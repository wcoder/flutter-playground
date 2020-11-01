import 'package:clean_weather_app/domain/state/home/home_state.dart';
import 'package:clean_weather_app/internal/dependencies/home_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  HomeState _homeState;

  @override
  void initState() {
    super.initState();
    _homeState = HomeModule.homeState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: _getBody(),
      ),
    );
  }

  Widget _getBody() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getRowInput(),
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 20),
              child: RaisedButton(
                child: Text('Get'),
                onPressed: _getDay,
              ),
            ),
            _getDayInfo(),
          ],
        ),
      ),
    );
  }

  Widget _getRowInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _latController,
            autofocus: false,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(hintText: 'Latitude'),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: _lngController,
            autofocus: false,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            decoration: InputDecoration(hintText: 'Longitude'),
          ),
        ),
      ],
    );
  }

  Widget _getDayInfo() {
    return Observer(
      builder: (_) {
        if (_homeState.isLoading)
          return Center(
            child: CircularProgressIndicator(),
          );
        if (_homeState.day == null) return Container();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sunrise: ${_homeState.day.sunrise.toLocal()}'),
            Text('Sunset: ${_homeState.day.sunset.toLocal()}'),
            Text('Solar Noon: ${_homeState.day.solarNoon.toLocal()}'),
            Text(
              'Duration: ${Duration(seconds: _homeState.day.dayLength)}',
            ),
          ],
        );
      },
    );
  }

  // TODO: export to BL
  void _getDay() {
    // get data
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);
    _homeState.getDay(latitude: lat, longitude: lng);
  }
}
