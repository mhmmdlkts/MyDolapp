import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/models/item.dart';
import 'package:my_doll_app/models/wardrobe.dart';
import 'package:my_doll_app/models/weather.dart';
import 'package:my_doll_app/services/wardrobe_service.dart';
import 'package:my_doll_app/services/weather_service.dart';
import 'package:my_doll_app/widgets/item_on_avatar.dart';
import 'package:my_doll_app/widgets/weather_bg_widget.dart';

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
    wardrobe = WardrobeService.getDefaultWardrobe();
    combine.random(wardrobe);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      /*constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg4.jpg"),
          fit: BoxFit.fill,
        ),
      ),*/
      child: WeatherBgWidget(
        weather: Weather(temp: 17.4, type: WeatherType.rainy, country: 'Salzburg'),
        child: wardrobe==null?const Center(child: CircularProgressIndicator(color: Colors.white,)):Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 250),
            ItemOnAvatarWidget(
              showShadow: true,
              combine: combine,
              onItemClicked: (Item item) => setState(() {
                combine.random(wardrobe!);
              })
            ),
          ],
        ),
      ),
    );
  }
}