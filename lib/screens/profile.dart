import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_volunteer/components/custom_snack_bar.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/screens/login.dart';
import 'package:go_volunteer/screens/user_rides.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:go_volunteer/utilities/fetch_user_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  dynamic user;
  ProfilePage({super.key, required this.user});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late String imageUrl = '';
  late String name = '';
  late String phoneNumber = '';
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;
  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

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
    // Check the permission status for accessing photos
    var permissionStatus = await Permission.manageExternalStorage.status;

    // Request permission if it is denied or restricted
    if (permissionStatus.isDenied || permissionStatus.isRestricted) {
      final Map<Permission, PermissionStatus> statuses =
          await [Permission.manageExternalStorage].request();
      if (statuses[Permission.manageExternalStorage]!.isDenied) {
        showCustomSnackbar(context, 'Storage permission denied');
        return;
      } else if (statuses[Permission.manageExternalStorage]!
          .isPermanentlyDenied) {
        // Direct the user to app settings if permission is permanently denied
        showCustomSnackbar(context,
            'Storage permission is permanently denied. Please enable it in the app settings.');
        openAppSettings();
        return;
      }
    }

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

  Future<void> signOut() async {
    setLoading(true);
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    setLoading(false);
    showCustomSnackbar(context, 'Signing out ...');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (builder) => const Login()));
  }

  void onUpdateProfileButtonHandler() async {
    if (!_formKey.currentState!.validate()) {
      showCustomSnackbar(context, 'Please fill the form fields and Try again');
      return;
    }
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
              child: Form(
                key: _formKey,
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
                    const Text(
                      "**Please hold off on updating your profile until you see the message 'Image picked and stored in the database'. Thanks for your patience!**",
                      style: const TextStyle(
                          color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintText: name.isNotEmpty ? name : 'name',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Name field cannot be empty';
                          }

                          return null;
                        }),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: phoneNumber.isNotEmpty
                              ? phoneNumber
                              : 'phoneNumber',
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Phone field cannot be empty!';
                          }

                          return null;
                        }),
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
                            'Update Profile',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => UserRides(
                                      user: widget.user,
                                    )));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFD97365),
                        ),
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            'My Rides',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: signOut,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.red,
                        ),
                        width: double.infinity,
                        child: const Center(
                          child: Text(
                            'Sign out',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
