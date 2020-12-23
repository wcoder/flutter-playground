import 'package:ble_app/flutter_ble_lib/device_manager.dart';
import 'package:ble_app/flutter_ble_lib/device_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DeviceModel>(
      create: (_) => DeviceModel(),
      builder: (context, child) => Scaffold(
        appBar: AppBar(
          title: Text("flutter_ble_lib"),
          actions: [
            _ConnectionButton(),
            Consumer<DeviceModel>(
              builder: (context, model, _) {
                return IconButton(
                  onPressed: model.isDeviceFound
                      ? null
                      : () => context.read<DeviceModel>().rescan(),
                  icon: Icon(Icons.refresh),
                );
              },
            ),
          ],
        ),
        body: Center(
          child: Consumer<DeviceModel>(
            builder: (context, model, snapshot) {
              return model.isDeviceFound
                  ? model.isDeviceConnected
                      ? _DeviceWidget()
                      : Text("Device found, not connected")
                  : const _SearchingWidget();
            },
          ),
        ),
      ),
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceModel>(
      builder: (context, model, child) {
        if (!model.isDeviceFound) {
          return Container();
        }

        return StreamBuilder(
          stream: model.deviceConnection,
          builder: (context, snapshot) {
            final state = snapshot.data;

            if (state == DeviceConnectionState.unknown) {
              return Container();
            }

            if (state == DeviceConnectionState.connecting ||
                state == DeviceConnectionState.disconnecting) {
              return const _AppBarCircularProgressIndicator();
            }

            final isConnected = state == DeviceConnectionState.connected;
            final onPressed = isConnected ? model.disconnect : model.connect;
            final icon =
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth;
            return IconButton(
              onPressed: () async => await onPressed(),
              icon: Icon(icon),
            );
          },
        );
      },
    );
  }
}

class _AppBarCircularProgressIndicator extends StatelessWidget {
  const _AppBarCircularProgressIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeviceWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer<DeviceModel>(
          builder: (context, value, child) => StreamBuilder(
            stream: value.temperature,
            initialData: "---",
            builder: (context, snapshot) => Text(
              snapshot.data,
              style: Theme.of(context).textTheme.headline2,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("F"),
            Consumer<DeviceModel>(
              builder: (context, model, child) => ValueListenableBuilder(
                valueListenable: model.isCelsiusFormat,
                builder: (context, value, child) => Switch(
                  value: value,
                  onChanged: model.isDeviceConnected
                      ? (v) => model.useCelsiusFormat(v)
                      : null,
                ),
              ),
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
