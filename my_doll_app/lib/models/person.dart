import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  String? username;
  String? name;
  String? email;
  int? height;
  int? weight;
  Gender? gender;
  Timestamp? birthdate;

  Person();

  Person.copy(Person other) {
    username = other.username;
    name = other.name;
    email = other.email;
    height = other.height;
    weight = other.weight;
    gender = other.gender;
    birthdate = other.birthdate;
  }
  
  Person.dummy({required this.email}) {
    username = 'testUserName';
    name = 'Max Musterman';
    height = 183;
    weight = 96;
    gender = Gender.male;
    birthdate = Timestamp.fromDate(DateTime(1999, 10, 7));
  }

  Person.fromSnapshot(DocumentSnapshot<Object?> snap) {
    if (snap.data() == null) {
      return;
    }
    Map<String, dynamic> o = snap.data() as Map<String, dynamic>;

    if (o.containsKey('username')) {
      username = o['username'];
    }
    if (o.containsKey('birthdate')) {
      birthdate = o['birthdate'];
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
    if (o.containsKey('height')) {
      height = o['height'];
    }
    if (o.containsKey('weight')) {
      weight = o['weight'];
    }
  }

  Map toJson() => {
    'username': username,
    'birthdate': birthdate!.seconds,
    'email': email,
    'gender': gender==null?null:getStringFromGender(gender!),
    'name': name,
    'height': height,
    'weight': weight
  };

  bool isDataComplete() =>
      username != null &&
      birthdate != null &&
      email != null &&
      gender != null &&
      name != null &&
      height != null &&
      weight != null;

  static Gender getGenderFromString(String gender) {
    switch (gender) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
    }
    return Gender.male;
  }

  static String getStringFromGender(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'male';
      case Gender.female:
        return 'female';
    }
  }
}

enum Gender { male, female }
