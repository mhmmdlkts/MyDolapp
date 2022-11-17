import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_doll_app/models/person.dart';
import 'package:my_doll_app/services/firestore_paths_service.dart';

class PersonService {

  static bool _isInited = false;
  static late Person person;

  static Future initPerson({DateTime? now}) async {
    DocumentReference? ref = FirestorePathsService.getUserDoc();
    if (ref == null) {
      return;
    }

    DocumentSnapshot snapshot = await ref.get();

    person = Person.fromSnapshot(snapshot);

    _isInited = true;
    if (now != null) {
      print('initPerson: took: ${DateTime.now().difference(now).inMilliseconds}');
    }
  }

  static bool isInited() => _isInited;
}