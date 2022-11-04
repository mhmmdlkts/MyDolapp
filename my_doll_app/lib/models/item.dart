import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  late String id;
  late String name;
  late Timestamp createTime;

  Item.fromDoc(QueryDocumentSnapshot<Object?> element) {
    id = element.id;
    name = element.get('name');
    createTime = element.get('create_time');
  }
}