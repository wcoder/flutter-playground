import 'package:flutter/material.dart';
import 'package:moolax/services/service_locator.dart';
import 'package:moolax/ui/views/calculate_screen.dart';

void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currencies',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: CalculateCurrencyScreen(),
    );
  }
}
