import 'package:ble_app/flutter_ble_lib/device_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlutterBleLibPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_ble_lib"),
        actions: [
          Consumer<DeviceModel>(
            builder: (context, model, child) {
              if (model.deviceFound) {
                return IconButton(
                  onPressed: () {
                    if (model.isConnected) {
                      model.disconnect();
                    } else {
                      model.connect();
                    }
                  },
                  icon: Icon(model.isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth),
                );
              }
              return Container();
            },
          ),
          IconButton(
            onPressed: () => context.read<DeviceModel>().refresh(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Text(
          context.watch<DeviceModel>().temperature,
          style: Theme.of(context).textTheme.headline2,
        ),
      ),
    );
  }
}
