
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
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';

class ItemOnAvatarWidget extends StatefulWidget {
  final Combine? combine;
  final Uint8List? movableItem;
  final bool showMannequin;
  final void Function(Matrix4)? onMatrixUpdate;
  final void Function(Item)? onItemClicked;

  const ItemOnAvatarWidget({this.combine, this.movableItem, this.onMatrixUpdate, this.onItemClicked, this.showMannequin = false, super.key});

  @override
  _ItemOnAvatarWidgetState createState() => _ItemOnAvatarWidgetState();
}

class _ItemOnAvatarWidgetState extends State<ItemOnAvatarWidget> {

  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  final double _width = 400;
  final double _height = 500;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: _width,
          height: _height,
          child: widget.showMannequin?Image.asset('assets/images/test_avatar.png'):Container(),
        ),
        widget.combine!=null?Stack(
          children: widget.combine!.items.map((e) => SizedBox(
            child: _showItems(e),
          )).toList()
        ):Container(),
        widget.movableItem!=null?SizedBox(
          width: _width,
          height: _height,
          child: _movableObjectWidget(),
        ):Container(),
      ],
    );
  }

  Widget _showItems(Item item) => SizedBox(
    width: _width,
    height: _height,
    child: Transform(
      transform: item.matrix,
      child: InkWell(
        onTap: widget.onItemClicked==null?null: () => widget.onItemClicked!.call(item),
        child: item.links.thumb_600!=null?Image.network(item.links.thumb_600!):Container()
      ),
    ),
  );

  Widget _movableObjectWidget() => MatrixGestureDetector (
    onMatrixUpdate: (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
      if (widget.movableItem != null) {
        notifier.value = m;

        widget.onMatrixUpdate?.call(m);
      }
    },
    child: AnimatedBuilder (
      animation: notifier,
      builder: (context, child) {
        return Transform(
          transform: notifier.value,
          child: widget.movableItem!=null?Image.memory(widget.movableItem!):Container(),
        );
      },
    ),
  );
}