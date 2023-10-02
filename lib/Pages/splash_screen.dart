import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diamondplatform/Pages/check_login_page.dart';

// Import your main screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    return const Scaffold(
      body: Center(
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/logo.png'),
          maxRadius: 120,
        ), // Load the splash image from assets
      ),
    );
  }
}
