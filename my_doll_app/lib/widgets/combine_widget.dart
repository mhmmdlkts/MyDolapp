import 'package:flutter/material.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:widget_mask/widget_mask.dart';

class CombineWidget extends StatefulWidget {
  final double? width;
  final double? height;
  final Combine? combine;

  CombineWidget({this.combine, this.width, this.height, super.key}) : assert((height == null && width != null) || (height != null && width == null) ) {
    if (width == null && height == null) {
      width == 200;
    }
  }

  @override
  _CombineWidgetState createState() => _CombineWidgetState();
}

class _CombineWidgetState extends State<CombineWidget> {

  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
  }

  resize() {
    if (widget.width != null) {
      _width = widget.width!;
      _height = ItemOnAvatarWidget.originalItemHeight*(_width/ItemOnAvatarWidget.originalItemWidth);
    } else if (widget.height != null) {
      _height = widget.height!;
      _width = ItemOnAvatarWidget.originalItemWidth*(_height/ItemOnAvatarWidget.originalItemHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    resize();
    return Container(
      child: SizedBox(
        width: _width,
        height: _height,
        child: widget.combine==null?Container():_showCombine(widget.combine!)
      ),
    );
  }

  Widget _showCombine(Combine combine) => Stack(
      children: widget.combine!.items?.map((e) => SizedBox(
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