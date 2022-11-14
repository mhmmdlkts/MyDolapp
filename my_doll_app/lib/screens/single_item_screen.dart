
import 'dart:convert';
import 'dart:typed_data';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:image_painter/image_painter.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:palette_generator/palette_generator.dart';

class SingleItemScreen extends StatefulWidget {
  final Item item;
  const SingleItemScreen({required this.item, super.key});

  @override
  _SingleItemScreenState createState() => _SingleItemScreenState();
}

class _SingleItemScreenState extends State<SingleItemScreen> with WidgetsBindingObserver {
  
  final _imageKey = GlobalKey<ImagePainterState>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ItemTypeService.enumToReadableString(widget.item.type))),
      body: ImagePainter.network(
        widget.item.links!.thumb_1200!,
        key: _imageKey,
        scalable: true,
        initialPaintMode: PaintMode.freeStyle,
      ),
    );
  }
}