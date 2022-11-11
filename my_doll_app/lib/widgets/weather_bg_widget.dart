import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:my_doll_app/widgets/sun_moon_widget.dart';
import 'package:parallax_rain/parallax_rain.dart';
import 'package:snowfall/snowfall.dart';
import 'package:flutter/services.dart';

import '../models/weather.dart';

class WeatherBgWidget extends StatefulWidget {
  final Widget? child;
  final Weather? weather;
  final bool showShadow;

  const WeatherBgWidget({this.child, this.weather, this.showShadow = false, super.key});

  @override
  _WeatherBgWidgetState createState() => _WeatherBgWidgetState();
}

class _WeatherBgWidgetState extends State<WeatherBgWidget> {

  DateTime now = DateTime.now();
  int i = 0;
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

  void doIt() async { // TODO DELETE me
    Future.delayed(Duration(milliseconds: 150)).then((value) => {
      setState(() {
        now = DateTime(now.year,now.month,now.day,i,now.minute);
        i = (i + 1)%24;
      }),
      doIt()
    });
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
        image: widget.weather!=null?DecorationImage(
          image: widget.weather!.getImage(),
          fit: BoxFit.fill,
        ):null,
      ),
      child: Container(
        constraints: const BoxConstraints.expand(),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(Weather.isDay(now.hour)?0:0.6),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Opacity(
                opacity: 0.7,
                child: SunMoonWidget(time: now),
              ),
            ),
            widget.weather==null?Container():weatherAnimation(
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
                            now = now.add(const Duration(hours: 1));
                            if (now.millisecond != 0) {
                              now = now.subtract(Duration(minutes: now.minute, milliseconds: now.millisecond, microseconds: now.microsecond));
                            }
                          }
                          if (totalDelta <= -sensitivity) {
                            flag = true;
                            totalDelta = 0;
                            now = now.subtract(const Duration(hours: 1));
                            if (now.millisecond != 0) {
                              now = now.add(const Duration(hours: 1));
                              now = now.subtract(Duration(minutes: now.minute, milliseconds: now.millisecond, microseconds: now.microsecond));
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
                          if (now.millisecond != 0) {
                            now = now.subtract(Duration(minutes: now.minute, milliseconds: now.millisecond, microseconds: now.microsecond));
                          }
                          if (details.velocity.pixelsPerSecond.dx > sensitivity) {
                            DateTime target = DateTime(now.year, now.month, now.day, 6);
                            target = target.add(const Duration(days: 1));
                            int diff = target.difference(now).inHours.abs();
                            for (int x = 0; x <= diff; x++) {
                              await Future.delayed(Duration(milliseconds: animationMs));
                              now = now.add(const Duration(hours: 1));
                              setState(() {});
                            }
                          }

                          if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
                            DateTime target = DateTime(now.year, now.month, now.day, 6);
                            target = target.subtract(const Duration(days: 1));
                            int diff = target.difference(now).inHours.abs();
                            for (int x = 0; x < diff; x++) {
                              await Future.delayed(Duration(milliseconds: animationMs));
                              now = now.subtract(const Duration(hours: 1));
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
                                          Icon(widget.weather!.getIcon(), color: Colors.white, size: 16, shadows: [shadow]),
                                          Container(width: 5),
                                          Text(widget.weather!.getReadableType(), style: TextStyle(fontSize:14, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow]),)
                                        ],
                                      ),
                                      Text(widget.weather!.getReadableTemp(), style: TextStyle(fontSize:42, color: Colors.white, shadows: [shadow], ))
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(getTime(), style: TextStyle(fontSize:22, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow])),
                                      Text(Jiffy(widget.weather!.dateTime).format('MMM, dd yyyy'), style: TextStyle(fontSize:12, color: Colors.white, shadows: [shadow])),
                                      Text(widget.weather!.country, style: TextStyle(fontSize:13, color: Colors.white, fontWeight: FontWeight.bold, shadows: [shadow])),
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
    if (widget.weather == null) {
      return Container();
    }
    switch (widget.weather!.type) {
      case WeatherType.rainy: case WeatherType.heavyRainy: return ParallaxRain(
        distanceBetweenLayers: 0.7,
        numberOfDrops: widget.weather!.type == WeatherType.rainy?200:300 ,
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

  String getDate() {
     late String d, m, y;
    d = now.day.toString();
    m = now.month.toString();
    y = now.year.toString();
    if (d.length == 1) { d = '0$d'; }
    if (m.length == 1) { m = '0$m'; }
    return '$d/$m/$y';
  }

  String getTime() {
    late String m, h;
    m = now.minute.toString();
    h = now.hour.toString();
    if (m.length == 1) { m = '0$m'; }
    if (h.length == 1) { h = '0$h'; }
    return '$h:$m';
  }
}