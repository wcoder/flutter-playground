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

  String get test => "test string";

  DeviceModel() {
    Fimber.d("Init device model");
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

  // @override
  // void dispose() {
  //   super.dispose();
  // }

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

  void _startScan() {
    Fimber.d("Ble client created");

    _scanSubscription = _bleManager.startPeripheralScan().listen(
      (ScanResult scanResult) {
        if (scanResult.advertisementData.localName != null) {
          Fimber.d(
              'found new device ${scanResult.advertisementData.localName} ${scanResult.peripheral.identifier}');

          if (scanResult.advertisementData.localName == "Thermometer") {
            device = scanResult.peripheral;
            notifyListeners();

            _scanSubscription.cancel();
            _bleManager.stopPeripheralScan();
          }
        }
      },
    );
  }

  Future<void> refresh() async {
    _scanSubscription.cancel();
    await _bleManager.stopPeripheralScan();

    await _checkPermissions();
    try {
      _startScan();
    } catch (e) {
      Fimber.d("Couldn't refresh", ex: e);
    }
  }

  Future<void> connect() async {
    device
        .observeConnectionState(
      emitCurrentValue: true,
      completeOnDisconnect: true,
    )
        .listen((connectionState) {
      Fimber.d(
          "Peripheral ${device.identifier} connection state is $connectionState");
    });

    await device.connect();

    isConnected = await device.isConnected();
    notifyListeners();

    await device.discoverAllServicesAndCharacteristics();

    var services = await device.services();
    print(services);

    device
        .monitorCharacteristic(
      "00000001-710e-4a5b-8d75-3e5b444bc3cf",
      "00000002-710e-4a5b-8d75-3e5b444bc3cf",
    )
        .listen((event) {
      final value = utf8.decode(event.value);
      temperature = value;
      notifyListeners();
    });
  }

  Future<void> disconnect() async {
    await device.disconnectOrCancelConnection();
    isConnected = false;
    notifyListeners();
  }
}
