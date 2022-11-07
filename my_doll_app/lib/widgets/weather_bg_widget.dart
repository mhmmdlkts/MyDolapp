
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:my_doll_app/models/item.dart';

import '../models/weather.dart';

class WeatherBgWidget extends StatefulWidget {
  final Widget? child;
  final Weather weather;

  const WeatherBgWidget({this.child, required this.weather, super.key});

  @override
  _WeatherBgWidgetState createState() => _WeatherBgWidgetState();
}

class _WeatherBgWidgetState extends State<WeatherBgWidget> {

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    now = DateTime.now();
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        color: widget.weather.getColor()
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 260,
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(widget.weather.getIcon(), color: Colors.white, size: 16,),
                            Container(width: 5),
                            Text(widget.weather.getReadableType(), style: const TextStyle(fontSize:14, color: Colors.white),)
                          ],
                        ),
                        Container(height: 5),
                        Text(widget.weather.getReadableTemp(), style: const TextStyle(fontSize:42, color: Colors.white),)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTime(), style: const TextStyle(fontSize:22, color: Colors.white)),
                        Container(height: 5),
                        Text(getDate(), style: const TextStyle(fontSize:12, color: Colors.white)),
                        Container(height: 5),
                        Text(widget.weather.country, style: const TextStyle(fontSize:12, color: Colors.white)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ),
          widget.child==null?Container():widget.child!
        ],
      ),
    );
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