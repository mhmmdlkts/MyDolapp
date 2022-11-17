import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

import 'item.dart';

class Wardrobe implements Comparable {
  late String id;
  late String name;
  late Timestamp createTime;
  bool isDefault = false;
  List<Item>? _items;

  Wardrobe({required this.name}) {
    createTime = Timestamp.now();
  }

  Wardrobe.fromDoc(QueryDocumentSnapshot doc) {
    id = doc.id;

    Map<String, dynamic> o = doc.data() as Map<String, dynamic>;


    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('is_default')) {
      isDefault = o['is_default'];
    }
    if (o.containsKey('create_time')) {
      createTime = o['create_time'];
    }
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

  List<Item> getItems() {
    if (isLoaded()) {
      return _items!;
    }
    return [];
  }

  List<Item> getAllTypes(ItemType type) {
    if (!isLoaded()) {
      return [];
    }
    List<Item> items = [];
    _items!.where((element) => element.type == type).forEach((element) {
      items.add(element);
    });
    items.sort();
    return items;
  }

  Map<String, dynamic> toData() => {
    'name': name,
    'is_default': isDefault,
    'create_time': createTime,
  };

  @override
  int compareTo(other) => createTime?.compareTo(other.createTime)??0;

  void addItem(Item item) {
    _items?.add(item);
  }

  Item? getItemById(String id) {
    if (!isLoaded()) {
      return null;
    }
    List<Item> whereId = _items!.where((element) => element.id == id).toList();
    if (whereId.isEmpty) {
      return null;
    }
    return whereId.first;
  }

}