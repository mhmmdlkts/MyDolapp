import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_doll_app/decorations.dart';
import 'package:my_doll_app/models/combine.dart';
import 'package:my_doll_app/services/combine_service.dart';
import 'package:my_doll_app/widgets/combine_widget.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with WidgetsBindingObserver {

  bool _isGlobal = true;
  Combine? _currentCombine;

  @override
  void initState() {
    super.initState();
    _currentCombine = CombineService.combines.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                      },
                      icon: Icon(Icons.search)
                  ),
                  _toggleButton(),
                  Opacity(
                    opacity: 0,
                    child: IconButton(
                        onPressed: null,
                        icon: Icon(Icons.search)
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 50),
            _content(),
            Container(height: 50),
            _buttons(),
          ],
        )
      ),
    );
  }

  Widget _toggleButton() {
    double radius = 20;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(4, 4),
            ),
          ]
      ),
      child: Row(
        children: [
          Material(
            color: _isGlobal?Colors.primaries.first.withOpacity(0.25):Colors.white,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(radius)),
            child: InkWell(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(radius)),
              onTap: () => setState(() {
                _isGlobal = true;
              }),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(radius)),
                ),
                child: Icon(Icons.public),
              ),
            ),
          ),
          Material(
            color: !_isGlobal?Colors.primaries.first.withOpacity(0.25):Colors.white,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(radius)),
            child: InkWell(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(radius)),
              onTap: () => setState(() {
                _isGlobal = false;
              }),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(radius)),
                ),
                child: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() => Container(
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
    padding: EdgeInsets.all(10),
    child: CombineWidget(combine: _currentCombine, height: MediaQuery.of(context).size.height - 450),
  );

  ValueNotifier<double> percentage = ValueNotifier(0);
  Widget _buttons() {
    Size ctxSize = MediaQuery.of(context).size;
    double smallSize = 50;
    double bigSize = 65;
    double padding = 70;
    double iconSize = 24;
    double calc (double min, double max, bool turn, {double mul = 1}) => min + ((max - min) * (percentage.value*mul) * (turn&&percentage.value.isNegative?-1:1));
    return ValueListenableBuilder(
      valueListenable: percentage,
      builder: (ctx, val, child) => SizedBox(
        width: ctxSize.width,
        height: bigSize,
        child: Stack(
          children: [
            Positioned(
              top: bigSize - smallSize,
              left: padding,
              child: _roundButton(
                  icon: Icons.close,
                  size: smallSize,
                  iconSize: percentage.value.isNegative?calc(iconSize, 0, true).abs():iconSize,
                  onTap: () {}
              ),
            ),
            Positioned(
              top: bigSize - smallSize,
              left: ctxSize.width - (smallSize + padding),
              child: _roundButton(
                  icon: Icons.done,
                  size: smallSize,
                  iconSize: percentage.value.isNegative?iconSize:calc(iconSize, 0, false).abs(),
                  onTap: () {}
              ),
            ),
            Positioned(
              top: calc(0, bigSize - smallSize, true),
              left: percentage.value.isNegative?
                calc((ctxSize.width-bigSize)/2, padding, true) :
                calc((ctxSize.width-bigSize)/2, ctxSize.width - (smallSize + padding), false),
              child: GestureDetector(
                child: _roundButton(
                    icon: Icons.chat_outlined,
                    size: calc(bigSize, smallSize, true),
                    iconSize: iconSize,
                    onTap: percentage.value==0?onComment:null
                ),
                onHorizontalDragUpdate: (details) {
                  double mul = 3;
                  double flex = 0.2;
                  double pos = details.globalPosition.dx - ctxSize.width/2;
                  setPercentage((pos*mul) / ((ctxSize.width/2) - smallSize));
                  if (percentage.value <= -1 + flex) {
                    HapticFeedback.mediumImpact();
                    onComment(right: true);
                    percentage.value = -1;
                  } else if (percentage.value >= 1 - flex) {
                    HapticFeedback.mediumImpact();
                    onComment(right: false);
                    percentage.value = 1;
                  }
                },
                onHorizontalDragEnd: (details) {
                  percentage.value = 0;
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _roundButton({required IconData icon, required double size, double iconSize = 24, VoidCallback? onTap}) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(size)),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.circular(size)),
      child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(size)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(4, 4),
                )
              ]
          ),
          child: Icon(icon, size: iconSize,)
      ),
    ),
  );

  onComment({bool? right}) {
    if (right == null) {
      showPercentageAnimation();
    }
  }

  setPercentage(val) {
    percentage.value = val;
    if (percentage.value <= -1) {
      percentage.value = -1;
    } else if (percentage.value >= 1) {
      percentage.value = 1;
    }
  }

  showPercentageAnimation() async {
    const double maxPercentage = 0.65;
    const int goGoTimes = 1;
    const int ticker = 10;

    int j = -1;
    bool direction = true;
    for (int i = 0; i < goGoTimes * ticker * 4; i++) {
      if (i%ticker==0) {
        if (j != 0) {
          j = 0;
        } else {
          j = direction?1:-1;
          direction = !direction;
        }
      }
      percentage.value += (direction?1:-1) * (maxPercentage/ticker);
      await Future.delayed(Duration(milliseconds: 5));
    }
    percentage.value = 0;
  }
}