import 'package:ble_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fimber/flutter_fimber.dart';

void main() {
  Fimber.plantTree(FimberTree(useColors: true));
  runApp(App());
}
