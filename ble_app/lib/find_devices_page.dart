import 'package:ble_app/device_page.dart';
import 'package:ble_app/widgets/scan_result_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class FindDevicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () => FlutterBlue.instance.startScan(
          timeout: Duration(seconds: 4),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<BluetoothDevice>>(
                stream: Stream.periodic(Duration(seconds: 2)).asyncMap(
                  (event) => FlutterBlue.instance.connectedDevices,
                ),
                initialData: [],
                builder: (context, snapshot) {
                  return Column(
                    children: snapshot.data
                        .map(
                          (device) => ListTile(
                            title: Text(device.name),
                            subtitle: Text(device.id.toString()),
                            trailing: StreamBuilder<BluetoothDeviceState>(
                              stream: device.state,
                              initialData: BluetoothDeviceState.connected,
                              builder: (context, snapshot) {
                                if (snapshot.data ==
                                    BluetoothDeviceState.connected) {
                                  return RaisedButton(
                                    child: Text('OPEN'),
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DevicePage(
                                          device: device,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Text(snapshot.data.toString());
                              },
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (context, snapshot) {
                  return Column(
                    children: snapshot.data
                        .map(
                          (result) => ScanResultTile(
                              result: result,
                              onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        result.device.connect();
                                        return DevicePage(
                                          device: result.device,
                                        );
                                      },
                                    ),
                                  )),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (context, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () => FlutterBlue.instance.startScan(
                timeout: Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }
}
