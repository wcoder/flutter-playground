import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greate_places_app/providers/great_places.dart';
import 'package:greate_places_app/widgets/image_input.dart';
import 'package:provider/provider.dart';

class AddPlacePage extends StatefulWidget {
  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final TextEditingController _titleController = TextEditingController();

  File _pickedImage;

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  void _savePlace() {
    if (_titleController.text.isEmpty || _pickedImage == null) {
      return;
    }

    Provider.of<GreatPlaces>(context, listen: false).addPlace(_titleController.text, _pickedImage);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a New Place"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        decoration: InputDecoration(labelText: "Title"),
                        controller: _titleController,
                      ),
                      SizedBox(height: 10,),
                      ImageInput(_selectImage),
                    ],
                  ),
                ),
              ),
            ),
            RaisedButton.icon(
              icon: Icon(Icons.add),
              label: Text("Add Place"),
              onPressed: _savePlace,
              elevation: 0,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              color: Theme.of(context).accentColor,
            )
          ],
        ),
      ),
    );
  }
}
