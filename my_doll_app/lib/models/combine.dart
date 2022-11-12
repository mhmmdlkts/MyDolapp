import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';

class Combine {
  String? id;
  late Timestamp createTime;
  List<Item> items = [];

  Combine() {
    createTime = Timestamp.now();
  }

  void random(Wardrobe? wardrobe, {Item? oldItem}) {
    if (wardrobe == null) {
      return;
    }
    List<ItemType> validCombineTypes;
    if (oldItem == null) {
      items.clear();
      validCombineTypes = [ItemType.tShirt, ItemType.pants];
    } else {
      items.removeWhere((element) => element.type == oldItem.type);
      validCombineTypes = [oldItem!.type];
    }
    for (ItemType type in validCombineTypes) {
      List<Item> subItems = wardrobe.getAllTypes(type).where((element) => oldItem==null || element.id != oldItem!.id).toList();
      if (subItems.isNotEmpty) {
        items.add(subItems[Random().nextInt(subItems.length)]);
      }
    }
  }
}