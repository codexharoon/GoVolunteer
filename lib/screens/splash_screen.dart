import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_volunteer/screens/auth_screen.dart';
import 'package:go_volunteer/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, navigate to AuthScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AuthScreen()));
    } else {
      // Online mode, check Firebase user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userEmail = prefs.getString('userEmail');

        if (userEmail != null) {
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
        } 
      } else {
        // User is not logged in, navigate to AuthScreen
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AuthScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04BF68),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-2.png',
            ),
            const Text(
              'Lets Travel Together',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
