import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather/weather.dart' as w;

class Weather5Day {
  List<Weather> list = [];

  Weather5Day(List<w.Weather> weather, String country) {
    weather.forEach((element) {
      list.add(Weather.fromWeather(element, country));
    });
  }

  Weather? getWeather(DateTime dateTime) {
    if (dateTime.isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
      return null;
    }

    final closetsDateTimeToNow = list.reduce(
            (a, b) => a.dateTime.difference(dateTime).abs() < b.dateTime.difference(dateTime).abs() ? a : b);

    return closetsDateTimeToNow;
  }
}

class Weather {
  late double temp;
  late WeatherType type;
  late String country;
  late DateTime dateTime;
  late w.Weather weather;

  Weather({required this.temp, required this.type, required this.country, required this.dateTime});

  Weather.fromWeather(w.Weather w, String country) {
    temp = w.temperature?.celsius??0.0;
    this.country = country??'';
    type = conditionCodeToType(w.weatherConditionCode??0);
    dateTime = w.date??DateTime(1990);
    weather = w;
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

  // TODO check that https://openweathermap.org/weather-conditions
  WeatherType conditionCodeToType(int weatherConditionCode) {
    switch (weatherConditionCode.toString().characters.first) {
      case '0': return WeatherType.rainy; // Thunderstorm
      case '3': return WeatherType.rainy; // Drizzle
      case '5': return WeatherType.rainy; // Rain
      case '6': return WeatherType.snowy; // Snow
      case '7': return WeatherType.rainy; // Atmosphere !!
      case '8': return WeatherType.sunny; // Clear
      case '9': return WeatherType.cloudy; // Clouds
    }
    return WeatherType.sunny;
  }

  static bool isDayStatic(hour) => hour >= 6 && hour <= 18;
  bool isDay(hour) => hour >= _getSunriseHour() && hour <= _getSunsetHour();

  int _getSunriseHour() => weather.sunrise?.hour??6;
  int _getSunsetHour() => weather.sunset?.hour??18;
}

enum WeatherType {
  sunny,
  cloudy,
  rainy,
  heavyRainy,
  snowy,
}