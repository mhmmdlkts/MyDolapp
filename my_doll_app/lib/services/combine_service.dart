import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_doll_app/services/firestore_paths_service.dart';

import '../models/combine.dart';

class CombineService {
  static List<Combine> combines = [];
  static Map<DateTime, Combine> combinesByDate = {};

  static Future initCombines({DateTime? now}) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference? col = FirestorePathsService.getCombinesCollection();
    if (col == null) {
      return;
    }

    QuerySnapshot querySnapshot = await col.where('user_id', isEqualTo: uid).get();
    for (var element in querySnapshot.docs) {
      combines.add(Combine.fromDoc(element));
    }

    initCombinesByDate();
    if (now != null) {
      print('initCombines: took: ${DateTime.now().difference(now).inMilliseconds}');
    }
  }

  static initCombinesByDate() {
    for (Combine combine in combines) {
      combine.wearDates?.forEach((date) {
        combinesByDate.addAll({date: combine});
      });
    }
    combinesByDate = Map.fromEntries(combinesByDate.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));
  }

  static Future initAllCombines() async {
    List<Future> futures = [];
    for (Combine combine in combines) {
      futures.add(combine.initItems());
    }
    await Future.wait(futures);
  }

  static Future addNewCombine(Combine combine) async {
    combine.createTime = Timestamp.now();
    CollectionReference col = FirestorePathsService.getCombinesCollection()!;
    String id = col.doc().id;
    combine.id = id;
    combines.add(combine);
    await col.doc(id).set(combine.toData());
  }
}