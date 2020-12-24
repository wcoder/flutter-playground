import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_fimber/flutter_fimber.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/extension.dart';

enum BleConnectionState {
  unknown,
  unsupported,
  unauthorized,
  powered_on,
  powered_off,
  resetting,
}

enum DeviceConnectionState {
  unknown,
  disconnected,
  connected,
  disconnecting,
  connecting,
}

enum DeviceSearchingState { unknown, searching, found }

class DeviceManager {
  static const DeviceIdentifier = "6A89CD01-62F1-A8A3-E7F2-F4E7F750C8A2";
  static const DeviceLocalName = "Thermometer";
  static const ServiceUuid = "00000001-710e-4a5b-8d75-3e5b444bc3cf";
  static const TempoValueUuid = "00000002-710e-4a5b-8d75-3e5b444bc3cf";
  static const TempoFormatUuid = "00000003-710e-4a5b-8d75-3e5b444bc3cf";

  final _bleManager = BleManager();

  // stream controllers of public streams
  final _searchDeviceController =
      StreamController<DeviceSearchingState>.broadcast();
  final _deviceConnectionController =
      StreamController<DeviceConnectionState>.broadcast();
  final _temperatureController = StreamController<String>.broadcast();

  // internal subscriptions
  StreamSubscription<ScanResult> _scanSubscription;
  StreamSubscription<PeripheralConnectionState> _deviceConectionSubscription;
  StreamSubscription<CharacteristicWithValue> _temperatureSubscription;

  Peripheral _device;
  bool _isConnected = false;

  // lazy singleton

  static DeviceManager _instance;
  static DeviceManager get instance {
    if (_instance == null) {
      _instance = DeviceManager._();
    }
    return _instance;
  }

  DeviceManager._() {
    _initBle();
  }

  // public streams

  Stream<BleConnectionState> get bleConnection => _bleManager
      .observeBluetoothState(
        emitCurrentValue: true,
      )
      .map(_convertBleConnectionState);

  Stream<DeviceConnectionState> get connection =>
      _deviceConnectionController.stream;

  Stream<DeviceSearchingState> get searching => _searchDeviceController.stream;

  Stream<String> get temperature => _temperatureController.stream;

  // public methods

  Future<void> dispose() async {
    await _searchDeviceController.close();
    await _deviceConnectionController.close();
    await _temperatureController.close();

    await _scanSubscription?.cancel();
    await _deviceConectionSubscription?.cancel();
    await _temperatureSubscription?.cancel();

    await _bleManager.destroyClient();
  }

  Future<void> rescan() async {
    await _cancelScan();
    await _checkPermissions();
    try {
      _startScan();
    } catch (e) {
      Fimber.d("Couldn't refresh", ex: e);
    }
  }

  Future<void> connect() async {
    _isConnected = await _device.isConnected();
    if (!_isConnected) {
      await _device.connect();
      _isConnected = await _device.isConnected();
    }

    await _device.discoverAllServicesAndCharacteristics();
    final services = await _device.services();
    Fimber.d(services.toString());

    await _subscribeOnTemperatureCharacteristic();
  }

  Future<void> disconnect() async {
    await _runWithErrorHandling(() async {
      await _device.disconnectOrCancelConnection();
      _isConnected = false;
    });
  }

  Future<String> changeTemperatureFormat(bool isCelsius) {
    return synchronized<String>(() async {
      final format = isCelsius ? "C" : "F";
      final value = utf8.encode(format);
      final characteristic = await _device.writeCharacteristic(
        ServiceUuid,
        TempoFormatUuid,
        value,
        true,
        transactionId: "changeFormat",
      );
      final response = await characteristic.read(transactionId: "readFormat");
      final responseString = utf8.decode(response);
      return responseString;
    });
  }

  // private methods

  void _initBle() {
    Fimber.d("Init BLE");
    _bleManager
        .createClient(
          restoreStateIdentifier: "example-restore-state-identifier",
          restoreStateAction: (peripherals) {
            peripherals?.forEach((peripheral) {
              // TODO: reinit device + subscriptions
              Fimber.d("Restored peripheral: ${peripheral.name}");
            });
          },
        )
        .catchError((e) => Fimber.d("Couldn't create BLE client", ex: e))
        .then((_) => Fimber.d("Ble client created"))
        .then((_) => _checkPermissions())
        .catchError((e) => Fimber.d("Permission check error", ex: e))
        .then((_) => _waitForBluetoothPoweredOn())
        .then((_) => _startScan());
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      final locationPermissionStatus = await Permission.location.request();
      if (locationPermissionStatus != PermissionStatus.granted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  Future<void> _waitForBluetoothPoweredOn() async {
    final completer = Completer();
    StreamSubscription waiter;
    waiter = bleConnection.listen((state) async {
      if (state == BleConnectionState.powered_on && !completer.isCompleted) {
        completer.complete();
        waiter.cancel();
      }
    });
    return completer.future;
  }

  BleConnectionState _convertBleConnectionState(BluetoothState state) {
    switch (state) {
      case BluetoothState.UNSUPPORTED:
        return BleConnectionState.unsupported;
      case BluetoothState.UNAUTHORIZED:
        return BleConnectionState.unauthorized;
      case BluetoothState.RESETTING:
        return BleConnectionState.resetting;
      case BluetoothState.POWERED_OFF:
        return BleConnectionState.powered_off;
      case BluetoothState.POWERED_ON:
        return BleConnectionState.powered_on;
      case BluetoothState.UNKNOWN:
      default:
        return BleConnectionState.unknown;
    }
  }

  void _startScan() async {
    _searchDeviceController.sink.add(DeviceSearchingState.searching);

    final deviceIdentifiers = [DeviceIdentifier];

    void _foundDevice(Peripheral peripheral) {
      _device = peripheral;
      _searchDeviceController.sink.add(DeviceSearchingState.found);
      _subscribeOnDeviceEvents();
    }

    // used on Android
    final connectedDevices =
        await _bleManager.connectedPeripherals([ServiceUuid]);
    if (connectedDevices.isNotEmpty) {
      Fimber.d("Found connected device");
      _foundDevice(connectedDevices.first);
      return;
    }

    // used on iOS
    final knownDevices = await _bleManager.knownPeripherals(deviceIdentifiers);
    if (knownDevices.isNotEmpty) {
      Fimber.d("Found known device");
      _foundDevice(knownDevices.first);
      return;
    }

    Fimber.d("Start scanner...");
    _scanSubscription = _bleManager.startPeripheralScan().listen((scanResult) {
      if (scanResult.advertisementData.localName == DeviceLocalName) {
        _cancelScan();
        _foundDevice(scanResult.peripheral);
      }
    });
  }

  Future<void> _cancelScan() async {
    Fimber.d("Cancel scanner...");
    await _scanSubscription?.cancel();
    await _bleManager.stopPeripheralScan();
  }

  Future<void> _subscribeOnDeviceEvents() async {
    await _deviceConectionSubscription?.cancel();
    _deviceConectionSubscription =
        _device.observeConnectionState(emitCurrentValue: true).listen((event) {
      _deviceConnectionController.sink.add(_convertConnectionState(event));
    });

    _isConnected = await _device.isConnected();
    if (_isConnected) {
      await _subscribeOnTemperatureCharacteristic();
    }
  }

  Future<void> _subscribeOnTemperatureCharacteristic() async {
    await _temperatureSubscription?.cancel();
    await _bleManager.cancelTransaction("monitorCPU");
    _temperatureSubscription = _device
        .monitorCharacteristic(
      ServiceUuid,
      TempoValueUuid,
      transactionId: "monitorCPU",
    )
        .listen((event) {
      final temperature = utf8.decode(event.value);
      _temperatureController.sink.add(temperature);
    });
  }

  DeviceConnectionState _convertConnectionState(
      PeripheralConnectionState state) {
    switch (state) {
      case PeripheralConnectionState.connected:
        return DeviceConnectionState.connected;
      case PeripheralConnectionState.connecting:
        return DeviceConnectionState.connecting;
      case PeripheralConnectionState.disconnected:
        return DeviceConnectionState.disconnected;
      case PeripheralConnectionState.disconnecting:
        return DeviceConnectionState.disconnecting;
      default:
        return DeviceConnectionState.unknown;
    }
  }

  Future<void> _runWithErrorHandling(Function func) async {
    try {
      await func();
    } on BleError catch (e) {
      Fimber.e("BleError caught: ${e.errorCode.value} ${e.reason}", ex: e);
    } catch (e) {
      Fimber.e("${e.runtimeType}: $e", ex: e, stacktrace: e.stackTrace);
    }
  }
}
