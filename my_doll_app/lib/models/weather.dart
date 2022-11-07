import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Weather {
  double temp;
  WeatherType type;
  String country;

  Weather({required this.temp, required this.type, required this.country});

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

  IconData getIcon() {
    switch (type) {
      case WeatherType.sunny: return Icons.sunny;
      case WeatherType.cloudy: return Icons.cloud;
      case WeatherType.rainy: return Icons.cloudy_snowing;
      case WeatherType.heavyRainy: return Icons.cloudy_snowing;
      case WeatherType.snowy: return Icons.cloudy_snowing;
    }
  }
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  heavyRainy,
  snowy,
}