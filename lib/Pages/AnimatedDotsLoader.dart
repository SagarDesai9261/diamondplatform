
import 'package:flutter/material.dart';

class AnimatedDotsLoader extends StatefulWidget {
  @override
  AnimatedDotsLoaderState createState() => AnimatedDotsLoaderState();
}

class AnimatedDotsLoaderState extends State<AnimatedDotsLoader> {
  int dotCount = 4; // Number of dots
  double dotSize = 10.0; // Size of each dot
  double spacing = 5.0; // Spacing between dots
  Color dotColor = Colors.blue; // Color of the dots
  Duration animationDuration =
  Duration(milliseconds: 400); // Duration of the animation

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Future.delayed(animationDuration, () {
      if (mounted) {
        setState(() {
          dotCount = (dotCount + 1) % 4; // Increment the dot count
        });
        startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dots = [];

    for (int i = 0; i < dotCount; i++) {
      dots.add(
        Container(
          width: dotSize,
          height: dotSize,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
