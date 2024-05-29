import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_volunteer/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.green,
      textTheme: GoogleFonts.manropeTextTheme(),
    ),
    home: const SplashScreen(),
  ));
}
