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

  ScrollController controller = ScrollController();
  DateTime now = DateTime.now();
  List<DateTime> loadedDates = [];

  @override
  void initState() {
    super.initState();
    loadedDates.add(now);
    loadedDates.add(addMonth(now, -1));
    controller.addListener(_scrollListener);
  }

  DateTime addMonth(DateTime dateTime, int i) {
    int year = dateTime.year;
    int month = dateTime.month + i;
    if (month <= 0) {
      year -= ((month.abs()+1)/12).ceil();
      month = 12 - (month.abs()%12);
    } else if (month > 12) {
      year += (month.abs()/12).floor();
      month = month.abs()%12;
    }
    return DateTime(year, month);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: _getDateTimeWidgetChildren(CombineService.combinesByDate, howMuchInRow: 4, padding: 15),
      ),
    );
  }

  void _scrollListener() {
    if (controller.position.extentAfter < 500) {
      setState(() {
        loadedDates.add(addMonth(loadedDates.last, -1));
      });
    }
  }

  Widget _getDateTimeWidgetChildren (Map map, {int howMuchInRow = 3, double padding = 10}) {
    return ListView(
      controller: controller,
      reverse: true,
      children: loadedDates.map((e) => _getAllMonthChildren(map, month: e.month, year: e.year, howMuchInRow: howMuchInRow, padding: padding)).toList()
    );
  }

  Widget _getAllMonthChildren(Map map, {required int month, required int year, int howMuchInRow = 3, double padding = 10}) {
    double width = MediaQuery.of(context).size.width - (howMuchInRow+1) * padding;
    List<Widget> list = [];
    List<DateTime> monthList = [];
    DateTime date = DateTime(year, month, 1);
    int c = 0;
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
    Map<int, bool> checkDays = {};
    for (DateTime date in monthList) {
      if ((date.day+c)%howMuchInRow == 1) {
        checkDays.clear();
        for (int i = 0; i < howMuchInRow; i++) {
          checkDays.addAll({date.day+i: false});
        }
      }
      List<Combine?> combines = [];
      subMap.forEach((key, value) {
        if (key.year == date.year && key.month == date.month && key.day == date.day) {
          combines.add(value);
        }
        checkDays.forEach((k, _) {
          if (key.year == date.year && key.month == date.month && key.day == k) {
            checkDays[k] = true;
          }
        });
      });
      if (combines.isEmpty) {
        combines.add(null);
      }
      c += combines.length-1;
      bool isRowCollapsed = true;
      checkDays.forEach((key, value) {
        if (value) {
          isRowCollapsed = false;
        }
      });
      for (var combine in combines) {
        list.add(_getDateTimeWidget(dateTime: date, isCollapsed: isRowCollapsed, combine: combine, width: width/howMuchInRow));
      }
    }
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

  Widget _getDateTimeWidget ({Combine? combine, bool isCollapsed = false, required DateTime dateTime, required double width}) => Material(
    color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      onTap: () {
        print(dateTime);
      },
      child: Container(
        decoration: BoxDecoration(
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
            isCollapsed?Container(width: width,):CombineWidget(combine: combine, width: width),
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
      ),
    ),
  );
}