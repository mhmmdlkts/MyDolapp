
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/person.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/combine_service.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:widget_mask/widget_mask.dart';

import '../decorations.dart';

class ItemWidget extends StatefulWidget {
  final Item item;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  ItemWidget({required this.item, this.onPressed, this.onLongPressed, super.key});

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: widget.onPressed,
          onLongPress: widget.onLongPressed,
          child: Container(
            width: 150,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: shadowOffset,
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 80,
                        width: 115,
                        decoration: BoxDecoration(
                          color: (widget.item.color??Colors.black).withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child: _widgetWithShadow(widget.item.images!.thumb_600!),
                      ),
                    ],
                  ),
                ),
                Text(ItemTypeService.enumToReadableString(widget.item.type), style: TextStyle(fontWeight: FontWeight.bold),),
                // Container(color: item.color, height: 18 )
              ],
            ),
          )
        ),
      ),
    );
  }


  Widget _widgetWithShadow(Uint8List img) => SimpleShadow(
    offset: shadowOffset,
    sigma: 4,
    child: Image.memory(img),
  );
}