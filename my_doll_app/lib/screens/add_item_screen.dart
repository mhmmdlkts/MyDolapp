import 'dart:convert';
import 'dart:typed_data';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/system_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:palette_generator/palette_generator.dart';

class AddItemScreen extends StatefulWidget {
  final Wardrobe wardrobe;
  const AddItemScreen({required this.wardrobe, super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> with WidgetsBindingObserver {

  Item item = Item();
  Uint8List? img;
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  bool _isUploading = false;
  Color? color;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      readImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(SystemService.isSupportingIsolateImage);
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Column(
        children: [
          CustomRadioButton(
            elevation: 0,
            unSelectedColor: Theme.of(context).canvasColor,
            buttonLables: ItemType.values.map(ItemTypeService.enumToReadableString).toList(),
            buttonValues: ItemType.values.map(ItemTypeService.enumToString).toList(),
            defaultSelected: ItemTypeService.enumToString(ItemTypeService.defaultItem),
            radioButtonValue: (value) {
              setState(() {
                item.type = ItemTypeService.stringToEnum(value);
              });
            },
            selectedColor: Theme.of(context).colorScheme.secondary,
          ),
          ItemOnAvatarWidget(
            showMannequin: true,
            movableItem: img,
            onMatrixUpdate: (Matrix4 m) {
              item.matrix = m;
            },
          ),
          Container(
            color: color==null?Colors.transparent:color,
            width: 400,
            height: 50,
          ),
          _isUploading?const CircularProgressIndicator():ElevatedButton(
            onPressed: () async {
              setState(() {
                _isUploading = true;
              });
              final base64String = base64.encode(img!);
              item.base64 = base64String;
              WardrobeService.addItem(widget.wardrobe, item).then((value) => {
                Navigator.pop(context, item)
              });
            },
            child: const Text('Add')
          )
        ],
      ),
    );
  }

  Future<void> readImages() async {
    final Uint8List? imageBytes = await Pasteboard.image;
    if (imageBytes == null) {
      return;
    }
    color = await getImagePalette(Image.memory(imageBytes).image);
    setState(() {
      img = imageBytes;
    });
  }

  Future<Color> getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color??Colors.transparent;
  }
}