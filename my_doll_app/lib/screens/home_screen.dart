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

  Weather? weather;
  Wardrobe? wardrobe;
  Combine combine = Combine();

  @override
  void initState() {
    super.initState();
    wardrobe = WardrobeService.getDefaultWardrobe();
    combine.random(wardrobe);
    WeatherService.getWeather().then((value) => {
      if (mounted)
        setState((){
          weather = value;
        })
    });
  }

  @override
  Widget build(BuildContext context) {
    return WeatherBgWidget(
      weather: weather,
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
    );
  }
}