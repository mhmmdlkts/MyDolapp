import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart' as w;

class Weather {
  late double temp;
  late WeatherType type;
  late String country;
  late DateTime dateTime;

  Weather({required this.temp, required this.type, required this.country, required this.dateTime});

  Weather.fromWeather(w.Weather w, String country) {
    temp = w.temperature?.celsius??0.0;
    this.country = country??'';
    type = conditionCodeToType(w.weatherConditionCode??0);
    dateTime = DateTime.now();
  }

  String getReadableTemp() {
    return '${temp.toStringAsFixed(1)}°';
  }

  String getReadableType() {
    switch (type) {
      case WeatherType.sunny: return 'Sunny';
      case WeatherType.cloudy: return 'Cloudy';
      case WeatherType.rainy: return 'Rain';
      case WeatherType.heavyRainy: return 'Heavy Rain';
      case WeatherType.snowy: return 'Snowy';
    }
  }

  Color getColor() {
    switch (type) {
      case WeatherType.sunny: return const Color.fromARGB(255, 255,125,111);
      case WeatherType.cloudy: return const Color.fromARGB(255, 93,158,218);
      case WeatherType.rainy: return const Color.fromARGB(255, 121, 161, 208);
      case WeatherType.heavyRainy: return const Color.fromARGB(255, 88,116,141);
      case WeatherType.snowy: return const Color.fromARGB(255, 175,206,225);
    }
  }

  AssetImage getImage() {
    switch (type) {
      case WeatherType.sunny: return const AssetImage('assets/images/weather/cloudy.png');
      case WeatherType.cloudy: return const AssetImage('assets/images/weather/cloudy.png');
      case WeatherType.rainy: return const AssetImage('assets/images/weather/rainy.png');
      case WeatherType.heavyRainy: return const AssetImage('assets/images/weather/rainy.png');
      case WeatherType.snowy: return const AssetImage('assets/images/weather/snowy.png');
    }
  }

  IconData getIcon() {
    switch (type) {
      case WeatherType.sunny: return Icons.sunny;
      case WeatherType.cloudy: return Icons.cloud;
      case WeatherType.rainy: return Icons.cloudy_snowing;
      case WeatherType.heavyRainy: return Icons.cloudy_snowing;
      case WeatherType.snowy: return Icons.cloudy_snowing;
    }
  }

  WeatherType conditionCodeToType(int weatherConditionCode) {
    switch (weatherConditionCode) {
      case 0: return WeatherType.rainy;
    }
    return WeatherType.sunny;
  }

  static bool isDay(hour) => hour >= 6 && hour <= 18;
  static bool isDusk(hour) => hour >= 16 && hour <= 18;
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  heavyRainy,
  snowy,
}