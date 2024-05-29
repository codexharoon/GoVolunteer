import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_volunteer/screens/auth_screen.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatefulWidget {
  @override
  AuthCheckerState createState() => AuthCheckerState();
}

class AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  Widget _initialScreen = const SplashScreen();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection, navigate to AuthScreen
      setState(() {
        _initialScreen = const SplashScreen();
        _isLoading = false;
      });
    } else {
      // Online mode, check Firebase user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userEmail = prefs.getString('userEmail');

        if (userEmail != null) {
          setState(() {
            _initialScreen = HomeScreen(user: user);
            _isLoading = false;
          });
        } else {
          setState(() {
            _initialScreen = const SplashScreen();
            _isLoading = false;
          });
        }
      } else {
        // User is not logged in, show SplashScreen then navigate to AuthScreen
        setState(() {
          _initialScreen = const SplashScreen();
        });

        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _initialScreen = const AuthScreen();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const SplashScreen() : _initialScreen;
  }
}
