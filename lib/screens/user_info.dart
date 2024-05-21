import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_volunteer/screens/login.dart';
import 'package:go_volunteer/screens/user_rides.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserInfoPage extends StatefulWidget {
  dynamic user;
  UserInfoPage({super.key, required this.user});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  String? imageUrl;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF04BF68),
        body: Container(
          margin:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey,
                        // backgroundImage: _imageFile != null
                        //     ? FileImage(_imageFile!)
                        //     : imageUrl != null
                        //         ? NetworkImage(imageUrl!)
                        //         : null,
                        child: _imageFile == null && imageUrl == null
                            ? const Icon(Icons.camera_alt,
                                size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(context, MaterialPageRoute(builder: (builder) => Signup()));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFF04BF68),
                        ),
                        width: double.infinity,
                        child: const Center(
                            child: Text(
                          'Save Details',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        )),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
