import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diamondplatform/Pages/check_login_page.dart';

// Import your main screen

class SplashScreen extends StatefulWidget {
 //  SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for a few seconds and then navigate to the main screen
    Timer(const Duration(seconds: 1), ()  {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>check_login_page()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .8,
          height: MediaQuery.of(context).size.width * .8,
          decoration: BoxDecoration(
           // shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/logo.png'),
              fit: BoxFit.cover, // You can change this property to control how the image is scaled
            ),
          ),
        ),
      ),
    );
  }
}
