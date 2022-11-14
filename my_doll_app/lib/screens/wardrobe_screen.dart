import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/screens/add_item_screen.dart';
import 'package:my_doll_app/screens/add_wardrobe_screen.dart';
import 'package:my_doll_app/screens/single_item_screen.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:simple_shadow/simple_shadow.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {


  final PhotoViewController _photoViewController = PhotoViewController();
  final List<ItemType> types = [ItemType.tShirt, ItemType.pants];
  final List<ItemType> openTypes = [ItemType.tShirt, ItemType.pants];
  Wardrobe? wardrobe;

  Offset shadowOffset = Offset(4, 4);
  Color backgroundColor = Colors.black.withOpacity(0.05);

  @override
  void initState() {
    super.initState();
    wardrobe = WardrobeService.getDefaultWardrobe();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: backgroundColor,
          child: SafeArea(
            bottom: false,
            child: wardrobe==null?const Center(child: CircularProgressIndicator()):CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: 150,
                  stretch: true,
                  title: Text('My Wardrobes', style: TextStyle(color: Colors.black)),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: EdgeInsets.only(top: 50),
                      alignment: Alignment.center,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: WardrobeService.wardrobes.length + 1,
                        itemBuilder: (ctx,i) => _changeWardrobeButton(i),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) => _getAllTypes(ItemType.values[index]),
                    childCount: ItemType.values.length,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            child: Icon(Icons.add, color: Colors.black,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemScreen(wardrobe: wardrobe!)),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _getAllTypes(ItemType type) => Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: wardrobe!.itemCount(type: type)! > 0?[
      Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(left: 8, bottom: 10),
        child: Text(ItemTypeService.enumToReadableString(type), style: TextStyle(color: Colors.black, fontSize: 20),),
      ),
        Container(
          margin: EdgeInsets.only(bottom: 50),
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: wardrobe!.itemCount(type: type),
              itemBuilder: (context, index) {
                Item item = (wardrobe!.getItem(index, type: type))!;
                return Container(
                  margin: const EdgeInsets.all(10),
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        openItem(item);
                      },
                      child: _itemWidget(item),
                      onLongPress: () {
                        _showItemDialog(item);
                        print('long');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        )
    ]:[],
  );

  Widget _changeWardrobeButton(int i) {
    bool isAddNewButton = i >= WardrobeService.wardrobes.length;
    Wardrobe? wardrobe;
    if (!isAddNewButton) {
      wardrobe = WardrobeService.wardrobes[i];
    }
    bool isSame = this.wardrobe!.id == (wardrobe?.id??'');
    return Container(
      alignment: Alignment.center,
      // padding: EdgeInsets.only(top: 100),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: SizedBox(
        width: 100,
        child: Center(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(5),
                onTapDown: (details) => _getTapPosition(details),
                onLongPress: () {
                  _showContextMenu(wardrobe!, context);
                },
                onTap: isSame?null:() {
                  setState(() {
                    if (!isAddNewButton) {
                      this.wardrobe = wardrobe;
                      print(wardrobe!.itemCount());
                    } else {
                      _openAddWardrobeScreen();
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Opacity(
                        opacity: wardrobe?.isDefault??true?1:0.7,
                        child: Icon(isAddNewButton?Icons.add:Icons.checkroom, color: Colors.black, size: 35,),
                      ),
                      Text(isAddNewButton?'Add New':wardrobe!.name, style: TextStyle(fontSize: 10, color: Colors.black), textAlign: TextAlign.center),
                    ],
                  ),
                )
              ),

              Opacity(opacity: isSame?1:0, child: Icon(Icons.arrow_drop_down, color: Colors.black,),)
            ],
          ),
        ),
      ),
    );
  }

  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    _tapPosition = referenceBox.globalToLocal(details.globalPosition);
  }

  void _showContextMenu(Wardrobe wardrobe, BuildContext context) async {
    final RenderObject? overlay =
    Overlay.of(context)?.context.findRenderObject();

    final result = await showMenu(
        context: context,

        // Show the context menu at the tap location
        position: RelativeRect.fromRect(
            Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, 30, 30),
            Rect.fromLTWH(0, 0, overlay!.paintBounds.size.width,
                overlay.paintBounds.size.height)),

        // set a list of choices for the context menu
        items: [
          const PopupMenuItem(
            value: 'default',
            child: Text('Set default'),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ]);

    // Implement the logic for each choice here
    switch (result) {
      case 'default':
        _setWardrobeAsDefault(wardrobe: wardrobe);
        break;
      case 'edit':
        _openAddWardrobeScreen(wardrobe: wardrobe);
        break;
      case 'delete':
        _showDeleteWardrobeAlertDialog(wardrobe, context);
        break;
    }
  }

  _showDeleteWardrobeAlertDialog(Wardrobe wardrobe, BuildContext context) async {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed:  () async {
        await WardrobeService.removeWardrobe(wardrobe);
        Navigator.of(context).pop(true);
      },
    );

    bool? val = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Alert Dialog"),
          content: Text("TO DO uyari mersaji hazirla parca sayisi: ${wardrobe.itemCount()} isim: ${wardrobe.name}"),
          actions: [ cancelButton, continueButton ],
        );
      },
    );

    if (val??true) {
      setState(() {});
    }
  }

  Widget _itemWidget(Item item) => Container(
    width: 150,
    height: 220,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(3)),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.15),
          spreadRadius: 2,
          blurRadius: 5,
          offset: shadowOffset,
        ),
      ],
    ),
    child: Column(
      children: [
        SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 80,
                width: 115,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.035),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: _widgetWithShadow(item.images!.thumb_600!),
              ),
            ],
          ),
        ),
        Text(ItemTypeService.enumToReadableString(item.type), style: TextStyle(fontWeight: FontWeight.bold),),
        // Container(color: item.color, height: 18 )
      ],
    ),
  );

  void _showItemDialog(Item item) async {
    ValueNotifier<Uint8List?> notifier = ValueNotifier(null);
    await item.images!.init1200().then((value) {
      notifier.value = item.images!.thumb_1200;
    });

    Size size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () {
          Navigator.pop(context, false);
        },
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  openItem(item);
                },
                child: Container(
                  width: size.width - 30,
                  height: size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: shadowOffset,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipRect(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: notifier.value==null?CircularProgressIndicator():Image.memory(notifier.value!)/*PhotoView(
                          controller: _photoViewController,
                          backgroundDecoration: BoxDecoration(
                            color: Colors.transparent,
                          ),

                          imageProvider: AssetImage(item.images!.thumb_1200!),
                          enableRotation: false,
                          gaplessPlayback: true,
                          onScaleEnd: (ctx, details, value) {
                            _photoViewController.reset();
                          },
                        ),*/
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void openItem(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SingleItemScreen(item: item!)),
    );
  }

  Widget _widgetWithShadow(Uint8List img) => SimpleShadow(
    offset: shadowOffset,
    sigma: 4,
    child: Image.memory(img),
  );

  Future _setWardrobeAsDefault({required Wardrobe wardrobe}) async {
    await WardrobeService.setDefault(wardrobe);
    setState(() { });
  }

  Future _openAddWardrobeScreen({Wardrobe? wardrobe}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddWardrobeScreen(wardrobe: wardrobe)),
    );

    setState(() {});
  }
}