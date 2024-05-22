import 'package:flutter/material.dart';
import 'package:go_volunteer/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_volunteer/components/custom_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';
import 'package:go_volunteer/screens/user_info.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String email = '';
  String password = '';
  String confirmPassword = '';

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isAgreedTerms = false;
  String errorText = '';
  String passwordStrength = '';
  String emailValidator = '';
  String passwordLength = '';

  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
    multiLine: false,
  );

  void onSignUpButtonHandler() async {
    setState(() {
      email = emailController.text;
      password = passwordController.text;
      confirmPassword = confirmPasswordController.text;
      emailValidator = '';
      passwordLength = '';
      errorText = '';
    });

    // Checking if any field is empty or terms are not agreed
    if (!_isAgreedTerms) {
      setState(() {
        errorText = 'You must agreed to the terms';
      });
      return;
    }

    // Checking if passwords match
    if (password != confirmPassword) {
      setState(() {
        errorText = 'Password and confirm password must be the same';
      });
      return;
    }

    // Validating email format
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailValidator = 'Invalid Email';
      });
      return;
    }

    // Checking password length
    if (password.length < 8) {
      setState(() {
        passwordLength = 'Password length should be greater than 8 characters';
      });
      return;
    }
    try {
      // Check if the email already exists in Firestore
      final userRef = FirebaseFirestore.instance.collection('users');
      final querySnapshot =
          await userRef.where('email', isEqualTo: email).get();

      if (querySnapshot.docs.isNotEmpty) {
        showCustomSnackbar(context,
            'The email is already registered. Please use a different email.');
        return;
      }

      // Create a new user with Firebase Authentication
    // If all validations pass, try to create a new user
    try {

      final newUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (newUser.user != null) {
        // Generate a random number for the guest name
        final random = Random();
        final randomNumber =
            random.nextInt(1000); // Generates a number between 0 and 999
        // Store user information in Firestore with defaults
        await userRef.doc(newUser.user!.uid).set({
          'email': email,
          'name': 'Guest.$randomNumber',
          'phone': '123-456-7890',
          'imageUrl': 'https://example.com/dummy-image.jpg',
        }).then((_) {
          print('User data stored in Firestore successfully');
        }).catchError((error) {
          print('Error storing user data: $error');
          showCustomSnackbar(context, 'Error storing user data: $error');
        });

        setState(() {
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          passwordStrength = '';
          _isAgreedTerms = false;
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.user?.uid)
            .set({
          'email': email,
        }).then((_) {
          print('User data stored in Firestore successfully');
        }).catchError((error) {
          print('Error storing user data: $error');
        });
        // Show Snackbar
        showCustomSnackbar(context, 'User profile created successfully!');
        // Optionally navigate to the Login screen
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      }
    } catch (e) {
      // Handle Firebase errors
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            showCustomSnackbar(context,
                'The email address is already in use by another account.');
            break;
          case 'invalid-email':
            showCustomSnackbar(context, 'The email address is not valid.');
            break;
          case 'operation-not-allowed':
            showCustomSnackbar(
                context, 'Email/password accounts are not enabled.');
            break;
          case 'weak-password':
            showCustomSnackbar(context, 'The password is too weak.');
            break;
          default:
            showCustomSnackbar(context, 'An error occurred: ${e.message}');
        }
      } else {
        showCustomSnackbar(context, 'An error occurred: ${e.toString()}');
      }
            MaterialPageRoute(
                builder: (context) => UserInfoPage(
                      user: newUser.user,
                    )));
      }
    } catch (e) {
      print(e);
    }
  }

  void updatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        passwordStrength = '';
      });
      return;
    }

    bool hasNumber = password.contains(RegExp(r'\d'));
    bool hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasSpecialCharacters =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.length >= 8 &&
        hasNumber &&
        hasLetter &&
        hasSpecialCharacters) {
      setState(() {
        passwordStrength = 'Strong';
      });
    } else if (password.length >= 8 && (hasNumber || hasLetter)) {
      setState(() {
        passwordStrength = 'Medium';
      });
    } else {
      setState(() {
        passwordStrength = 'Weak';
      });
    }
  }

  Future<void> onGoogleSignInHandler() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Triggering the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        showCustomSnackbar(context, 'Google sign-in was canceled.');
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in the user with the credential
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);

      // Access the user information
      final User? user = userCredential.user;
      if (user != null) {
        // Check if user already exists in Firestore
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userData = await userRef.get();

        if (!userData.exists) {
          // If user does not exist, store user information in Firestore
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'phone': '123-456-7890',
            'imageUrl': user.photoURL,
          });
          showCustomSnackbar(context, 'User profile created successfully!');
        } else {
          showCustomSnackbar(context, 'Welcome back, ${user.displayName}!');
        }
      } else {
        showCustomSnackbar(
            context, 'Google sign-in failed. No user information available.');
      }
    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            errorMessage =
                'The account already exists with a different credential.';
            break;
          case 'invalid-credential':
            errorMessage = 'The credential is invalid or expired.';
            break;
          case 'operation-not-allowed':
            errorMessage =
                'Operation not allowed. Please enable Google sign-in in the Firebase console.';
            break;
          case 'user-disabled':
            errorMessage = 'This user has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'No user found for this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An undefined error occurred.';
        }
      } else {
        errorMessage = 'An unknown error occurred.';
      }
      showCustomSnackbar(context, errorMessage);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: const Text(
                    'Create your new account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: const Text(
                    'Email Address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          borderSide: BorderSide(
                            width: 1.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Email field cannot be empty';
                        }
                        return null;
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: Text(
                    emailValidator,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextFormField(
                    onChanged: (value) {
                      updatePasswordStrength(value);
                    },
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      suffixText: passwordStrength.isNotEmpty
                          ? '($passwordStrength)'
                          : '',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password field cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    passwordLength,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                const Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    'Confirm Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password again',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          width: 1.0,
                          color: Colors.grey,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Confirm password field cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Text(
                    errorText,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  children: [
                    Checkbox(
                      fillColor: MaterialStateProperty.all(Color(0xFF04BF68)),
                      value: _isAgreedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreedTerms = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAgreedTerms = !_isAgreedTerms;
                          });
                        },
                        child: Text(
                          "I've read and agreed with User Agreement and Privacy Policy",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: Row(
                    children: [
                      const Text(
                        'Already have an account ? ',
                        style: TextStyle(color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (builder) => Login()));
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onSignUpButtonHandler,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF04BF68),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(15.0),
                      ),
                      child: Text('Signup'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Center(
                    child: Column(children: [
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text('Other ways to signup'),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: onGoogleSignInHandler,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Color(0xFFFFFFFF),
                            radius: 25,
                            child: Image.asset(
                              'assets/images/google-icon.png',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Color(0xFFFFFFFF),
                          radius: 25,
                          child: Image.asset(
                            'assets/images/facebook-icon.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                ]))
              ],
            ),
          ),
        ),
      ),
    );
  }
}