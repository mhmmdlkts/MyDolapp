import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:my_doll_app/services/weather_service.dart';
import 'package:my_doll_app/widgets/sun_moon_widget.dart';
import 'package:parallax_rain/parallax_rain.dart';
import 'package:snowfall/snowfall.dart';
import 'package:flutter/services.dart';

import '../models/weather.dart';

class WeatherBgWidget extends StatefulWidget {
  final Widget? child;
  final bool showShadow;

  const WeatherBgWidget({this.child, this.showShadow = false, super.key});

  @override
  _WeatherBgWidgetState createState() => _WeatherBgWidgetState();
}

class _WeatherBgWidgetState extends State<WeatherBgWidget> {

  DateTime dateTime = DateTime.now();
  Shadow shadow = const Shadow(
    offset: Offset(0.0, 0.0),
    blurRadius: 3.0,
    color: Colors.black54,
  );

  @override
  void initState() {
    super.initState();
    // doIt();
  }

  double totalDelta = 0;
  double lastValue = 0;

  @override
  Widget build(BuildContext context) {
    // DateTime now = DateTime.now();
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        //color: widget.weather?.getColor()??Colors.white,
        image: getWeather()!=null?DecorationImage(
          image: getWeather()!.getImage(),
          fit: BoxFit.fill,
        ):null,
      ),
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(Weather.isDayStatic(dateTime.hour)?0:0.6),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Opacity(
                opacity: 0.7,
                child: SunMoonWidget(time: dateTime, weather: getWeather(),),
              ),
            ),
            getWeather()==null?Container():weatherAnimation(
              child: SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                        onPanStart: (_) {
                          totalDelta = 0;
                          lastValue = 0;
                        },
                        onPanUpdate: (details) {
                          lastValue = details.delta.dx;
                          totalDelta += details.delta.dx;
                          int sensitivity = 20;
                          bool flag = false;
                          if (totalDelta >= sensitivity) {
                            flag = true;
                            dateTime = dateTime.add(const Duration(hours: 1));
                            if (dateTime.millisecond != 0) {
                              dateTime = dateTime.subtract(Duration(minutes: dateTime.minute, milliseconds: dateTime.millisecond, microseconds: dateTime.microsecond));
                            }
                          }
                          if (totalDelta <= -sensitivity) {
                            flag = true;
                            totalDelta = 0;
                            dateTime = dateTime.subtract(const Duration(hours: 1));
                            if (dateTime.millisecond != 0) {
                              dateTime = dateTime.add(const Duration(hours: 1));
                              dateTime = dateTime.subtract(Duration(minutes: dateTime.minute, milliseconds: dateTime.millisecond, microseconds: dateTime.microsecond));
                            }
                          }
                          if (flag) {
                            HapticFeedback.lightImpact();
                            setState(() {
                              totalDelta = 0;
                            });
                          }
                        },
                        onPanEnd: (details) async {
                          int sensitivity = 1000;
                          int animationMs = 25;
                          if (dateTime.millisecond != 0) {
                            dateTime = dateTime.subtract(Duration(minutes: dateTime.minute, milliseconds: dateTime.millisecond, microseconds: dateTime.microsecond));
                          }
                          if (details.velocity.pixelsPerSecond.dx > sensitivity) {
                            DateTime target = DateTime(dateTime.year, dateTime.month, dateTime.day, 6);
                            target = target.add(const Duration(days: 1));
                            int diff = target.difference(dateTime).inHours.abs();
                            for (int x = 0; x <= diff; x++) {
                              await Future.delayed(Duration(milliseconds: animationMs));
                              dateTime = dateTime.add(const Duration(hours: 1));
                              setState(() {});
                            }
                          }

                          if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
                            DateTime target = DateTime(dateTime.year, dateTime.month, dateTime.day, 6);
                            target = target.subtract(const Duration(days: 1));
                            int diff = target.difference(dateTime).inHours.abs();
                            for (int x = 0; x < diff; x++) {
                              await Future.delayed(Duration(milliseconds: animationMs));
                              dateTime = dateTime.subtract(const Duration(hours: 1));
                              setState(() {});
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: 400,
                          decoration: BoxDecoration(
                              border: Border.all(width: 0, color: Colors.transparent),
                              boxShadow: widget.showShadow?const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 0)
                                ),
                              ]:null,
                              borderRadius: const BorderRadius.all(Radius.circular(20))
                          ),
                          child: Container(
                            child: Container(
                              width: 300,
                              height: 116,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 70),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(getWeather()!.getIcon(), color: Colors.white, size: 16, shadows: [shadow]),
                                          Container(width: 5),
                                          Text(getWeather()!.getReadableType(), style: TextStyle(fontSize:14, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow]),)
                                        ],
                                      ),
                                      Text(getWeather()!.getReadableTemp(), style: TextStyle(fontSize:42, color: Colors.white, shadows: [shadow], ))
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(getTime(), style: TextStyle(fontSize:22, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow])),
                                      Text(Jiffy(getWeather()!.dateTime).format('MMM, dd yyyy'), style: TextStyle(fontSize:12, color: Colors.white, shadows: [shadow])),
                                      Text(getWeather()!.country, style: TextStyle(fontSize:13, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow])),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                  )
              ),
            ),
            widget.child==null?Container():widget.child!,
          ],
        ),
      ),
    );
  }

  Widget weatherAnimation({required Widget child}) {
    if (getWeather() == null) {
      return Container();
    }
    switch (getWeather()!.type) {
      case WeatherType.rainy: case WeatherType.heavyRainy: return ParallaxRain(
        distanceBetweenLayers: 0.7,
        numberOfDrops: getWeather()!.type == WeatherType.rainy?200:300 ,
        dropWidth: 0.15,
        dropHeight: 10,
        dropColors: const  [Color.fromRGBO(40, 97, 145, 1.0)],
        dropFallSpeed: 3,
        trail: true,
        rainIsInBackground: false,
        child: child,
      );
      case WeatherType.snowy: return SnowfallWidget(

        alpha: 75,
        child: child
      );
    }
    return child;
  }

  Weather? getWeather() => WeatherService.getWeather(dateTime);

  String getDate() {
     late String d, m, y;
    d = dateTime.day.toString();
    m = dateTime.month.toString();
    y = dateTime.year.toString();
    if (d.length == 1) { d = '0$d'; }
    if (m.length == 1) { m = '0$m'; }
    return '$d/$m/$y';
  }

  String getTime() {
    late String m, h;
    m = dateTime.minute.toString();
    h = dateTime.hour.toString();
    if (m.length == 1) { m = '0$m'; }
    if (h.length == 1) { h = '0$h'; }
    return '$h:$m';
  }
}