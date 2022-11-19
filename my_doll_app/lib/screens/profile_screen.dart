import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/services/combine_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(onPressed: () {
        FirebaseAuth.instance.signOut();
      }, child: Icon(Icons.logout)),
    );
  }
}