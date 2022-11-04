import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/services/firestore_paths_service.dart';

class WardrobeService {
  static List<Wardrobe> wardrobes = [];


  static Future fetchWardrobes() async {
    if (wardrobes.isNotEmpty) {
      return;
    }

    CollectionReference? col = FirestorePathsService.getWardrobesCollection();
    if (col == null) {
      return;
    }

    QuerySnapshot querySnapshot = await col.get();

    for (var element in querySnapshot.docs) {
      wardrobes.add(Wardrobe.fromDoc(element));
    }
    await getDefaultWardrobe()?.loadItems();
  }

  static Future<List<Item>> loadWardrobe(String wardrobeId) async {

    CollectionReference col = FirestorePathsService.getItemsCollection(wardrobeId)!;

    QuerySnapshot querySnapshot = await col.get();
    List<Item> items = [];
    for (var element in querySnapshot.docs) {
      items.add(Item.fromDoc(element));
    }
    return items;
  }

  static Wardrobe? getDefaultWardrobe() {
    if (wardrobes.isEmpty) {
      return null;
    }
    return wardrobes.first;
  }
}