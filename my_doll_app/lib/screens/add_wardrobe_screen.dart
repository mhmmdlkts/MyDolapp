import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/camera_service.dart';
import 'package:my_doll_app/services/system_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';

class AddWardrobeScreen extends StatefulWidget {
  Wardrobe? wardrobe;
  AddWardrobeScreen({this.wardrobe, super.key});

  @override
  _AddWardrobeScreenState createState() => _AddWardrobeScreenState();
}

class _AddWardrobeScreenState extends State<AddWardrobeScreen> {

  final TextEditingController _controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  String wardrobeName = '';
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.wardrobe?.name??'';
    focusNode.requestFocus();
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
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.words,
                        focusNode: focusNode,
                        onChanged: (val) {
                          setState(() {
                            wardrobeName = val.trim();
                          });
                        },
                      )
                    ),
                    _getConfirmButton()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  Widget _getConfirmButton() {
    if (_isUploading) {
      return CircularProgressIndicator();
    }
    return ElevatedButton(onPressed: (widget.wardrobe?.name??'')==wardrobeName||wardrobeName.length<3?null:() {
        if (_isCreating()) {
          _confirm();
        } else {
          _update();
        }
      },
      child: Container(
        padding: EdgeInsets.all(20),
        child: Text(_isCreating()?'Create':'Update'),
      )
    );
  }

  Future _update() async {
    setState(() {
      _isUploading = true;
    });
    widget.wardrobe!.name = wardrobeName;
    await WardrobeService.updateWardrobe(widget.wardrobe!);
    Navigator.of(context).pop(widget.wardrobe);
  }

  Future _confirm() async {
    setState(() {
      _isUploading = true;
    });
    Wardrobe wardrobe = Wardrobe(name: wardrobeName);
    await WardrobeService.createWardrobe(wardrobe);
    Navigator.of(context).pop(wardrobe);
  }

  bool _isCreating() => widget.wardrobe == null;
}