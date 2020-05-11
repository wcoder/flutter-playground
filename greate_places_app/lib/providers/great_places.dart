import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:greate_places_app/helpers/db_helper.dart';
import 'package:greate_places_app/models/place.dart';

class GreatPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  void addPlace(String title, File image, PlaceLocation location) {
    final newPlace = Place(
      id: DateTime.now().toString(),
      title: title,
      location: location,
      image: image,
    );
    _items.add(newPlace);
    notifyListeners();

    DatabaseHelper.insert("places", {
      "id": newPlace.id,
      "title": newPlace.title,
      "image": newPlace.image.path,
      "loc_lat": newPlace.location.latitude,
      "loc_lng": newPlace.location.longitude,
      "address": newPlace.location.address,
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DatabaseHelper.getData("places");
    _items = dataList
        .map((item) => Place(
              id: item["id"],
              title: item["title"],
              image: File(item["image"]),
              location: PlaceLocation(
                latitude: item["loc_lat"],
                longitude: item["loc_lng"],
                address: item["address"],
              ),
            ))
        .toList();

    notifyListeners();
  }
}
