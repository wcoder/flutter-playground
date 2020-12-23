import 'dart:async';

import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:flutter/material.dart';

class DeviceModel extends ChangeNotifier {
  StreamSubscription<DeviceSearchingState> _searchingSubscription;
  StreamSubscription<DeviceConnectionState> _connectionSubscription;

  final _deviceConnectionController =
      StreamController<DeviceConnectionState>.broadcast();

  final isCelsiusFormat = ValueNotifier<bool>(false);

  DeviceModel() {
    _searchingSubscription = DeviceManager.instance.searching.listen((event) {
      final isFound = event == DeviceSearchingState.found;
      if (isDeviceFound != isFound) {
        isDeviceFound = isFound;
        notifyListeners();
      }
    });
    _connectionSubscription = DeviceManager.instance.connection.listen((event) {
      _deviceConnectionController.sink.add(event);
      final isConnected = event == DeviceConnectionState.connected;
      if (isDeviceConnected != isConnected) {
        isDeviceConnected = isConnected;
        notifyListeners();
      }
    });
  }

  bool isDeviceFound = false;
  bool isDeviceConnected = false;

  Stream<DeviceConnectionState> get deviceConnection =>
      _deviceConnectionController.stream;
  Stream<String> get temperature =>
      DeviceManager.instance.temperature.map((event) {
        isCelsiusFormat.value = event.contains("C"); // fast hack
        return event;
      });

  @override
  void dispose() {
    _searchingSubscription?.cancel();
    _connectionSubscription?.cancel();
    _deviceConnectionController.close();
    disconnect();
    // _deviceManager.dispose(); // TODO: now used as singleton
    super.dispose();
  }

  Future<void> rescan() => DeviceManager.instance.rescan();
  Future<void> connect() => DeviceManager.instance.connect();
  Future<void> disconnect() => DeviceManager.instance.disconnect();

  Future<void> useCelsiusFormat(bool isCelsius) async {
    isCelsiusFormat.value = isCelsius;
    await DeviceManager.instance.changeTemperatureFormat(isCelsius);
  }
}
