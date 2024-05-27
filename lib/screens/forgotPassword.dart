import 'package:flutter/material.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white.withOpacity(0),
      ),
      body: const Center(

        child: Padding(padding: const EdgeInsets.all(10.0),
        child:  Text("Dobara yad karein! Yad ajayega In Sha Allah ",style: TextStyle(fontSize: 40.0,color: Colors.green)),),
        
      )
    );
  }
  
}