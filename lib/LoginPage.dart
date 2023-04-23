import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'TeamMembers.dart';
import 'ResetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super (key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('uid', uid);
        }


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

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }
  Future<void> _resetPassword() async {
    showDialog(
      context: context,
      builder: (_) => PasswordResetDialog(),
    );
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
                Text('Sign into your accunt',
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
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                  ),
                  onPressed: _isLoading ? null : _signInWithEmailAndPassword,
                  child: const Text('Login'),
                ),
                const Padding(padding: EdgeInsets.all(25.0)),
                TextButton(
                  onPressed: _resetPassword,
                  child: const Text('Password Lost?'),
                ),
              ],
            ),
          ),
        ),
    ));
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.deepPurple;
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.875, size.width * 0.5, size.height * 0.9167);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9584, size.width * 1.0, size.height * 0.9167);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}