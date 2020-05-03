import 'package:flutter/material.dart';

class MealDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mealId = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail'),
      ),
      body: Container(),
    );
  }
}
