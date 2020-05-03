import 'package:flutter/material.dart';
import '../services/dummy_data.dart';
import '../widgets/category_item.dart';

class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DeliMeals'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(25),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: DUMMY_CATEGORIES.length,
        itemBuilder: (context, index) {
          final category = DUMMY_CATEGORIES[index];
          return CategoryItem(category.title, category.color);
        },
      ),
    );
  }
}
