import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/screens/add_item_screen.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  _WardrobeScreenState createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {

  final List<ItemType> types = [ItemType.tShirt, ItemType.pants];
  final List<ItemType> openTypes = [ItemType.tShirt, ItemType.pants];
  Wardrobe? wardrobe;

  @override
  void initState() {
    super.initState();
    wardrobe = WardrobeService.getDefaultWardrobe();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: wardrobe==null?const Center(child: CircularProgressIndicator()):Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableListView(
            shrinkWrap: true,
            children: types.map(_getAllTypes).toList(),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex = newIndex - 1;
                }
                final element = types.removeAt(oldIndex);
                types.insert(newIndex, element);
              });
            },
          )
        ],
      ),
    );
      /*floatingActionButton: wardrobe != null? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(wardrobe: wardrobe!)),
          );
        },
      ):null,*/
  }

  Widget _getAllTypes(ItemType type) => Column(
    key: ValueKey(type),
    children: [
      Container(
        color: Colors.brown.withOpacity(0.4),
        child: Column(
          children: [
            Container(
              color: Colors.black45,
              padding: EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ItemTypeService.enumToReadableString(type), style: TextStyle(color: Colors.white),),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              if (openTypes.contains(type)) {
                                openTypes.remove(type);
                              } else {
                                openTypes.add(type);
                              }
                            });
                          },
                          icon: Icon(openTypes.contains(type)?Icons.keyboard_arrow_down:Icons.keyboard_arrow_up, color: Colors.white,)
                      ),
                      const IconButton(
                          onPressed: null,
                          icon: Icon(Icons.reorder, color: Colors.white,)
                      )
                    ],
                  )
                ],
              ),
            ),
            openTypes.contains(type)?SizedBox(
              height: 175,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wardrobe!.itemCount(type: type),
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.all(10),
                  child: _itemWidget((wardrobe!.getItem(index, type: type))!),
                ),
              ),
            ):Container()
          ],
        ),
      ),
      Divider(height: 0, color: Colors.black,)
    ],
  );

  Widget _itemWidget(Item item) => Image.network(item.links!.thumb_600!);

}