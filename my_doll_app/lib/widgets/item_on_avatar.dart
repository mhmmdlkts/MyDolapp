
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
import 'package:my_doll_app/services/person_service.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/avatar_widget.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:clipboard/clipboard.dart';

class ItemOnAvatarWidget extends StatefulWidget {
  final Combine? combine;
  final Uint8List? movableItem;
  final bool showMannequin;
  final bool showShadow;
  final void Function(Matrix4)? onMatrixUpdate;
  final void Function(Item)? onItemClicked;
  final VoidCallback? onRefreshClicked;

  const ItemOnAvatarWidget({this.combine, this.movableItem, this.onMatrixUpdate, this.onItemClicked, this.onRefreshClicked, this.showMannequin = false, this.showShadow = false, super.key});

  @override
  _ItemOnAvatarWidgetState createState() => _ItemOnAvatarWidgetState();
}

class _ItemOnAvatarWidgetState extends State<ItemOnAvatarWidget> {

  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  final double _width = 400;
  final double _height = 500;
  int position = 0;
  double val = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      height: _height,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(width: 0, color: Colors.transparent),
            boxShadow: widget.showShadow? const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
              ),
            ]:null,
            borderRadius: const BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: _width,
                  height: _height,
                  child: widget.showMannequin?AvatarWidget(_width, _height, gender: PersonService.person.gender??Gender.female):Container(),
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
                widget.onRefreshClicked==null?Container():Positioned(
                  bottom: 10,
                  right: 10,
                  child: FloatingActionButton(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.refresh, color: Colors.white,),
                    onPressed: () => widget.onRefreshClicked!.call(),
                  )
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showItems(Item item) => SizedBox(
    width: _width,
    height: _height,
    child: Transform(
      transform: item.matrix,
      child: InkWell(
        onTap: widget.onItemClicked==null?null: () => widget.onItemClicked!.call(item),
        child: item.links?.thumb_600!=null?Image.network(item.links!.thumb_600!):Container()
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
          child: widget.movableItem!=null?SizedBox(
            child: Image.memory(widget.movableItem!),
          ):Container(),
        );
      },
    ),
  );
}