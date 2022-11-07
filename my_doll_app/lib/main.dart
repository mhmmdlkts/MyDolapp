import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/screens/first_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My DolApp',
      theme: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(systemOverlayStyle:SystemUiOverlayStyle.light),
      ),
      home: StreamBuilder(
        stream: auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;
          if (user == null) {
            return SignInScreen(
              providers: [EmailAuthProvider()],
            );
          } else {
            return const FirstScreen();
          }
        }
      )
    );
  }
}
