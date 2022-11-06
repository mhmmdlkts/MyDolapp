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

  void random(Wardrobe wardrobe) {
    items.clear();
    List<ItemType> validCombineTypes = [ItemType.tShirt, ItemType.pants];
    for (ItemType type in validCombineTypes) {
      List<Item> subItems = wardrobe.getAllTypes(type);
      if (subItems.isNotEmpty) {
        items.add(subItems[Random().nextInt(subItems.length)]);
      }
    }
  }
}