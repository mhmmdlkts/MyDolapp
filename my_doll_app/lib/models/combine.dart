import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class Combine {
  String? id;
  late Timestamp createTime;
  late Map<int, List<Item>> items; // TODO Remove me
  late List<String> _itemsId;
  List<DateTime>? wearDates;

  Combine() {
    createTime = Timestamp.now();
    clear();
  }

  Combine.fromDoc(QueryDocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }

    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;

    if (o.containsKey('create_time')) {
      createTime = o['create_time'];
    }
    if (o.containsKey('items')) {
      _itemsId = List<String>.from(o['items']);
    }
    if (o.containsKey('wearDates')) {
      wearDates = List<DateTime>.from(o['wearDates'].map((e) => e.toDate()).toList());
    }
  }

  initItems() async {
    clear();
    List<Future> futures = [];
    for (String itemId in _itemsId) {
      futures.add(
          WardrobeService.getItemById(itemId).then((value) => {
            if (value != null) {
              items[0]!.add(value)
            }
          })
      );
    }
    await Future.wait(futures);
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

  Object? toData() => {
    'create_time': createTime,
    'items': items[0]?.map((e) => e.id).toList()??[],
    'wearDates': wearDates?.map((e) => Timestamp.fromDate(e)).toList()??[]
  };
}