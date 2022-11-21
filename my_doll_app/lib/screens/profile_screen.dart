import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/services/cloudfunctions_service.dart';
import 'package:my_doll_app/services/person_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // FirebaseAuth.instance.signOut();
                },
                icon: Icon(Icons.more_vert)
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _getFollowsFollowersTextWidget(623, 'Follower'),
              _getCircleOwnImage(),
              _getFollowsFollowersTextWidget(234, 'Follows'),
            ],
          ),
          Container(height: 30,),
          _getUsername(),
          _getBio(),
        ],
      ),
    );
  }

  Widget _getUsername() => Text(
    PersonService.person.username!
  );

  Widget _getBio() => Text('Bio');
  
  Widget _getCircleOwnImage() => CircleAvatar(
    child: Container(
    ),
    backgroundColor: Colors.black.withOpacity(0.08),
    minRadius: 50,
  );

  Widget _getFollowsFollowersTextWidget(int count, String label) => Column(
    children: [
      Text(count.toString()),
      Text(label),
    ],
  );
}