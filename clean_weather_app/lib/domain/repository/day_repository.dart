import 'package:clean_weather_app/domain/model/day.dart';
import 'package:flutter/foundation.dart';

abstract class DayRepository {
  Future<Day> getDay({
    @required double latitude,
    @required double longitude,
  });
}
