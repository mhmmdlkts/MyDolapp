import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/services/firestore_paths_service.dart';
import 'package:my_doll_app/services/storage_service.dart';

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
    wardrobes.sort();
    await getDefaultWardrobe()?.loadItems();
  }

  static Future<List<Item>> loadWardrobe(String wardrobeId) async {

    CollectionReference col = FirestorePathsService.getItemsCollection(wardrobeId)!;

    QuerySnapshot querySnapshot = await col.get();
    List<Item> items = [];
    List<Future> urlTasks = [];
    for (var element in querySnapshot.docs) {
      Item item = Item.fromDoc(element);
      items.add(item);
      urlTasks.add(item.initImageUrls());
    }
    await Future.wait(urlTasks);
    return items;
  }

  static Wardrobe? getDefaultWardrobe() {
    List<Wardrobe> defs = wardrobes.where((element) => element.isDefault).toList();
    if (defs.isNotEmpty) {
      return defs.first;
    }
    if (wardrobes.isNotEmpty) {
      return wardrobes.first;
    }
    return null;
  }

  static Future<String> addItem(Wardrobe wardrobe, Item item) async {
    CollectionReference col = FirestorePathsService.getItemsCollection(wardrobe.id)!;
    String id = col.doc().id;
    item.id = id;
    if (item.base64 != null) {
      await StorageService.uploadImage(item.base64!, id);
    }
    wardrobe.addItem(item);
    await col.doc(id).set(item.toData());
    return id;
  }

  static Future<String?> updateWardrobe(Wardrobe wardrobe) async {
    DocumentReference? ref = FirestorePathsService.getWardrobeDoc(wardrobe.id);
    if (ref == null) {
      return null;
    }
    await ref!.update(wardrobe.toData());
  }

  static Future<String?> createWardrobe(Wardrobe wardrobe) async {
    CollectionReference? ref = FirestorePathsService.getWardrobesCollection();
    if (ref == null) {
      return null;
    }
    DocumentReference newDocRef = await ref!.add(wardrobe.toData());
    wardrobe.id = newDocRef.id;
    wardrobes.add(wardrobe);
    return newDocRef.id;
  }

  static Future removeWardrobe(Wardrobe wardrobe) async {
    DocumentReference? ref = FirestorePathsService.getWardrobeDoc(wardrobe.id);
    if (ref == null) {
      return null;
    }
    await ref!.delete();
    wardrobes.removeWhere((element) => element.id == wardrobe.id);
  }

  static Future setDefault(Wardrobe wardrobe) async {
    List<Future> tasks = [];
    for (var element in wardrobes) {
      DocumentReference ref = FirestorePathsService.getWardrobeDoc(element.id)!;
      element.isDefault = wardrobe.id == element.id;
      tasks.add(ref.update({'is_default': element.isDefault}));
    }
    await Future.wait(tasks);
  }

}