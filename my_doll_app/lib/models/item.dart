import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/main.dart';
import 'package:my_doll_app/services/storage_service.dart';
import 'package:vector_math/vector_math_64.dart';

class Item implements Comparable {
  String? id;
  String? wardrobeId;
  String? userId;
  ItemType type = ItemType.other;
  late Timestamp createTime;
  late Matrix4 matrix;
  String? base64;
  ItemImages? images;
  Color? color;
  String? colorName;

  Item.fromDoc(QueryDocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }

    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    id = snap.id;

    if (o.containsKey('wardrobe_id')) {
      wardrobeId = o['wardrobe_id'];
    }
    if (o.containsKey('type')) {
      type = ItemTypeService.stringToEnum(o['type']);
    }
    if (o.containsKey('create_time')) {
      createTime = o['create_time'];
    }
    if (o.containsKey('matrix')) {
      matrix = decodeMatrix4(o['matrix']);
    }
    if (o.containsKey('color_hex')) {
      color = fromHex(o['color_hex']);
    }
    if (o.containsKey('color_name')) {
      colorName = o['color_name'];
    }
  }
  
  Future initImageUrls() async {
    if (images != null) {
      return;
    }
    images = ItemImages(id!);
    await images?._init();
  }

  Item({required this.type, required this.matrix, required this.base64}) {
    createTime = Timestamp.now();

  }

  Map<String, dynamic> toData() => {
    'wardrobe_id': wardrobeId,
    'type': ItemTypeService.enumToString(type),
    'create_time': createTime,
    'matrix': encodeMatrix4(matrix),
    'color_hex': color?.toHex(withAlpha: false),
    'color_name': colorName
  };

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

  @override
  int compareTo(other) {
    int a = ItemTypeService.enumToZIndex(type);
    int b = ItemTypeService.enumToZIndex(other.type);
    if (a == b) {
      return createTime?.compareTo(other.createTime)??0;
    }
    return a - b;
  }
}

class ItemImages {
  String itemId;
  late Uint8List? thumb_50;
  late Uint8List? thumb_100;
  late Uint8List? thumb_200;
  late Uint8List? thumb_400;
  late Uint8List? thumb_600;
  Uint8List? thumb_800;
  Uint8List? thumb_1200;
  Uint8List? thumb_2000;


  ItemImages(this.itemId);
  
  Future _init() async {
    thumb_50 = await StorageService.getItemRef(itemId, 'img_50x50').getData();
    // thumb_100 = await StorageService.getItemRef(itemId, 'img_100x100').getData();
    // thumb_200 = await StorageService.getItemRef(itemId, 'img_200x200').getData();
    // thumb_400 = await StorageService.getItemRef(itemId, 'img_400x400').getData();
    thumb_600 = await StorageService.getItemRef(itemId, 'img_600x600').getData();
  }
  
  Future init800() async {
    if (thumb_800 != null) {
      return;
    }
    thumb_800 = await StorageService.getItemRef(itemId, 'img_800x800').getData();
  }
  
  Future init1200() async {
    if (thumb_1200 != null) {
      return;
    }
    thumb_1200 = await StorageService.getItemRef(itemId, 'img_1200x1200').getData();
  }
  
  Future init2000() async {
    if (thumb_2000 != null) {
      return;
    }
    thumb_2000 = await StorageService.getItemRef(itemId, 'img_2000x2000').getData();
  }

  Uint8List getBestQuality() {
    if (thumb_2000 != null) {
      return thumb_2000!;
    }
    if (thumb_1200 != null) {
      return thumb_1200!;
    }
    if (thumb_800 != null) {
      return thumb_800!;
    }
    if (thumb_600 != null) {
      return thumb_600!;
    }
    if (thumb_400 != null) {
      return thumb_400!;
    }
    if (thumb_200 != null) {
      return thumb_200!;
    }
    if (thumb_100 != null) {
      return thumb_100!;
    }
    if (thumb_50 != null) {
      return thumb_50!;
    }
    return Uint8List.fromList([]);
  }
}