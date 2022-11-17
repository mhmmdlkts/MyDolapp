import 'package:flutter/cupertino.dart';
import 'package:my_doll_app/services/camera_service.dart';
import 'package:my_doll_app/services/combine_service.dart';
import 'package:my_doll_app/services/person_service.dart';
import 'package:my_doll_app/services/system_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/services/weather_service.dart';

class InitService {

  static bool isInited = false;
  static bool isIniting = false;
  static Map<int, VoidCallback> _listeners = {};

  static Future init({bool force = false, Map<int, VoidCallback>? onInited}) async {
    if (onInited!=null) {
      _listeners.addAll(onInited!);
    }
    if ((isIniting || isInited) && !force) {
      callAllListeners();
      return;
    }
    isIniting = true;
    DateTime now = DateTime.now();
    List<Future> toDo = [
      WardrobeService.initWardrobes(now: now),
      PersonService.initPerson(now: now),
      SystemService.initSystem(now: now),
      CameraService.initCameras(now: now),
      WeatherService.initWeather(now: now),
      CombineService.initCombines(now: now)
    ];
    await Future.wait(toDo);
    await CombineService.initAllCombines();
    isInited = true;
    isIniting = false;
    callAllListeners();
  }

  static void callAllListeners() {
    _listeners.forEach((key, value) {
      value.call();
    });
  }

  static void removeListener(int s) {
    _listeners.remove(s);
  }
}