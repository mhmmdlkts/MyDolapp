import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:vector_math/vector_math_64.dart';

class Item {
  String? id;
  ItemType type = ItemType.other;
  late Timestamp createTime;
  late Matrix4 matrix;
  String? base64;
  ItemDownloadLinks links = ItemDownloadLinks();

  Item.fromDoc(QueryDocumentSnapshot<Object?> element) {
    id = element.id;
    type = ItemTypeService.stringToEnum(element.get('type'));
    createTime = element.get('create_time');
    matrix = decodeMatrix4(element.get('matrix'));
  }

  Item() {
    createTime = Timestamp.now();
  }

  Map<String, dynamic> toData() => {
    'type': ItemTypeService.enumToString(type),
    'create_time': createTime,
    'matrix': encodeMatrix4(matrix)
  };

  Future getThumbLink() async {
    if (links.thumb_600 != null) {
      return;
    }

    final Reference storageRef = FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid).child('Items').child(id!);

    final String thumb_600 = await storageRef.child('600x600.png').getDownloadURL();
    links.thumb_600 = thumb_600;
  }

  Future<void> getOriginalLink() async {
    if (links.original != null) {
      return;
    }

    final Reference storageRef = FirebaseStorage.instance.ref(FirebaseAuth.instance.currentUser!.uid).child('Items').child(id!);

    final String original = await storageRef.child('original.png').getDownloadURL();
    links.original = original;
  }

  static Matrix4 decodeMatrix4(String? matrix) {
    if (matrix == null) {
      return Matrix4.identity();
    }
    List<double> v = matrix!.split(',').map(double.parse).toList();
    return Matrix4(v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11],v[12],v[13],v[14],v[15]);
  }

  static String encodeMatrix4(Matrix4 matrix) {
    List<String> value = List.filled(16, '0');
    List<Vector4> vectors = [matrix.row0, matrix.row1, matrix.row2, matrix.row3];

    for (int i = 0, j = i; i < vectors.length; i++, j = i) {
      vectors[i].toString().split(',').forEach((element) {
        value[j] = element;
        j += vectors.length;
      });
    }
    return value.join(',');
  }
}

class ItemDownloadLinks {
  String? original;
  String? thumb_600;
}