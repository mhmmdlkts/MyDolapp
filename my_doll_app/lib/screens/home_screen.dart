import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_doll_app/enums/item_type_enum.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/screens/add_item_screen.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Wardrobe? wardrobe;
  Combine combine = Combine();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => {
      if (mounted) {
        WardrobeService.fetchWardrobes().then((value) => {
          if (mounted)
            setState(() {
              wardrobe = WardrobeService.getDefaultWardrobe();
              combine.random(wardrobe!);
            })
        })
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ElevatedButton(onPressed: (){
          FirebaseAuth.instance.signOut();
        }, child: Text('Sign Out'),),
      ),
      appBar: AppBar(title: Text('My Dolapp')),
      body: wardrobe==null?const Center(child: CircularProgressIndicator()):Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ItemOnAvatarWidget(
            combine: combine,
            onItemClicked: (Item item) => setState(() {
                combine.random(wardrobe!);
              }
            )
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: wardrobe!.itemCount(),
              itemBuilder: (context, index) => _itemWidget((wardrobe!.getItem(index))!),
            )
          )
        ],
      ),
      floatingActionButton: wardrobe != null? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemScreen(wardrobe: wardrobe!)),
          );
        },
      ):null,
    );
  }

  Widget _itemWidget(Item item) => Image.network(item.links!.thumb_600!);

}