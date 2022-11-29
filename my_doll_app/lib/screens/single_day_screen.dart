import 'package:flutter/material.dart';
import 'package:my_doll_app/models/combine.dart';
import 'create_outfit_screen.dart';

import '../widgets/combine_widget.dart';

class SingleDayScreen extends StatefulWidget {
  final DateTime date;
  final Combine? combine;
  const SingleDayScreen(this.date, {this.combine, super.key});

  @override
  _SingleDayScreenState createState() => _SingleDayScreenState();
}

class _SingleDayScreenState extends State<SingleDayScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(left: 20),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back_ios)
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _content(),
                  Container(height: 20),
                  _singleInput(
                    hidden: false,
                    icon: Icons.calendar_month,
                    child: Text('25 January 2022'),
                  ),
                  _singleInput(
                    hidden: false,
                    icon: Icons.location_pin,
                    child: Text('Uni Salzburg'),
                  ),
                  _singleInput(
                    hidden: true,
                    icon: Icons.group,
                    child: Text('Faruk, Mars, Erol, Kutay, Minel, Ayberk, Ilker, Amac, Faruk, Mars, Erol, Kutay, Minel, Ayberk, Ilker, Amac, Faruk, Mars, Erol, Kutay, Minel, Ayberk, Ilker, Amac'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _singleInput({required Widget child, bool hidden = true, required IconData icon}) {
    ValueNotifier<bool> isHidden = ValueNotifier(hidden);
    return Container(

      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(4, 4),
            )
          ]
      ),
      child: Row(
        children: [
          Icon(icon),
          Expanded(child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: child,
          )),
          IconButton(onPressed: () {
            isHidden.value = !isHidden.value;
          }, icon: ValueListenableBuilder(
            valueListenable: isHidden,
            builder: (a, _, b) => Icon(isHidden.value?Icons.visibility_off:Icons.visibility),
          ))
        ],
      ),
    );
  }

  Widget _content() => Container(
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(4, 4),
          )
        ]
    ),
    child: Material(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateOutfitScreen(combine: widget.combine)),
          );
          setState(() {});
        },
        child: Container(
          padding: EdgeInsets.all(20),
          child: CombineWidget(combine: widget.combine, width: MediaQuery.of(context).size.width - 80),
        ),
      ),
    ),
  );
}
