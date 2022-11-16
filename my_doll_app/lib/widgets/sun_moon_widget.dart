import 'package:flutter/material.dart';

import 'dart:math';

import 'package:my_doll_app/models/weather.dart';

class SunMoonWidget extends StatelessWidget {
  static const sunMoonWidth = 130.0;

  double mapRange(
      double value,
      double iMin,
      double iMax, [
        double oMin = 0,
        double oMax = 1,
      ]) {
    return ((value - iMin) * (oMax - oMin)) / (iMax - iMin) + oMin;
  }

  final DateTime time;
  final Weather? weather;
  const SunMoonWidget({
    Key? key,
    required this.time,
    this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hour = time.hour;

    final displace = mapRange(time.hour * 1.0, 0, 23);

    return AnimatedContainer(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      duration: const Duration(seconds: 1),
      height: 150,
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.round() - sunMoonWidth;
          final top = sin(pi * displace) * 1.8;
          final left = maxWidth * displace;
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedPositioned(
                curve: Curves.ease,
                bottom: top * 20,
                left: left,
                duration: const Duration(milliseconds: 200),
                child: SizedBox(
                  width: sunMoonWidth,
                  child: AnimatedSwitcher(
                    switchInCurve: Curves.ease,
                    switchOutCurve: Curves.ease,
                    duration: const Duration(milliseconds: 250),
                    child: weather?.isDay(hour)??Weather.isDayStatic(hour)? Container(
                        key: const ValueKey(1),
                        child: const Image(
                          image: AssetImage( "assets/images/weather/sun.png"),
                        ))
                        : Container(
                      key: const ValueKey(2),
                      child: const Image(
                        image: AssetImage("assets/images/weather/moon.png"),
                      ),
                    ),
                    transitionBuilder: (child, anim) {
                      return ScaleTransition(
                        scale: anim,
                        child: FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: anim.drive(
                              Tween(
                                begin: const Offset(0, 4),
                                end: const Offset(0, 0),
                              ),
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}