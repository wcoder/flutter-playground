import 'package:flutter/material.dart';
import 'package:greate_places_app/pages/add_place_screen.dart';
import 'package:greate_places_app/pages/places_list_page.dart';
import 'package:greate_places_app/providers/great_places.dart';
import 'package:greate_places_app/routes.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GreatPlaces>(
      create: (_) => GreatPlaces(),
      builder: (context, child) => MaterialApp(
        title: 'Great Places',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          accentColor: Colors.amber,
        ),
        home: PlacesListPage(),
        routes: {
          Routes.appPlace: (ctx) => AddPlacePage(),
        },
      ),
    );
  }
}
