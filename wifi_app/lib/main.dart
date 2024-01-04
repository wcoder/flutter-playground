// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:open_settings_plus/open_settings_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _wifiName;
  String? _wifiBSSID;
  String? _wifiIP;
  String? _wifiIPv6;
  String? _wifiSubmask;
  String? _wifiBroadcast;
  String? _wifiGateway;
  List<WiFiAccessPoint> _accessPoints = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('WiFi App'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Active WiFi Info',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text('Name: $_wifiName'),
          Text('BSSID: $_wifiBSSID'),
          Text('IPv4: $_wifiIP'),
          Text('IPv6: $_wifiIPv6'),
          Text('Submask: $_wifiSubmask'),
          Text('Broadcast: $_wifiBroadcast'),
          Text('Gateway: $_wifiGateway'),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _accessPoints.length,
              itemBuilder: (context, index) {
                final item = _accessPoints[index];
                return ListTile(
                  title: Text(item.ssid),
                  subtitle: Text(
                      '${item.standard.name}   ${item.level}   ${item.capabilities}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getWifiInfo,
            tooltip: 'Get WiFi Info',
            child: const Icon(Icons.wifi),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _getWifiList,
            tooltip: 'Get WiFi List',
            child: const Icon(Icons.list),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _openWifiSettings,
            tooltip: 'Open WiFi Settings',
            child: const Icon(Icons.settings),
          ),
        ],
      ),
    );
  }

  void _getWifiInfo() async {
    try {
      const locationPermission = Permission.locationWhenInUse;
      final locationStatus = await locationPermission.status;

      if (locationStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      } else if (locationStatus != PermissionStatus.granted) {
        if (!await locationPermission.request().isGranted) {
          print('XXX: location permissions denied');
        }
      }

      final info = NetworkInfo();

      _wifiName = await info.getWifiName(); // "FooNetwork"
      _wifiBSSID = await info.getWifiBSSID(); // 11:22:33:44:55:66
      _wifiIP = await info.getWifiIP(); // 192.168.1.43
      _wifiIPv6 =
          await info.getWifiIPv6(); // 2001:0db8:85a3:0000:0000:8a2e:0370:7334
      _wifiSubmask = await info.getWifiSubmask(); // 255.255.255.0
      _wifiBroadcast = await info.getWifiBroadcast(); // 192.168.1.255
      _wifiGateway = await info.getWifiGatewayIP(); // 192.168.1.1

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _getWifiList() async {
    final scanner = WiFiScan.instance;

    setState(() {
      _accessPoints = [];
    });

    final canScan = await scanner.canStartScan(askPermissions: true);
    switch (canScan) {
      case CanStartScan.yes:
        final isScanning = await scanner.startScan();
        if (!isScanning) {
          print('XXX: no Wifi scan =(');
          return;
        }

        await Future.delayed(const Duration(seconds: 5));

        final can = await scanner.canGetScannedResults(askPermissions: true);
        switch (can) {
          case CanGetScannedResults.yes:
            _accessPoints = await scanner.getScannedResults();
            setState(() {});
            break;
          default:
            print('XXX: Wifi scan results: $can');
            break;
        }

        break;
      default:
        print('XXX: Wifi scan: $canScan');
        break;
    }
  }

  void _openWifiSettings() async {
    if (Platform.isAndroid) {
      const settingsAndroid = OpenSettingsPlusAndroid();
      await settingsAndroid.wifi();
      return;
    }
    if (Platform.isIOS) {
      const settingsiOS = OpenSettingsPlusIOS();
      await settingsiOS.wifi();
      return;
    }
  }
}
