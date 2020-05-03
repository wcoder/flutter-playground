import 'package:flutter/material.dart';
import '../models/category.dart';
import '../routes.dart';

class CategoryItem extends StatelessWidget {
  final Category category;

  const CategoryItem(this.category);

  void _selectCategory(BuildContext ctx) {
    Navigator.of(ctx).pushNamed(
      Routes.categoryMeals,
      arguments: {
        'id': category.id,
        'title': category.title,
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(15);

    return InkWell(
      onTap: () => _selectCategory(context),
      splashColor: Theme.of(context).primaryColor,
      borderRadius: borderRadius,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Text(
          category.title,
          style: Theme.of(context).textTheme.title,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              category.color.withOpacity(0.7),
              category.color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}
