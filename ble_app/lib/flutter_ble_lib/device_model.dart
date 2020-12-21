import 'dart:async';

import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:flutter/material.dart';

class DeviceModel extends ChangeNotifier {
  final _deviceManager = DeviceManager();

  StreamSubscription<DeviceSearchingState> _searchingSubscription;

  DeviceModel() {
    _searchingSubscription = _deviceManager.searching.listen((event) {
      final isFound = event == DeviceSearchingState.found;
      if (isDeviceFound != isFound) {
        isDeviceFound = isFound;
        notifyListeners();
      }
    });
  }

  Stream<BleConnectionState> get bleConnection => _deviceManager.bleConnection;
  Stream<DeviceConnectionState> get deviceConnection =>
      _deviceManager.connection.map((event) {
        final isConnected = event == DeviceConnectionState.connected;
        if (isConnected != isDeviceConnected) {
          isDeviceConnected = isConnected;
          notifyListeners();
        }
        return event;
      });

  bool isDeviceFound = false;
  bool isDeviceConnected = false;

  Stream<String> get temperature => _deviceManager.temperature;

  @override
  void dispose() {
    _searchingSubscription?.cancel();
    _deviceManager.dispose();
    super.dispose();
  }

  Future<void> rescan() => _deviceManager.rescan();
  Future<void> connect() => _deviceManager.connect();
  Future<void> disconnect() => _deviceManager.disconnect();

  // bool isCelsiusFormat = false;

  // Future<void> useCelsiusFormat(bool isCelsius) async {
  //   isCelsiusFormat = isCelsius;
  //   notifyListeners();
  //   //
  //   // _changeCelsiusFormat(responseString);
  // }

  // Future<void> _updateFormatInfo() async {
  //   synchronized(() async {
  //     final response = await device.readCharacteristic(
  //       _serviceUuid,
  //       _tempoFormatCharacteristicUuid,
  //       transactionId: "getFormat",
  //     );
  //     final responseString = utf8.decode(response.value);
  //     _changeCelsiusFormat(responseString);
  //   });
  // }

  // void _changeCelsiusFormat(String str) {
  //   isCelsiusFormat = str == "C";
  //   notifyListeners();
  // }
}
