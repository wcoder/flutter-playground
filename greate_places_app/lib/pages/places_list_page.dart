import 'package:flutter/material.dart';
import 'package:greate_places_app/providers/great_places.dart';
import 'package:greate_places_app/routes.dart';
import 'package:provider/provider.dart';

class PlacesListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("You Places"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.appPlace);
            },
          )
        ],
      ),
      body: Center(
        child: Consumer<GreatPlaces>(
          child: Center(
            child: Text("Got not places yet, start adding some!"),
          ),
          builder: (context, provider, child) {
            if (provider.items.length <= 0) {
              return child;
            }
            return ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (context, index) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: FileImage(provider.items[index].image),
                ),
                title: Text(provider.items[index].title),
                onTap: () {
                  // TODO:...
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
