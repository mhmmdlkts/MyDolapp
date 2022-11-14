import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {

  static Future uploadImage(String base64, String itemId) async {
    final storageRef = getItemRef(itemId, 'img');
    try {
      await storageRef.putString(base64, format: PutStringFormat.base64, metadata: SettableMetadata(contentType: 'image/png'));
    } catch (e) {
      print(e);
    }
  }

  static Reference getItemRef(String itemId, String imgName) => FirebaseStorage.instance.ref('users').child(FirebaseAuth.instance.currentUser!.uid).child('items').child(itemId).child(imgName);
}