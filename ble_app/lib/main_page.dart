import 'package:ble_app/flutter_ble_lib/flutter_ble_lib_page.dart';
import 'package:ble_app/flutter_blue/flutter_blue_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FlutterBluePage(),
                ),
              ),
              child: Text("flutter-blue sample"),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FlutterBleLibPage(),
                ),
              ),
              child: Text("flutter-ble-lib sample"),
            ),
          ],
        ),
      ),
    );
  }
}
