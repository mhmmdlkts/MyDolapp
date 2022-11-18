import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/screens/first_screen.dart';
import 'package:my_doll_app/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int i = 0;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) => {
      if (i < 2) {
        setState((){
          i = 2;
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My DolApp',
      theme: ThemeData(
        primarySwatch: Colors.red,
        appBarTheme: Theme.of(context).appBarTheme.copyWith(systemOverlayStyle:SystemUiOverlayStyle.light),
      ),
      home: StreamBuilder(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return loading();
          }
          final user = snapshot.data;
          if (user == null) {
            return SignInScreen(
              providers: [EmailAuthProvider()],
            );
          } else {
            if (++i >= 2) {
              return const FirstScreen();
            } else {
              return loading();
            }
          }
        }
      )
    );
  }

  Widget loading() => SplashScreen(freeze: true);
}

extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ?'${this[0].toUpperCase()}${substring(1).toLowerCase()}':'';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}

extension Resize on Matrix4 {
  Matrix4 resize({dx = 1, dy = 1}) {
    final v0 = getColumn(0);
    final v1 = getColumn(1);
    final v2 = getColumn(2);
    final v3 = getColumn(3);
    return Matrix4(v0[0]/1, v0[1]/1, v0[2], v0[3], v1[0]/1, v1[1]/1, v1[2], v1[3], v2[0]/1, v2[1]/1, v2[2], v2[3], v3[0]/dx, v3[1]/dy, v3[2], v3[3]);
  }
}

extension HexColor on Color {

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true, bool withAlpha = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${withAlpha ? alpha.toRadixString(16).padLeft(2, '0').toUpperCase() : ''}'
      '${red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
      '${blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
}