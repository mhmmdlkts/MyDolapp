import 'package:flutter/material.dart';
import 'package:my_doll_app/screens/home_screen.dart';
import 'package:my_doll_app/screens/wardrobe_screen.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) => {
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