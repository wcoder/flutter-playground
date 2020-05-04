import 'package:flutter/material.dart';
import 'package:shopapp/widgets/prducts_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ProductGrids(),
    );
  }
}
