
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/person.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';

class AvatarWidget extends StatefulWidget {
  final double width;
  final double height;
  final Gender gender;
  final Color color;

  const AvatarWidget(this.width, this.height, {this.gender = Gender.male, this.color = Colors.red, super.key});

  @override
  _AvatarWidgetState createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        getImagePart(widget.gender, 'white', color: Color.fromARGB(
            255, 190, 133, 111)),
        getImagePart(widget.gender, 'hair', color: Color.fromARGB(
            255, 33, 26, 25)),
        getImagePart(widget.gender, 'underwear', color: Color.fromARGB(
            255, 255, 255, 255)),
        getImagePart(widget.gender, 'outline'),
      ],
    );
  }

  Widget getImagePart2(Gender gender, String imageName, {Color color = Colors.white}) =>
      Image.asset('assets/images/avatar/${Person.getStringFromGender(gender)}_$imageName.png');

  Widget getImagePart(Gender gender, String imageName, {Color color = Colors.white}) => Container(
    width: widget.width,
    height: widget.height,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('assets/images/avatar/${Person.getStringFromGender(gender)}_$imageName.png'),
        colorFilter: ColorFilter.mode(color, BlendMode.modulate),
      ),
    ),
  );

}