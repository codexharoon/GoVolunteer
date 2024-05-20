import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: HomeScreen(),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
