import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:ble_app/flutter_ble_lib/device_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_ble_lib"),
        actions: [
          Consumer<DeviceModel>(
            builder: (context, model, child) {
              if (model.isDeviceFound) {
                return StreamBuilder(
                  stream: model.deviceConnection,
                  initialData: DeviceConnectionState.unknown,
                  builder: (context, connectionSnapshot) {
                    if (connectionSnapshot.data ==
                        DeviceConnectionState.unknown) {
                      return Container();
                    }
                    if (connectionSnapshot.data ==
                            DeviceConnectionState.connecting ||
                        connectionSnapshot.data ==
                            DeviceConnectionState.disconnecting) {
                      return CircularProgressIndicator();
                    }
                    final isConnected = connectionSnapshot.data ==
                        DeviceConnectionState.connected;
                    var onPressed =
                        isConnected ? model.disconnect : model.connect;
                    var icon = isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth;
                    return IconButton(
                      onPressed: () async => await onPressed(),
                      icon: Icon(icon),
                    );
                  },
                );
              }
              return Container();
            },
          ),
          IconButton(
            onPressed: () => context.read<DeviceModel>().rescan(),
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: Consumer<DeviceModel>(
          builder: (context, model, snapshot) {
            return model.isDeviceFound
                ? model.isDeviceConnected
                    ? _DeviceWidget()
                    : Text("not connected")
                : const _SearchingWidget();
          },
        ),
      ),
    );
  }
}

class _DeviceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder(
          stream: context.watch<DeviceModel>().temperature,
          initialData: "---",
          builder: (context, snapshot) => Text(
            snapshot.data == null ? "null" : snapshot.data,
            style: Theme.of(context).textTheme.headline2,
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("F"),
            Consumer<DeviceModel>(
              builder: (context, model, child) {
                return Switch(
                  value: false, //model.isCelsiusFormat,
                  onChanged: null, //model.isConnected
                  // ? null //(value) => model.useCelsiusFormat(value)
                  // : null,
                );
              },
            ),
            Text("C"),
          ],
        ),
      ],
    );
  }
}

class _SearchingWidget extends StatelessWidget {
  const _SearchingWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text("searching device...")
      ],
    );
  }
}
