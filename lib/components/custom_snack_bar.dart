import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String message, {String label = 'OK', VoidCallback? onPressed}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    action: SnackBarAction(
      label: label,
      textColor: Colors.white,
      onPressed: onPressed ?? () {},
    ),
    duration:const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
