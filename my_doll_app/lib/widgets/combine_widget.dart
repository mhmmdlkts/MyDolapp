
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
import 'package:widget_mask/widget_mask.dart';

class CombineWidget extends StatefulWidget {
  final double width;
  final Combine combine;

  const CombineWidget({required this.combine, this.width = 200, super.key});

  @override
  _CombineWidgetState createState() => _CombineWidgetState();
}

class _CombineWidgetState extends State<CombineWidget> {

  late double _width;
  late double _height;
  int floor = 0;

  @override
  void initState() {
    super.initState();
    _width = widget.width;
    _height = ItemOnAvatarWidget.originalItemHeight*(widget.width/ItemOnAvatarWidget.originalItemWidth);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        width: _width,
        height: _height,
        child: _showCombine(widget.combine)
      ),
    );
  }

  Widget _showCombine(Combine combine) => Stack(
      children: widget.combine!.items[floor]?.map((e) => SizedBox(
        child: Container(
          child: _showItems(e, half: e.type == ItemType.jacket),
        ),
      )).toList()??[]
  );

  Widget _showItems(Item item, {bool half = false}) => SizedBox(
    width: _width,
    height: _height,
    child: Transform(
      transform: item.matrix.resize(dx: ItemOnAvatarWidget.originalItemWidth/_width, dy: ItemOnAvatarWidget.originalItemHeight/_height),
      child: Stack(
        alignment: Alignment.center,
        children: [
          WidgetMask(
            // `BlendMode.difference` results in the negative of `dst` where `src`
            // is fully white. That is why the text is white.
            childSaveLayer: true,
            blendMode: BlendMode.dstOut,
            mask: Container(
                width: _width,
                height: _height,
                child: half?Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: _width /2,
                      height: _height,
                      color: Colors.black,
                    )
                  ],
                ):Container()
            ),
            child: item.images?.thumb_600!=null?Image.memory(item.images!.thumb_600!):Container(),
          ),
        ],
      )
    ),
  );
}