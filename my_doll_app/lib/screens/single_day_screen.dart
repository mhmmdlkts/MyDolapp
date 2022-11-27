import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/services/cloudfunctions_service.dart';
import 'package:my_doll_app/services/permission_service.dart';
import 'package:my_doll_app/services/person_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ruler_picker_bn/ruler_picker_bn.dart';
import 'package:my_doll_app/models/person.dart';

import '../widgets/stepper.dart';

class SingleDayScreen extends StatefulWidget {
  final DateTime date;
  const SingleDayScreen(this.date, {super.key});

  @override
  _SingleDayScreenState createState() => _SingleDayScreenState();
}

class _SingleDayScreenState extends State<SingleDayScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back_ios)
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.date.toString())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
