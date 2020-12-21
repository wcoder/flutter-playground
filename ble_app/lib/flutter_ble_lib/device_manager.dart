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
  static const DeviceIdentifier = "DC:A6:32:B8:51:FE";
  static const ServiceUuid = "00000001-710e-4a5b-8d75-3e5b444bc3cf";
  static const TempoValueUuid = "00000002-710e-4a5b-8d75-3e5b444bc3cf";
  static const TempoFormatUuid = "00000003-710e-4a5b-8d75-3e5b444bc3cf";

  final _bleManager = BleManager();

  final _searchingStream = StreamController<DeviceSearchingState>();

  StreamSubscription<ScanResult> _scanSubscription;
  Peripheral _device;
  bool _isConnected = false;

  DeviceManager() {
    _initBle();
  }

  Stream<BleConnectionState> get bleConnection => _bleManager
      .observeBluetoothState(
        emitCurrentValue: true,
      )
      .map(_convertBleConnectionState);
  Stream<DeviceConnectionState> get connection => _device
      .observeConnectionState(
        emitCurrentValue: true,
      )
      .map(_convertConnectionState);
  Stream<DeviceSearchingState> get searching => _searchingStream.stream;
  Stream<String> get temperature => _device
      .monitorCharacteristic(
        ServiceUuid,
        TempoValueUuid,
        transactionId: "monitorCPU",
      )
      .map((event) => utf8.decode(event.value));

  Future<void> dispose() async {
    await _searchingStream.close();

    await _scanSubscription?.cancel();

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
  }

  Future<void> disconnect() async {
    await _runWithErrorHandling(() async {
      await _device.disconnectOrCancelConnection();
      _isConnected = false;
      // isCelsiusFormat = false;
      // temperature = "--";
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

  void _initBle() {
    Fimber.d("Init BLE");
    _bleManager
        .createClient(
          restoreStateIdentifier: "example-restore-state-identifier",
          restoreStateAction: (peripherals) {
            peripherals?.forEach((peripheral) {
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
    _searchingStream.sink.add(DeviceSearchingState.searching);

    final deviceIdentifiers = [DeviceIdentifier];
    final knownDevices = await _bleManager.knownPeripherals(deviceIdentifiers);

    void _foundDevice(Peripheral peripheral) {
      _device = peripheral;
      _searchingStream.sink.add(DeviceSearchingState.found);
    }

    if (knownDevices.isEmpty) {
      Fimber.d("Start scanner...");
      _scanSubscription = _bleManager
          .startPeripheralScan(uuids: deviceIdentifiers)
          .listen((scanResult) {
        _cancelScan();
        _foundDevice(scanResult.peripheral);
      });
    } else {
      Fimber.d("Found known device");
      _foundDevice(knownDevices.first);
    }
  }

  Future<void> _cancelScan() async {
    Fimber.d("Cencel scanner...");
    await _scanSubscription?.cancel();
    await _bleManager.stopPeripheralScan();
    _searchingStream.sink.add(DeviceSearchingState.unknown);
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
