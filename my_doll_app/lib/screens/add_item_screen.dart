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

class AddItemScreen extends StatefulWidget {
  final Wardrobe wardrobe;
  const AddItemScreen({required this.wardrobe, super.key});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> with WidgetsBindingObserver {

  Uint8List? img;
  Uint8List? foundImg;
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity()); // TODO Maybe delete me
  bool _isUploading = false;
  bool? _willChoseFromGallery;
  Color? color;
  ItemType? itemType;
  final BorderRadius _borderRadius = BorderRadius.all(Radius.circular(5));
  CameraController? controller;
  bool takePicturePressed = false;
  bool isCropDone = false;
  Matrix4 matrix = Matrix4.identity();

  @override
  void initState() {
    super.initState();
    if (SystemService.isSupportingIsolateImage) {
      _willChoseFromGallery = true;
      _willChoseFromGallery = true;
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && SystemService.isSupportingIsolateImage && _getStep() == 3) {
      readImages();
    }

    if (!isCameraInited()) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      controller == null;
    } else if (state == AppLifecycleState.resumed) {
      // onNewCameraSelected(cameraController.description);
    }
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
                    onPressed: _stepDown,
                    icon: Icon(Icons.arrow_back_ios)
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _getContent(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future initializeCamera() async {
    controller = CameraController(
        CameraService.cameras[0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420
    );
    controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      print(e);
    });
  }

  Future upload () async {
    if (_isUploading) {
      return;
    }
    setState(() {
      _isUploading = true;
    });
    final base64String = base64.encode(img!);
    Item item = Item(type: itemType!, base64: base64String, matrix: matrix);
    item.color = await getImagePalette(Image.memory(img!).image);
    WardrobeService.addItem(widget.wardrobe, item).then((value) => {
      item.id = value,
      Navigator.of(context).pop(item)
    });
  }

  Future readImages() async {
    final Uint8List? imageBytes = await Pasteboard.image;
    if (imageBytes == null) {
      return;
    }
    setState(() {
      foundImg = imageBytes;
    });
  }

  Future<Color> getImagePalette (ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator
        .fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color??Colors.transparent;
  }

  Widget _avatarPositionStep() => Column(
    children: [
      ItemOnAvatarWidget(
        showMannequin: true,
        movableItem: img,
        onMatrixUpdate: (Matrix4 m) {
          matrix = m;
        },
      ),
      Container(height: 40,),
      _getConfirmButton()
    ],
  );

  Widget _getConfirmButton() {
    if (_isUploading) {
      return CircularProgressIndicator();
    }
    return ElevatedButton(onPressed: () {
      upload();
    }, child: Container(
      padding: EdgeInsets.all(20),
      child: Text('Confirm'),
    ));
  }

  Widget _itemTypeStep() {
    List<ItemType> list = ItemType.values.toList();
    double spacing = 30;
   return Expanded(
     child: Center(
       child: ListView(
         shrinkWrap: true,
         children: [
           Container(
             padding: EdgeInsets.all(spacing),
             child: Wrap(
               alignment: WrapAlignment.center,
               runSpacing: spacing,
               spacing: spacing,
               children: list.map((e) => _getPhotoGalleryButtons(onPressed: () => setState((){
                 itemType = e;
               }), child: Center(
                 child: Text(ItemTypeService.enumToReadableString(e)),
               ))).toList(),
             ),
           )
         ],
       ),
     ),
   );
  }

  Widget _getContent() {
    switch(_getStep()) {
      case 0: return _itemTypeStep();
      case 1: return _cameraOrGalleryStep();
      case 2: return _willChoseFromGallery!?_choseFromGalleryStep():_takePictureStep();
      case 3:
        if (_willChoseFromGallery! && SystemService.isSupportingIsolateImage && foundImg == null) {
          readImages();
        }
        return _choseFromGalleryStepForSupportedIos();
      case 4: return _cropPhotoScreen();
      case 5: return _avatarPositionStep();
    }
    return Container();
  }

  int _getStep() {
    if (itemType == null) {
      return 0;
    }

    if (_willChoseFromGallery == null) {
      return 1;
    }

    if (img == null) {
      return !_willChoseFromGallery! || !SystemService.isSupportingIsolateImage?
      2:3;
    }
    /* // TODO Remove me with vsl
    if (!isCropDone) {
      return 4;
    }*/

    return 5;
  }

  void _stepDown() {
    int step = _getStep();
    print(step);
    switch (step) {
      case 5:
        isCropDone = false;
        img = null; // TODO Remove me with vsl
        break;
      case 4:
        img = null;
        if (!_willChoseFromGallery!) {
          initializeCamera();
        }
        break;
      case 3:
        continue a; a:
      case 2:
        if (!_willChoseFromGallery!) {
          controller?.dispose();
          controller == null;
        }
        _willChoseFromGallery = null;
        break;
      case 1:
        itemType = null;
        break;
      case 0:
        Navigator.of(context).pop(null);
        return;
    }
    setState(() {});
  }

  Widget _choseFromGalleryStep() {
    return Text('TO DO');
  }

  Widget _choseFromGalleryStepForSupportedIos() {
    double spacing = 20;
    return Container(
      margin: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            ],
          ),
          _appIconWidget('assets/images/helper/ios_camera_app_icon.webp'),
          Container(height: spacing,),
          Icon(Icons.arrow_circle_down, size: 30,),
          Container(height: spacing,),
          _appIconWidget('assets/images/helper/ios_photos_app_icon.webp'),
          Container(height: spacing,),

          Icon(Icons.arrow_circle_down, size: 30,),
          Container(height: spacing,),
          Container(
            child: Image.asset('assets/images/helper/gif/isolate_helper.gif'),
            width: 200,
          ),
          Container(height: spacing,),
          foundImg==null?Container():Column(
            children: [
              Icon(Icons.arrow_circle_down, size: 30,),
              Container(height: spacing,),
              ShakeWidget(
                  duration: Duration(seconds: 3),
                  shakeConstant: ShakeRotateConstant2(),
                  autoPlay: true,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: _borderRadius,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    width: 150,
                    height: 150,
                    child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: _borderRadius,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Image.memory(foundImg!),
                          ),
                          onTap: () {
                            setState(() {
                              img = foundImg;
                            });
                          },
                        )
                    ),
                  )
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _appIconWidget(String path) {
    final BorderRadius _borderRadiusAppIcon = BorderRadius.all(Radius.circular(18));
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _borderRadiusAppIcon,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _borderRadiusAppIcon,
        child: Image.asset(path),
      ),
    );
  }

  Widget _cameraOrGalleryStep() => Container(
    padding: EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _getPhotoGalleryButtons(onPressed: () async {
          await initializeCamera();
          setState((){
            _willChoseFromGallery = false;
          });
        }, disabled: CameraService.hasNoCamera(), child: Icon(Icons.photo_camera, size: 40,),size: (MediaQuery.of(context).size.width / 2) - 100),
        _getPhotoGalleryButtons(onPressed: () async {
          if (!SystemService.isSupportingIsolateImage) {
            final ImagePicker _picker = ImagePicker();
            final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              img = await image!.readAsBytes();
            }
          }
          setState((){
            _willChoseFromGallery = true;
          });
          // Capture a photo
          // final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
        }, child: Icon(Icons.photo_library, size: 40,), size: (MediaQuery.of(context).size.width / 2) - 100, recommended: SystemService.isSupportingIsolateImage),
      ],
    ),
  );

  Widget _getPhotoGalleryButtons({required VoidCallback onPressed, required Widget child, double size = 100, bool disabled = false, bool recommended = false}) {
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
          Opacity(
            opacity: recommended?1:0,
            child: Container(
              margin: EdgeInsets.only(top: 15),
              height: 40,
              width: size,
              child: Center(
                child: Text('Highly recommended', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _takePictureStep() {
    if (CameraService.hasNoCamera() || !isCameraInited()) {
      return Center(child: Text('No Camera'),);
    }
    return CameraPreview(controller!,
      child: Positioned(
        width: MediaQuery.of(context).size.width,
        bottom: 20,
        child:  FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: takePicturePressed?null:() async {
            setState(() {
              controller!.pausePreview();
              takePicturePressed = true;
            });
            XFile? file = await controller!.takePicture();

            img = await file.readAsBytes();
            controller?.dispose();
            controller = null;

            setState(() {
              takePicturePressed = false;
            });
          },
          child: takePicturePressed?CircularProgressIndicator(color: Colors.black,):Icon(Icons.photo_camera, color: Colors.black,),
        ),
      )
    );
  }

  bool isCameraInited() => controller?.value.isInitialized??false;

  Widget _cropPhotoScreen() => InkWell(
    onTap: () {
      setState(() {
        isCropDone = true;
      });
    },
    child: Image.memory(img!),
  );
}