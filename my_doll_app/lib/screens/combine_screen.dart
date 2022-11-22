import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:my_doll_app/decorations.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/services/combine_service.dart';
import 'package:my_doll_app/widgets/combine_widget.dart';

class CombineScreen extends StatefulWidget {
  const CombineScreen({super.key});

  @override
  _CombineScreenState createState() => _CombineScreenState();
}

class _CombineScreenState extends State<CombineScreen> with WidgetsBindingObserver {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: _getDateTimeWidgetChildren(CombineService.combinesByDate, howMuchInRow: 3, padding: 15),
      ),
    );
  }

  Widget _getDateTimeWidgetChildren (Map map, {int howMuchInRow = 3, double padding = 10}) {
    DateTime dateTime = DateTime.now();
    return ListView(
      children: [
        _getAllMonthChildren(map, month: dateTime.month-1, year: dateTime.year, howMuchInRow: howMuchInRow, padding: padding),
        _getAllMonthChildren(map, month: dateTime.month, year: dateTime.year, howMuchInRow: howMuchInRow, padding: padding)
      ],
    );
  }

  Widget _getAllMonthChildren(Map map, {required int month, required int year, int howMuchInRow = 3, double padding = 10}) {
    double width = MediaQuery.of(context).size.width - (howMuchInRow+1) * padding;
    List<Widget> list = [];
    List<DateTime> monthList = [];
    DateTime date = DateTime(year, month, 1);
    while (date.month == month) {
      monthList.add(date);
      date = date.add(Duration(days: 1));
    }
    Map<DateTime, Combine> subMap = {};
    map.forEach((key, value) {
      if (key.month == month) {
        subMap.addAll({key: value});
      }
    });
    for (DateTime date in monthList) {
      List<Combine?> combines = [];
      subMap.forEach((key, value) {
        if (key.month == date.month && key.day == date.day) {
          combines.add(value);
        }
      });
      if (combines.isEmpty) {
        combines.add(null);
      }
      for (var combine in combines) {
        list.add(_getDateTimeWidget(dateTime: date, combine: combine, width: width/howMuchInRow));
      }
    }
    /*map.forEach((key, value) {
      list.add(_getDateTimeWidget(dateTime: key, combine: value, width: width/howMuchInRow));
    });*/
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding - 0.5, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Divider(thickness: 1, color: Colors.black),
          Text(Jiffy(monthList.first).format('MMMM yyyy'), style: TextStyle(fontSize: 18),),
          Container(height: 20),
          Wrap(
            runSpacing: padding,
            spacing: padding,
            children: list,
          )
        ],
      ),
    );
  }

  Widget _getDateTimeWidget ({Combine? combine, required DateTime dateTime, required double width}) => Container(

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(3)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(4, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CombineWidget(combine: combine, width: width),
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 5),
          child: Text(Jiffy(dateTime).format('MMM, dd')),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(Jiffy(dateTime).format('EEEE'), style: dateTime.weekday>5?TextStyle(color: Colors.red):null),
        ),
      ],
    ),
  );
}