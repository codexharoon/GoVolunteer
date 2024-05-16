import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_volunteer/splashscreen/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
}
