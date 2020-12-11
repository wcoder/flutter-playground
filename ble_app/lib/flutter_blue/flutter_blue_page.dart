import 'package:ble_app/flutter_blue/find_devices_page.dart';
import 'package:ble_app/no_bluetooth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FlutterBluePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindDevicesPage();
        }
        return NoBluetoothPage();
      },
    );
  }
}
