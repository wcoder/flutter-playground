import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:ble_app/flutter_ble_lib/device_page.dart';
import 'package:ble_app/no_bluetooth_page.dart';
import 'package:flutter/material.dart';

class FlutterBleLibPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BleConnectionState>(
      stream: DeviceManager.instance.bleConnection,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == BleConnectionState.powered_on) {
          return DevicePage();
        }
        if (state == BleConnectionState.powered_off ||
            state == BleConnectionState.unsupported) {
          return NoBluetoothPage();
        }
        return Scaffold(
          body: Center(
            child: state == BleConnectionState.resetting
                ? CircularProgressIndicator()
                : Text(
                    "BLE status: $state",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
