import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:ble_app/flutter_ble_lib/device_page.dart';
import 'package:ble_app/no_bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlutterBleLibPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<BleConnectionState>(
      builder: (context, connectionState, child) {
        if (connectionState == BleConnectionState.powered_on) {
          return DevicePage();
        }
        if (connectionState == BleConnectionState.powered_off) {
          return NoBluetoothPage();
        }
        return Scaffold(
          body: Center(
            child: connectionState == BleConnectionState.resetting
                ? CircularProgressIndicator()
                : Text(
                    "BLE status: $connectionState",
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
