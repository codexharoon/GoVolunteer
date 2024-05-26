import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_volunteer/components/custom_snack_bar.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/utilities/fetch_user_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
// import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class UserInfoPage extends StatefulWidget {
  final dynamic user;
  UserInfoPage({Key? key, required this.user}) : super(key: key);

  @override
  UserInfoPageState createState() => UserInfoPageState();
}

class UserInfoPageState extends State<UserInfoPage> {
  late String imageUrl = '';
  late String name = '';
  late String phoneNumber = '';
  String? uid = FirebaseAuth.instance.currentUser?.uid;
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      Map<String, dynamic> userData = await fetchUserData();
      setState(() {
        imageUrl = userData['imageUrl'] ?? '';
        name = userData['name'] ?? '';
        phoneNumber = userData['phone'] ?? '';
      });

      // Update text controllers with fetched data
      _nameController.text = name;
      _phoneController.text = phoneNumber;
    });
  }

  Future<void> imagePickerHanlder() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Do something with the picked image, for example, set it to a state variable
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Store the image in Firebase Storage
      final Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('images/${path.basename(pickedFile.path)}');

      final UploadTask uploadTask = firebaseStorageRef.putFile(_imageFile!);

      final TaskSnapshot downloadUrl = (await uploadTask.whenComplete(() {}));

      final String url = await downloadUrl.ref.getDownloadURL();

      // Update the imageUrl field with the URL provided by Firebase Storage
      setState(() {
        imageUrl = url;
      });

      // Show a snackbar after successful image uploading
      showCustomSnackbar(context, 'Image is picked stored in storage');
    } else {
      imageUrl = '';
    }
  }

  void onUpdateProfileButtonHandler() async {
    setState(() {
      name = _nameController.text;
      phoneNumber = _phoneController.text;
    });
    try {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'imageUrl': imageUrl,
        'name': name,
        'phone': phoneNumber,
      });
      Map<String, dynamic> userData = await fetchUserData();
      setState(() {
        _nameController.clear();
        _phoneController.clear();
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: userData)));
      showCustomSnackbar(context, 'User profile updated successfully');
    } catch (e) {
      showCustomSnackbar(context, '$e.code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04BF68),
      body: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
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
                    onTap: imagePickerHanlder,
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.grey,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider<Object>
                          : imageUrl.isNotEmpty
                              ? NetworkImage(imageUrl)
                              : null,
                      child: _imageFile == null && imageUrl.isEmpty
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
                      hintText: 'name',
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
                      hintText: 'phoneNumber',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: onUpdateProfileButtonHandler,
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
      ),
    );
  }
}
