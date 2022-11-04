import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WardrobeService.fetchWardrobes().then((value) => {
      if (mounted)
        setState(() {})
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ElevatedButton(onPressed: (){}, child: Text('sa'),),
      ),
      appBar: AppBar(title: Text("My Dolapp")),
      body: Container(
        child: ListView.builder(
          itemCount: WardrobeService.getDefaultWardrobe()?.itemCount()??0,
          itemBuilder: (context, index) => _itemWidget((WardrobeService.getDefaultWardrobe()?.getItem(index))!),
        )
      ),
    );
  }

  Widget _itemWidget(Item item) => Text(item.name);

}