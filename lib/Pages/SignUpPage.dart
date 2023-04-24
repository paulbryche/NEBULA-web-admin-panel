import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Services/CustomPainter.dart';

import '../Utilitaries/Classes.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _email, _password, _name;

  Future <void> _googleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Add user to Firestore with name and email
      FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'UserId' : FirebaseAuth.instance.currentUser!.uid,
        'Name': googleUser.displayName,
        'Email': googleUser.email,
        'UserType': 'User',
        'Team': '',
        'SubType': 'Basic',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during Google sign in: $e')),
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState != null) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        try {
          await Firebase.initializeApp();
          UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );

          // User is created successfully, add user to Firestore
          NebulaUser user = NebulaUser(
            UserId: userCredential.user!.uid,
            Name: _name!,
            Email: _email!,
            UserType: 'User',
            Team: '',
            SubType: 'Basic',
          );
          FirebaseFirestore.instance.collection('Users').doc().set({
            'UserId' : user.UserId,
            'Name': user.Name,
            'Email': user.Email,
            'UserType': user.UserType,
            'Team': user.Team,
            'SubType': user.SubType,
          });

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User is created successfully')),
          );
        } on FirebaseAuthException catch (e) {
          // Handle errors here
          if (e.code == 'weak-password') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The password provided is too weak.')),
            );
          } else if (e.code == 'email-already-in-use') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The account already exists for that email.')),
            );
          } else {
            String error = e.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          }
        } catch (e) {
          String error = e.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign In'),
        ),
        body:
        CustomPaint(
          painter: CurvePainter(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _name = value;
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Sign In'),
                  ),
                  SignInButton(
                    Buttons.Google,
                    onPressed: _googleSignUp,
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}