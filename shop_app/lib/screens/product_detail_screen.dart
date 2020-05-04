import 'package:flutter/material.dart';
import 'package:shopapp/models/product.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(productId),
      ),
      body: null,
    );
  }
}
