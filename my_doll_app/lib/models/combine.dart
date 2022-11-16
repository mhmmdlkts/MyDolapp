import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';

class Combine {
  String? id;
  late Timestamp createTime;
  late Map<int, List<Item>> items;

  Combine() {
    createTime = Timestamp.now();
    clear();
  }

  void clear() {
    items = {
      0: []
    };
  }

  void random(Wardrobe? wardrobe, {Item? oldItem}) {
    if (wardrobe == null) {
      return;
    }
    List<ItemType> validCombineTypes;
    if (oldItem == null) {
      clear();
      validCombineTypes = [ItemType.sweater, ItemType.pants, ItemType.shoe];
    } else {
      items[0]?.removeWhere((element) => element.type == oldItem.type);
      validCombineTypes = [oldItem!.type];
    }
    for (ItemType type in validCombineTypes) {
      List<Item> subItems = wardrobe.getAllTypes(type).where((element) => oldItem==null || element.id != oldItem!.id).toList();
      if (subItems.isNotEmpty) {
        items[0]?.add(subItems[Random().nextInt(subItems.length)]);
      }
    }
    addTestFloor(wardrobe, oldItem);
  }

  addTestFloor(Wardrobe wardrobe, Item? oldItem) {
    int floor = 1;
    items[floor] = [];
    for (ItemType type in [ItemType.jacket]) {
      List<Item> subItems = wardrobe.getAllTypes(type).where((element) => oldItem==null || element.id != oldItem!.id).toList();
      if (subItems.isNotEmpty) {
        items[floor]?.add(subItems[Random().nextInt(subItems.length)]);
      }
    }
  }

  bool existStack() {
    bool check = false;
    items.forEach((key, value) {
      if (key != 0) {
        check = true;
        return;
      }
    });
    return check;
  }
}