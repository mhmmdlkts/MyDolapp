import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/person.dart';
import 'package:my_doll_app/services/person_service.dart';
import 'package:my_doll_app/widgets/avatar_widget.dart';

import 'combine_widget.dart';

class ItemOnAvatarWidget extends StatefulWidget {
  static const double originalItemWidth = 400;
  static const double originalItemHeight = 500;
  final Combine? combine;
  final Uint8List? movableItem;
  final bool showMannequin;
  final bool showShadow;
  final void Function(Matrix4)? onMatrixUpdate;
  final void Function(Item)? onItemClicked;
  final VoidCallback? onRefreshClicked;
  final VoidCallback? onAcceptClicked;

  const ItemOnAvatarWidget({this.combine, this.movableItem, this.onMatrixUpdate, this.onItemClicked, this.onRefreshClicked, this.onAcceptClicked, this.showMannequin = false, this.showShadow = false, super.key});

  @override
  _ItemOnAvatarWidgetState createState() => _ItemOnAvatarWidgetState();
}

class _ItemOnAvatarWidgetState extends State<ItemOnAvatarWidget> {

  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  int position = 0;
  double val = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ItemOnAvatarWidget.originalItemWidth,
      height: ItemOnAvatarWidget.originalItemHeight,
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
                  width: ItemOnAvatarWidget.originalItemWidth,
                  height: ItemOnAvatarWidget.originalItemHeight,
                  child: widget.showMannequin?AvatarWidget(ItemOnAvatarWidget.originalItemWidth, ItemOnAvatarWidget.originalItemHeight, gender: PersonService.person.gender??Gender.female):Container(),
                ),
                widget.combine!=null?CombineWidget(width: ItemOnAvatarWidget.originalItemWidth, combine: widget.combine):Container(),
                widget.movableItem!=null?SizedBox(
                  width: ItemOnAvatarWidget.originalItemWidth,
                  height: ItemOnAvatarWidget.originalItemHeight,
                  child: _movableObjectWidget(),
                ):Container(),
                Positioned(
                    bottom: 10,
                    right: 10,
                    child: Column(
                      children: [
                        if(widget.onAcceptClicked != null)
                          FloatingActionButton(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.done, color: Colors.white,),
                            onPressed: widget.onAcceptClicked
                          ),
                        Container(height: 10,),
                        if (widget.onRefreshClicked!=null)
                          FloatingActionButton(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.refresh, color: Colors.white,),
                            onPressed: () => widget.onRefreshClicked!.call(),
                          )
                      ],
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _showItems(Item item) => SizedBox(
    width: ItemOnAvatarWidget.originalItemWidth,
    height: ItemOnAvatarWidget.originalItemHeight,
    child: Transform(
      transform: item.matrix,//.resize(ItemOnAvatarWidget.originalItemHeight/width, ItemOnAvatarWidget.originalItemHeight/height),
      child: InkWell(
        onTap: widget.onItemClicked==null?null: () => widget.onItemClicked!.call(item),
        child: item.images?.thumb_600!=null?Image.memory(item.images!.thumb_600!):Container()
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