import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class Combine {
  String? id;
  late String userId;
  late Timestamp createTime;
  List<Item> items = []; // TODO Remove me
  late List<String> _itemsId;
  List<DateTime>? wearDates;

  Combine() {
    userId = FirebaseAuth.instance.currentUser?.uid??'';
    createTime = Timestamp.now();
  }

  Combine.fromDoc(QueryDocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }

    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;

    if (o.containsKey('user_id')) {
      userId = o['user_id'];
    }
    if (o.containsKey('create_time')) {
      createTime = o['create_time'];
    }
    if (o.containsKey('items')) {
      _itemsId = List<String>.from(o['items']);
    }
    if (o.containsKey('wear_dates')) {
      wearDates = List<DateTime>.from(o['wear_dates'].map((e) => e.toDate()).toList());
    }
  }

  initItems() async {
    items.clear();
    List<Future> futures = [];
    for (String itemId in _itemsId) {
      futures.add(
          WardrobeService.getItemById(itemId).then((value) => {
            if (value != null) {
              items!.add(value)
            }
          })
      );
    }
    await Future.wait(futures);
    items.sort();
  }

  void random(Wardrobe? wardrobe, {Item? oldItem}) {
    if (wardrobe == null) {
      return;
    }
    List<ItemType> validCombineTypes;
    if (oldItem == null) {
      items.clear();
      validCombineTypes = [ItemType.sweater, ItemType.pants, ItemType.shoe, ItemType.jacket];
    } else {
      items?.removeWhere((element) => element.type == oldItem.type);
      validCombineTypes = [oldItem!.type];
    }
    for (ItemType type in validCombineTypes) {
      List<Item> subItems = wardrobe.getAllTypes(type).where((element) => oldItem==null || element.id != oldItem!.id).toList();
      if (subItems.isNotEmpty) {
        items?.add(subItems[Random().nextInt(subItems.length)]);
      }
    }
    items.sort();
  }

  Object? toData() => {
    'user_id': userId,
    'create_time': createTime,
    'items': items?.map((e) => e.id).toList()??[],
    'wear_dates': wearDates?.map((e) => Timestamp.fromDate(e)).toList()??[]
  };

  void removeItem(Item item) {
    items.removeWhere((element) => element.id == item.id);
  }

  void replaceWith(Item item) {
    items.removeWhere((element) => element.type == item.type);
    items.add(item);
    items.sort();
  }

  bool hasItem(Item item) {
    for (Item i in items) {
      if (item.id == i.id) {
        return true;
      }
    }
    return false;
  }
}