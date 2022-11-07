import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

import 'item.dart';

class Wardrobe {
  late String id;
  late String name;
  late Timestamp createTime;
  List<Item>? _items;

  Wardrobe.fromDoc(QueryDocumentSnapshot doc) {
    id = doc.id;
    name = doc.get('name');
    createTime = doc.get('create_time');
  }

  bool isLoaded() => _items != null;

  Future loadItems() async {
    if (isLoaded()) {
      return;
    }
    _items = await WardrobeService.loadWardrobe(id);
  }

  int itemCount({ItemType? type}) => _items?.where((element) => type==null || element.type == type)?.length??0;

  Item? getItem(int index, {ItemType? type}) => _items?.where((element) => type==null || element.type == type)?.elementAt(index);

  List<Item> getAllTypes(ItemType type) {
    if (!isLoaded()) {
      return [];
    }
    List<Item> items = [];
    _items!.where((element) => element.type == type).forEach((element) {
      items.add(element);
    });
    return items;
  }
}