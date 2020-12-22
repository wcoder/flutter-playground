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
        if (snapshot.data == BleConnectionState.powered_on) {
          return DevicePage();
        }
        if (snapshot.data == BleConnectionState.powered_off) {
          return NoBluetoothPage();
        }
        return Scaffold(
          body: Center(
            child: snapshot.data == BleConnectionState.resetting
                ? CircularProgressIndicator()
                : Text(
                    "BLE status: ${snapshot.data}",
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
