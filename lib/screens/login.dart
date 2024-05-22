import 'package:flutter/material.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/components/custom_snack_bar.dart';
import 'package:go_volunteer/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String email = '';
  String password = '';
  String errorText = '';

  bool _isPasswordVisible = false;

  void onSignInButtonHandler() async {
    setState(() {
      email = emailController.text;
      password = passwordController.text;
      errorText = '';
    });

    // Check if fields are empty or terms are not agreed
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'All fields must be filled';
      });
    }

    try {
      final loggedinUser = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      if (loggedinUser.user != null) {
        showCustomSnackbar(context, 'You are logged in!');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      user: loggedinUser.user,
                    )));
      }
    } catch (e) {
      setState(() {
        errorText = e.toString(); // Display the error message
      });
      showCustomSnackbar(context, 'An error occurred: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004643),
                  ),
                ),
              ),
              const SizedBox(height: 15),
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
                      prefixIcon: const Icon(Icons.email),
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
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Enter your password',
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
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
                child: Text(
                  errorText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forget Password ?',
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                child: Row(
                  children: [
                    Text(
                      "Don't  have an account ? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (builder) => Signup()));
                      },
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0, left: 10.0),
                child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onSignInButtonHandler,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF04BF68),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(15.0),
                      ),
                      child: Text('Login'),
                    )),
              ),
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text('Other ways to Sign in'),
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
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
