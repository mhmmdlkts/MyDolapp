import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/camera_service.dart';
import 'package:my_doll_app/services/system_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/combine_widget.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:my_doll_app/widgets/item_widget.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class CreateOutfitScreen extends StatefulWidget {
  Combine? combine;
  CreateOutfitScreen({this.combine, super.key});

  @override
  _CreateOutfitScreenState createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {

  final BorderRadius _borderRadius = BorderRadius.all(Radius.circular(5));
  double combineHeight = 250;
  ItemType? itemType;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(systemOverlayStyle:SystemUiOverlayStyle.light),
      ),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              GestureDetector(
                onPanEnd: (details) {
                  setState(() {
                    if (combineHeight == 250) {
                      combineHeight = 450;
                    } else {
                      combineHeight = 250;
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  margin: EdgeInsets.only(bottom: 10),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios)
                          ),
                          Opacity(opacity: 0, child: IconButton(onPressed: null, icon: Icon(Icons.arrow_back_ios)))
                        ],
                      ),
                      CombineWidget(combine: widget.combine, height: combineHeight,),
                    ],
                  ),
                ),
              ),
              Divider(thickness: 1),
              Opacity(
                opacity: itemType==null?0:1,
                child: _backButton(),
              ),
              if(itemType==null)
                _allItemTypes(),
              if (itemType!=null)
                _getItems()
            ],
          ),
        ),
      ),
    );
  }

  Widget _getItems() {
    List<Item> list = WardrobeService.getDefaultWardrobe()?.getAllTypes(itemType!)??[];
    double spacing = 30;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ItemWidget(item: list[index], onPressed: () {
                      setState(() {
                        if (widget.combine!.hasItem(list[index])) {
                          widget.combine!.removeItem(list[index]);
                        } else {
                          widget.combine!.replaceWith(list[index]);
                        }
                      });
                    }),
                    if (widget.combine!.hasItem(list[index]))
                      Positioned(
                        right: 15,
                        bottom: 15,
                        child: Icon(Icons.done),
                      )
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _allItemTypes() {
    List<ItemType> list = ItemType.values.toList();
    double spacing = 30;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.all(spacing),
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: spacing,
              spacing: spacing,
              children: list.where((element) => WardrobeService.getDefaultWardrobe()?.existItemType(element)??false).map((e) => _getTypesButton(onPressed: () => setState((){
                itemType = e;
              }), child: Center(
                child: Text(ItemTypeService.enumToReadableString(e)),
              ), marginTop: 0)).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _getTypesButton({required VoidCallback onPressed, required Widget child, double size = 100, bool disabled = false, bool recommended = false, double marginTop = 15}) {
    return Opacity(
      opacity: disabled?0.6:1,
      child: Column(
        children: [
          ShakeWidget(
            duration: Duration(seconds: 3),
            shakeConstant: ShakeRotateConstant2(),
            autoPlay: recommended,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: _borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(4,4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: _borderRadius,
                  onTap: disabled?null:onPressed,
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _backButton() => Container(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        IconButton(
            onPressed: itemType==null?null:() {
              setState(() {
                itemType = null;
              });
            },
            icon: Icon(Icons.arrow_back_ios)
        ),
      ],
    ),
  );
}