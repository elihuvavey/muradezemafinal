import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:muradezema/screens/audio_home.dart';
import 'package:muradezema/screens/welcome_screen.dart';
import 'package:muradezema/utils/user_prefs.dart';

import '../commons/custom_text.dart';
import 'books_home.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    bool isLoggedIn = HivePrefs.getBool("isLoggedIn")??false;
    Timer(const Duration(seconds: 3), () {
      if(isLoggedIn){
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BookHomeScreen()),
        (Route<dynamic> route) => false
      );
      } else {
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => WelcomePage()),
      );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png', 
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const CustomText('Murade Zema', fontSize: 24, fontWeight: FontWeight.bold),
            const SizedBox(height: 10),
             LoadingAnimationWidget.inkDrop(
                    color: Colors.orange,
                    size: 30.h,
                  ),
          ],
        ),
      ),
    );
  }
}