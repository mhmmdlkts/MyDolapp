import 'package:flutter/material.dart';
import 'package:my_doll_app/screens/get_additional_info_screen.dart';
import 'package:my_doll_app/screens/home_screen.dart';
import 'package:my_doll_app/screens/splash_screen.dart';
import 'package:my_doll_app/screens/wardrobe_screen.dart';
import 'package:my_doll_app/services/init_service.dart';
import 'package:my_doll_app/services/person_service.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  late int _selectedIndex;
  bool showSplashScreen = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 2;
    InitService.init(onInited: { context.hashCode: () => {
      if (PersonService.isInited() && !PersonService.person.isDataComplete()) {
        setState((){ showSplashScreen = false; })
      } else {
        Future.delayed(const Duration(milliseconds: 1000)).then((value) => {
          setState((){ showSplashScreen = false; })
        })
      },
      setState(() {}),
    } });
  }

  @override
  void dispose() {
    super.dispose();
    InitService.removeListener(context.hashCode);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InitService.isInited?_getBody():Container(),
        showSplashScreen?SplashScreen():Container(),
      ],
    );
  }

  Widget _getBody() {
    if (!PersonService.isInited()) {
      return Container();
    }
    print(PersonService.person.gender);
    if (!PersonService.person.isDataComplete()) {
      return GetAdditionalInfoScreen(PersonService.person);
    }
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