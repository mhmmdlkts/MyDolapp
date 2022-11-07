import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/screens/add_item_screen.dart';
import 'package:my_doll_app/screens/home_screen.dart';
import 'package:my_doll_app/screens/wardrobe_screen.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';

import '../widgets/empty_app_bar.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => {
      if (mounted) {
        WardrobeService.fetchWardrobes().then((value) => {
          if (mounted)
            setState(() { })
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(height: 0),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group), label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_small), label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom), label: ''
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), label: ''
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (int i) => setState((){
          _selectedIndex = i;
        }),
      ),
      body: _getSelectedPage(),
    );
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 2: return const HomeScreen();
      case 3: return const WardrobeScreen();
    }
    return const Center(child: Text('...'));
  }
}