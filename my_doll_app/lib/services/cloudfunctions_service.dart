import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'package:my_doll_app/secrets/secret_api_service.dart';

class CloudfunctionsService{
  static const String functionExistUsername = 'existUsername';
  static const String functionUpdateUserValues = 'updateUserValues';
  static const String functionFollowUser = 'followUser';

  static const String _host = 'europe-west1-my-dolapp.cloudfunctions.net';
  static const String _testHost = '127.0.0.1';
  static const int _hostPort = 8081;

  static Future<Map> httpCall(String functionName, {Map? body, String? testUid}) async{
    bool isTest = testUid != null;
    String uid = isTest?testUid:FirebaseAuth.instance.currentUser?.uid??'';
    String email = FirebaseAuth.instance.currentUser?.email??'';
    Response response = await post(
      Uri(
        port: isTest?_hostPort:null,
        scheme: isTest?'http':'https',
        host: isTest?_testHost:_host,
        path: isTest?'my-dolapp/europe-west1/$functionName':functionName,
      ),
      body: body==null?"{}":json.encode(body),
      headers: {
        'uid': uid,
        'email': email,
        'security_key': _calculateSecurityKey(uid, email)
      }
    );
    Map map = {'status': response.statusCode};
    try {
      map.addAll(json.decode(response.body));
    } catch (e) {
      print(e);
    }
    return map;
  }

  static String _calculateSecurityKey(String uid, String email) => sha256.convert(utf8.encode('$uid:$email:${SecretApiService.cloudFunctionsSeed}')).toString();
}