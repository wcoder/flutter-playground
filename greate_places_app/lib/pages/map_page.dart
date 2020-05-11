import 'package:flutter/material.dart';
import 'package:greate_places_app/models/place.dart';

class MapPage extends StatefulWidget {
  bool isSelecting;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  PlaceLocation _pickedLocation;
  void _selectLocation() async {
    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: 10,
        longitude: 10,
        address: "asdasd",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.check),
              onPressed: _pickedLocation == null
                  ? null
                  : () {
                      Navigator.of(context).pop(_pickedLocation);
                    })
        ],
      ),
      body: Center(
        // TODO: GoogleMap() widget
        child: RaisedButton(
          child: Text("Pick location"),
          onPressed: _selectLocation,
        ),
      ),
    );
  }
}
