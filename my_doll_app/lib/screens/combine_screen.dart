import 'package:flutter/material.dart';
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
    return SafeArea(
      child: ListView(
        children: CombineService.combines.map((e) => Container(
          padding: EdgeInsets.all(10),
          child: CombineWidget(combine: e, width: 300),
        )).toList(),
      ),
    );
  }
}