import 'package:flutter/material.dart';
import 'package:go_volunteer/screens/login.dart';
import 'package:go_volunteer/screens/signup.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/auth-img.png',
            ),
            const SizedBox(height: 80),
            const Text(
              'Lets Travel Together',
              style: TextStyle(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 150),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder) => Signup()));
              },
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF04BF68),
                ),
                width: double.infinity,
                child: const Center(
                    child: Text(
                  'Sign up',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )),
              ),
            ),
            const SizedBox(height: 5),
            GestureDetector(
              onTap: () {
                 Navigator.push(context, MaterialPageRoute(builder: (builder) => Login()));
              },
              child: const SizedBox(
                width: double.infinity,
                child: Center(
                    child: Text(
                  'Sign in',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
