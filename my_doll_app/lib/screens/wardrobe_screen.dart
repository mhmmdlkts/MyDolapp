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

  Wardrobe? wardrobe;

  @override
  void initState() {
    super.initState();
    wardrobe = WardrobeService.getDefaultWardrobe();
  }

  @override
  Widget build(BuildContext context) {
    return wardrobe==null?const Center(child: CircularProgressIndicator()):Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ReorderableListView(
          children: [
            SizedBox(
              key: ValueKey(''),
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: wardrobe!.itemCount(type: ItemType.pants),
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.all(10),
                    child: _itemWidget((wardrobe!.getItem(index, type: ItemType.pants))!),
                  )
              ),
            ),
            SizedBox(
              key: ValueKey(''),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: wardrobe!.itemCount(type: ItemType.tShirt),
                itemBuilder: (context, index) => Container(
                  padding: const EdgeInsets.all(10),
                  child: _itemWidget((wardrobe!.getItem(index, type: ItemType.tShirt))!),
                ),
              ),
            ),
          ],
          onReorder: (int a, int b) {},
        )
      ],
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

  Widget _itemWidget(Item item) => Image.network(item.links!.thumb_600!);

}