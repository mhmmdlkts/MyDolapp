import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:vector_math/vector_math_64.dart';

class Item {
  String? id;
  ItemType type = ItemType.other;
  late Timestamp createTime;
  late Matrix4 matrix;
  String? base64;
  ItemDownloadLinks? links;
  late Color color;
  late String colorName;

  Item.fromDoc(QueryDocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }

    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;

    if (o.containsKey('type')) {
      type = ItemTypeService.stringToEnum(o['type']);
    }
    if (o.containsKey('create_time')) {
      createTime = o['create_time'];
    }
    if (o.containsKey('matrix')) {
      matrix = decodeMatrix4(o['matrix']);
    }
    if (o.containsKey('colorHex')) {
      color = fromHex(o['colorHex']);
    }
    if (o.containsKey('colorName')) {
      colorName = o['colorName'];
    }
  }
  
  Future initImageUrls() async {
    links = ItemDownloadLinks(id!);
    await links?.init();
  }

  Item({required this.type, required this.matrix, required this.base64}) {
    createTime = Timestamp.now();

  }

  Map<String, dynamic> toData() => {
    'type': ItemTypeService.enumToString(type),
    'create_time': createTime,
    'matrix': encodeMatrix4(matrix),
    'colorHex': color.toHex(withAlpha: false)
  };
/*
  Future getThumbLink() async {
    if (links?.thumb_600 != null) {
      return;
    }

    final Reference storageRef = StorageService.getItemRef(id!, 'img_600x600');

    final String thumb_600 = await storageRef.child('600x600.png').getDownloadURL();
    links?.thumb_600 = thumb_600;
  }

  Future<void> getOriginalLink() async {
    if (links.original != null) {
      return;
    }

    final Reference storageRef = StorageService.getItemRef(id!, 'img_600x600.png');

    final String original = await storageRef.getDownloadURL();
    links.original = original;
  }
*/
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

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class ItemDownloadLinks {
  String itemId;
  late String thumb_50;
  late String thumb_100;
  late String thumb_200;
  late String thumb_400;
  late String thumb_600;
  String? thumb_800;
  String? thumb_1200;
  String? thumb_2000;

  ItemDownloadLinks(this.itemId);
  
  Future init() async {
    // thumb_50 = await StorageService.getItemRef(itemId, 'img_50x50').getDownloadURL();
    // thumb_100 = await StorageService.getItemRef(itemId, 'img_100x100').getDownloadURL();
    // thumb_200 = await StorageService.getItemRef(itemId, 'img_200x200').getDownloadURL();
    // thumb_400 = await StorageService.getItemRef(itemId, 'img_400x400').getDownloadURL();
    thumb_600 = await StorageService.getItemRef(itemId, '600x600.png').getDownloadURL();
  }
  
  Future init800() async {
    thumb_800 ??= await StorageService.getItemRef(itemId, 'img_800x800').getDownloadURL();
  }
  
  Future init1200() async {                             // TODO
    thumb_1200 ??= await StorageService.getItemRef(itemId, 'img').getDownloadURL();
  }
  
  Future init2000() async {
    thumb_2000 ??= await StorageService.getItemRef(itemId, 'img_2000x2000').getDownloadURL();
  }
}