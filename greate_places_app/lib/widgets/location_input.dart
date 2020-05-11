import 'package:flutter/material.dart';
import 'package:greate_places_app/helpers/location_helper.dart';
import 'package:greate_places_app/models/place.dart';
import 'package:greate_places_app/routes.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  final Function(double lat, double lng) onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImageUrl;

  void _showPreview(double lat, double lng) {
    final locationPreviewUrl = LocationHelper.generateLocationPreviewImage(
      latitude: lat,
      longitude: lng,
    );
    setState(() {
      _previewImageUrl = locationPreviewUrl;
    });
  }

  Future<void> _getCurrentUserLocation() async {
    final locationData = await Location().getLocation();
    _showPreview(locationData.latitude, locationData.longitude);
    widget.onSelectPlace(locationData.latitude, locationData.longitude);
  }

  Future<void> _selectOnMap() async {
    final selectedLocation = await Navigator.of(context).pushNamed(Routes.map) as PlaceLocation;
    if (selectedLocation == null) {
      return;
    }
    _showPreview(selectedLocation.latitude, selectedLocation.longitude);
    widget.onSelectPlace(selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? Text(
                  "No Location Chosen",
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl,
                  fit: BoxFit.cover,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.location_on),
              label: Text("Current Location"),
              textColor: Theme.of(context).primaryColor,
              onPressed: _getCurrentUserLocation,
            ),
            FlatButton.icon(
              icon: Icon(Icons.map),
              label: Text("Select on Map"),
              textColor: Theme.of(context).primaryColor,
              onPressed: _selectOnMap,
            )
          ],
        )
      ],
    );
  }
}
