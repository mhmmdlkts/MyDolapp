import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePathsService {

  static const String _usersKey = "users";
  static const String _wardrobesKey = "wardrobes";
  static const String _combinesKey = "combines";
  static const String _itemsKey = "items";

  static DocumentReference? getUserDoc() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_usersKey).doc(uid);
  }

  static CollectionReference? getWardrobesCollection() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_usersKey).doc(uid).collection(_wardrobesKey);
  }

  static DocumentReference? getWardrobeDoc(String id) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_usersKey).doc(uid).collection(_wardrobesKey).doc(id);
  }

  static CollectionReference? getItemsCollection(String id) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_usersKey).doc(uid).collection(_wardrobesKey).doc(id).collection(_itemsKey);
  }

  static CollectionReference? getCombinesCollection() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return FirebaseFirestore.instance.collection(_usersKey).doc(uid).collection(_combinesKey);
  }
}