import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  static Future testFunc(String base64, String uid, String itemId) async {
    final storageRef = FirebaseStorage.instance.ref(uid).child('Items').child(itemId).child('original.png');
    try {
      await storageRef.putString(base64, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png'));
    } catch (e) {
      print(e);
    }
    return null;
  }
}