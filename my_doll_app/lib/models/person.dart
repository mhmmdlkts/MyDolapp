import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? username;
  String? name;
  Timestamp? birthday;
  String? city;
  String? country;
  String? email;
  Gender? gender;
  GeoPoint? position;
  double? size;
  double? weight;

  Person();

  Person.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    if (o.containsKey('username')) {
      username = o['username'];
    }
    if (o.containsKey('birthdate')) {
      birthday = o['birthdate'];
    }
    if (o.containsKey('city')) {
      city = o['city'];
    }
    if (o.containsKey('country')) {
      country = o['country'];
    }
    if (o.containsKey('email')) {
      email = o['email'];
    }
    if (o.containsKey('gender')) {
      gender = getGenderFromString(o['gender']);
    }
    if (o.containsKey('name')) {
      name = o['name'];
    }
    if (o.containsKey('position')) {
      position = o['position'];
    }
    if (o.containsKey('size')) {
      size = o['size'] + 0.0;
    }
    if (o.containsKey('weight')) {
      weight = o['weight'] + 0.0;
    }
  }

  bool isDataComplete() =>  username != null &&
                            birthday != null &&
                            city != null &&
                            country != null &&
                            email != null &&
                            gender != null &&
                            name != null &&
                            position != null &&
                            size != null &&
                            weight != null;

  Gender getGenderFromString(String gender) {
    switch (gender) {
      case 'male': return Gender.male;
      case 'female': return Gender.female;
    }
    return Gender.male;
  }

  String getStringFromGender(Gender gender) {
    switch (gender) {
      case Gender.male: return 'male';
      case Gender.female: return 'female';
    }
  }
}

enum Gender {
  male,
  female
}