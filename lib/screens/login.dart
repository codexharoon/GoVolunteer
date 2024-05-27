import 'package:flutter/material.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:go_volunteer/screens/home.dart';
import 'package:go_volunteer/components/custom_snack_bar.dart';
import 'package:go_volunteer/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  void setLoading(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  String email = '';
  String password = '';
  String errorText = '';

  bool _isPasswordVisible = false;

  void onSignInButtonHandler() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        email = emailController.text;
        password = passwordController.text;
        errorText = '';
      });
    }
    try {
      setLoading(true);
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
      String errorMessage = 'An error occurred. Please try again.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          case 'user-disabled':
            errorMessage =
                'The user corresponding to the given email has been disabled.';
            break;
          case 'user-not-found':
            errorMessage = 'There is no user corresponding to the given email.';
            break;
          case 'wrong-password':
            errorMessage = 'The password is invalid for the given email.';
            break;
          default:
            errorMessage = 'An undefined error occurred.';
        }
      }
      setState(() {
        errorText = errorMessage;
      });
      showCustomSnackbar(context, 'An error occurred: $errorMessage');
    } finally {
      setLoading(false);
    }
  }

  Future<void> onGoogleSignInHandler() async {
    setLoading(true);
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
        // Navigate to the home page
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
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
    } finally {
      setLoading(false);
    }
  }

  Future<void> onGitHubSignInHandler() async {
    try {
      setLoading(true);
      print('Starting GitHub sign-in handler...');
      FirebaseAuth auth = FirebaseAuth.instance;

      // Configure GitHub sign-in
      final GitHubSignIn gitHubSignIn = GitHubSignIn(
        clientId: 'Ov23li2kwT8DFDdzpd33',
        clientSecret: '88c6ddd28eb39ea0e72550dbad48c236a1325324',
        redirectUrl:
            'https://go-volunteer-ba404.firebaseapp.com/__/auth/handler',
      );

      // Triggering the authentication flow
      var result = await gitHubSignIn.signIn(context);

      switch (result.status) {
        case GitHubSignInResultStatus.ok:
          print('GitHub user signed in successfully.');
          print('Access Token: ${result.token}');

          // Obtain the auth details from the request
          final AuthCredential credential =
              GithubAuthProvider.credential(result.token!);

          // Sign in the user with the credential
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          print('User signed in with GitHub credential.');

          // Access the user information
          final User? user = userCredential.user;
          print(user);
          if (user != null) {
            // Check if user already exists in Firestore
            final userRef =
                FirebaseFirestore.instance.collection('users').doc(user.uid);
            final userData = await userRef.get();
            print('User data retrieved from Firestore.');

            if (!userData.exists) {
              await userRef.set({
                'name': user.displayName,
                'email': user.email,
                'phone': '123-456-7890',
                'imageUrl': user.photoURL,
              });

              print('User profile created successfully in Firestore.');
            } else {
              showCustomSnackbar(context, 'Welcome back, ${user.displayName}!');
            }

            // Navigate to the home page
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(user: user)));
          } else {
            showCustomSnackbar(context,
                'GitHub sign-in failed. No user information available.');
          }
          break;

        case GitHubSignInResultStatus.cancelled:
          showCustomSnackbar(context, 'GitHub sign-in was canceled.');
          break;

        case GitHubSignInResultStatus.failed:
          showCustomSnackbar(context,
              'GitHub sign-in failed. Please try again. Error: ${result.errorMessage}');
          break;
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
                'Operation not allowed. Please enable GitHub sign-in in the Firebase console.';
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
    } finally {
      setLoading(false);
    }
  }

  // Future<void> onFacebookSignInHandler() async {
  //   try {
  //     print('Starting Facebook sign-in handler...');
  //     FirebaseAuth auth = FirebaseAuth.instance;

  //     // Triggering the authentication flow
  //     final result = await FacebookAuth.instance.login(
  //       permissions: ['email', 'public_profile'],
  //     );

  //     switch (result.status) {
  //       case LoginStatus.success:
  //         print('Facebook user signed in successfully.');

  //         // Obtain the auth details from the request
  //         final AccessToken accessToken = result.accessToken!;
  //         final AuthCredential credential =
  //             FacebookAuthProvider.credential(accessToken.tokenString);

  //         // Sign in the user with the credential
  //         final UserCredential userCredential =
  //             await auth.signInWithCredential(credential);
  //         print('User signed in with Facebook credential.');

  //         // Access the user information
  //         final User? user = userCredential.user;
  //         print(user);
  //         if (user != null) {
  //           // Check if user already exists in Firestore
  //           final userRef =
  //               FirebaseFirestore.instance.collection('users').doc(user.uid);
  //           final userData = await userRef.get();
  //           print('User data retrieved from Firestore.');

  //           if (!userData.exists) {
  //             await userRef.set({
  //               'name': user.displayName,
  //               'email': user.email,
  //               'phone': '123-456-7890',
  //               'imageUrl': user.photoURL,
  //             });

  //             print('User profile created successfully in Firestore.');
  //           } else {
  //             showCustomSnackbar(context, 'Welcome back, ${user.displayName}!');
  //           }

  //           // Navigate to the home page
  //           Navigator.pushReplacement(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => HomeScreen(user: user)));
  //         } else {
  //           showCustomSnackbar(context,
  //               'Facebook sign-in failed. No user information available.');
  //         }
  //         break;
  //       case LoginStatus.cancelled:
  //         showCustomSnackbar(context, 'Facebook sign-in was canceled.');
  //         break;
  //       case LoginStatus.failed:
  //         showCustomSnackbar(
  //             context, 'Facebook sign-in failed. Please try again.');
  //         break;
  //       default:
  //         showCustomSnackbar(context, 'Facebook sign-in in progress.');
  //         break;
  //     }
  //   } catch (e) {
  //     String errorMessage;
  //     if (e is FirebaseAuthException) {
  //       switch (e.code) {
  //         case 'account-exists-with-different-credential':
  //           errorMessage =
  //               'The account already exists with a different credential.';
  //           break;
  //         case 'invalid-credential':
  //           errorMessage = 'The credential is invalid or expired.';
  //           break;
  //         case 'operation-not-allowed':
  //           errorMessage =
  //               'Operation not allowed. Please enable Facebook sign-in in the Firebase console.';
  //           break;
  //         case 'user-disabled':
  //           errorMessage = 'This user has been disabled.';
  //           break;
  //         case 'user-not-found':
  //           errorMessage = 'No user found for this email.';
  //           break;
  //         case 'wrong-password':
  //           errorMessage = 'Wrong password provided.';
  //           break;
  //         default:
  //           errorMessage = 'An undefined error occurred.';
  //       }
  //     } else {
  //       errorMessage = 'An unknown error occurred.';
  //     }
  //     showCustomSnackbar(context, errorMessage);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                child: Form(
                    key: _formKey,
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
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: const Text(
                            'Email Address',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                            padding:
                                const EdgeInsets.only(left: 10.0, right: 10.0),
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
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: const Text(
                            'Password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
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
                          padding:
                              const EdgeInsets.only(right: 10.0, left: 10.0),
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
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 10.0),
                          child: Row(
                            children: [
                              Text(
                                "Don't  have an account ? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => Signup()));
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
                                  // const SizedBox(width: 10),
                                  // GestureDetector(
                                  //   onTap: onFacebookSignInHandler,
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       borderRadius: BorderRadius.circular(25),
                                  //     ),
                                  //     child: CircleAvatar(
                                  //       backgroundColor: Color(0xFFFFFFFF),
                                  //       radius: 25,
                                  //       child: Image.asset(
                                  //         'assets/images/facebook-icon.png',
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  const SizedBox(width: 10.0),
                                  GestureDetector(
                                    onTap: onGitHubSignInHandler,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: Color(0xFFFFFFFF),
                                        radius: 25,
                                        child: Image.asset(
                                          'assets/images/github_icon.png',
                                        ),
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
