import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceModel extends ChangeNotifier {
  var _bleManager = BleManager();
  PermissionStatus _locationPermissionStatus;

  StreamSubscription<ScanResult> _scanSubscription;
  StreamSubscription<CharacteristicWithValue> _monitorTempoSubscription;
  StreamSubscription<PeripheralConnectionState>
      _deviceConnectionStateSubscription;

  DeviceModel() {
    Fimber.d("Init device model");
    _bleManager.setLogLevel(LogLevel.verbose);
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
        .then((_) => _checkPermissions())
        .catchError((e) => Fimber.d("Permission check error", ex: e))
        .then((_) => _waitForBluetoothPoweredOn())
        .then((_) => _startScan());
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _monitorTempoSubscription?.cancel();
    _deviceConnectionStateSubscription?.cancel();
    _bleManager.destroyClient();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (Platform.isAndroid) {
      _locationPermissionStatus = await Permission.location.request();
      if (_locationPermissionStatus != PermissionStatus.granted) {
        return Future.error(Exception("Location permission not granted"));
      }
    }
  }

  Future<void> _waitForBluetoothPoweredOn() async {
    Completer completer = Completer();
    StreamSubscription<BluetoothState> subscription;
    subscription =
        _bleManager.observeBluetoothState(emitCurrentValue: true).listen(
      (bluetoothState) async {
        if (bluetoothState == BluetoothState.POWERED_ON &&
            !completer.isCompleted) {
          await subscription.cancel();
          completer.complete();
        }
      },
    );
    return completer.future;
  }

  Peripheral device = null;
  bool get deviceFound => device != null;
  bool isConnected = false;
  String temperature = "--";
  bool searching = false;
  bool isCelsiusFormat = false;

  void _startScan() {
    Fimber.d("Ble client created");

    searching = true;
    notifyListeners();

    _scanSubscription = _bleManager.startPeripheralScan().listen(
      (ScanResult scanResult) {
        Fimber.d(
            'found new device ${scanResult.advertisementData.localName} ${scanResult.peripheral.identifier}');

        if (scanResult.advertisementData.localName == "Thermometer") {
          device = scanResult.peripheral;
          searching = false;
          notifyListeners();

          _scanSubscription.cancel();
          _bleManager.stopPeripheralScan();
        }
      },
    );
  }

  Future<void> refresh() async {
    _scanSubscription?.cancel();
    await _bleManager.stopPeripheralScan();

    await _checkPermissions();
    try {
      _startScan();
    } catch (e) {
      Fimber.d("Couldn't refresh", ex: e);
    }
  }

  final _serviceUuid = "00000001-710e-4a5b-8d75-3e5b444bc3cf";
  final _tempoValueCharacteristicUuid = "00000002-710e-4a5b-8d75-3e5b444bc3cf";
  final _tempoFormatCharacteristicUuid = "00000003-710e-4a5b-8d75-3e5b444bc3cf";

  Future<void> connect() async {
    _deviceConnectionStateSubscription = device
        .observeConnectionState(
      emitCurrentValue: true,
      // completeOnDisconnect: true,
    )
        .listen((connectionState) {
      Fimber.d(
          "Peripheral ${device.identifier} connection state is $connectionState");
    });

    isConnected = await device.isConnected();
    if (!isConnected) {
      await device.connect();
      isConnected = await device.isConnected();
    }
    notifyListeners();

    await device.discoverAllServicesAndCharacteristics();
    // await _runWithErrorHandling(() async {});
    var services = await device.services();
    print(services);

    _monitorTempoSubscription = device
        .monitorCharacteristic(
      _serviceUuid,
      _tempoValueCharacteristicUuid,
      transactionId: "monitorCPU",
    )
        .listen((event) {
      final value = utf8.decode(event.value);
      temperature = value;
      notifyListeners();
    });

    if (isCelsiusFormat == null) {
      _updateFormatInfo();
    }
  }

  Future<void> disconnect() async {
    await _runWithErrorHandling(() async {
      _monitorTempoSubscription.cancel();
      _monitorTempoSubscription = null;
      await device.disconnectOrCancelConnection();
      isConnected = false;
      isCelsiusFormat = false;
      temperature = "--";
      notifyListeners();
    });
  }

  Future<void> useCelsiusFormat(bool isCelsius) async {
    final format = isCelsius ? "C" : "F";
    final value = utf8.encode(format);
    await device.writeCharacteristic(
        _serviceUuid, _tempoFormatCharacteristicUuid, value, false,
        transactionId: "changeFormat");
    await _updateFormatInfo();
  }

  Future<void> _updateFormatInfo() async {
    var response = await device.readCharacteristic(
      _serviceUuid,
      _tempoFormatCharacteristicUuid,
      transactionId: "getFormat",
    );
    var responseString = utf8.decode(response.value);
    isCelsiusFormat = responseString == "C";
    notifyListeners();
  }

  Future<void> _runWithErrorHandling(Function func) async {
    try {
      await func();
    } on BleError catch (e) {
      Fimber.e("BleError caught: ${e.errorCode.value} ${e.reason}", ex: e);
    } catch (e) {
      if (e is Error) {
        debugPrintStack(stackTrace: e.stackTrace);
      }
      Fimber.e("${e.runtimeType}: $e", ex: e, stacktrace: e.stackTrace);
    }
  }
}
