import 'package:flutter/material.dart';
import 'package:go_volunteer/screens/signup.dart';

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
  bool _isAgreedTerms = false;


  void onSignUpButtonHandler() {
    setState(() {
      email = emailController.text;
      password = passwordController.text;
     
    });
    try {
      if(email.isEmpty || password.isEmpty || !_isAgreedTerms){
        errorText = 'All fields must be filled and agreed to the terms';
      }else {
        print('Successfully logged in');
      }     
    } catch (e) {
      print(e);
    }

  }
  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Email Address',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
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
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Password',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
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
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right:20.0,top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Forget Password ?')
                  ],
                ),
              ),
               Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 30.0),
                child: Text(
                  errorText,
                  style: TextStyle(color: Colors.red),
                ),
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
              Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, top: 5.0, bottom: 5.0),
                child: Row(
                  children: [
                    Text(
                      "Don'nt  have an account ? ",
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
              Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onSignUpButtonHandler,
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF04BF68),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(20.0),
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
                        Container(
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
                        SizedBox(width: 10),
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
          ),
        ),
      ),
    );
  }
}
