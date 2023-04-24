import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilitaries/PopUp.dart';
import '../Utilitaries/ResetPassword.dart';

import 'TeamMembers.dart';
import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super (key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLoggedIn(); // Check if the user is already logged in
  }

  void checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid'); // Fetch uid from local storage
    if (uid != null) {
      // If uid is present, user is already logged in
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => TeamMembersPage(),
        ),
      );
    }
  }

  void _signInWithEmailAndPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final UserCredential userCredential =
        await signInWithEmailAndPassword(
            _emailController.text, _passwordController.text);

        await saveUidToPrefs(userCredential.user);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const TeamMembersPage(),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found with this email';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Incorrect password';
        } else {
          errorMessage = e.message ?? 'An error occurred';
        }

        setState(() {
          _isLoading = false;
        });

        showDialogWithErrorMessage(errorMessage, context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: const Text('Nebula Manager - Login Page'),
      ),
      backgroundColor: Colors.white,
      body:
        CustomPaint(
          painter: CurvePainter(),
          child:Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Welcome to Nebula Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.deepPurple[600], fontSize: 30),
                ),
                const Padding(padding: EdgeInsets.all(10.0)),
                Text('Sign into your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.deepPurple[600], fontSize: 20),
                ),
                const Padding(padding: EdgeInsets.all(35.0)),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                const Padding(padding: EdgeInsets.all(25.0)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                        ),
                        onPressed: _isLoading ? null : _signInWithEmailAndPassword,
                        child: const Text('Login'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: SignInButton(
                        onPressed: () async {
                          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
                          final GoogleSignInAuthentication googleAuth =
                          await googleUser!.authentication;
                          final OAuthCredential credential = GoogleAuthProvider.credential(
                              accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
                          await FirebaseAuth.instance.signInWithCredential(credential);
                        },
                        Buttons.Google,
                        text: "Login in with Google",
                      ),
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.all(25.0)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => PasswordResetDialog(),
                        );
                      },
                      child: const Text('Password Lost?'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(),
                          ),
                        );
                        },
                      child: const Text('Sign in Here!'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ));
  }
}