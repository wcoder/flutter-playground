import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../widgets/meal_item.dart';

class CategoryMealsPage extends StatefulWidget {
  List<Meal> meals;

  CategoryMealsPage(this.meals);

  @override
  State<StatefulWidget> createState() => _CategoryMealsPageState();
}

class _CategoryMealsPageState extends State<CategoryMealsPage> {
  String categoryTitle;
  List<Meal> displayedMeals;
  bool _loadedInitDate = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loadedInitDate) {
      return;
    }

    final routeArgs = ModalRoute.of(context).settings.arguments as Map<String, String>;
    final categoryId = routeArgs['id'];
    categoryTitle = routeArgs['title'];
    displayedMeals = widget.meals.where((meal) {
      return meal.categories.contains(categoryId);
    }).toList();

    _loadedInitDate = true;
  }

  void _removeMeal(String mealId) {
    setState(() {
      displayedMeals.removeWhere((meal) => meal.id == mealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
      ),
      body: ListView.builder(
        itemCount: displayedMeals.length,
        itemBuilder: (ctx, index) {
          return MealItem(displayedMeals[index]); // _removeMeal
        },
      ),
    );
  }
}
