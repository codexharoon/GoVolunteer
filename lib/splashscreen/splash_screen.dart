import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_volunteer/auth/auth_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0;

    Future.delayed(
      const Duration(milliseconds: 2000),
      () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AuthScreen()));
      },
    );
    return Scaffold(
      backgroundColor: const Color(0xFF04BF68),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-2.png',
            ),
            // const SizedBox(height: 20),
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
