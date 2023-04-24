import 'package:flutter/material.dart';
import 'package:nebula_team_manager/Pages/LoginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> signOut(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.remove('uid').then((value) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  });
}

Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  return await _auth.signInWithEmailAndPassword(
    email: email.trim(),
    password: password.trim(),
  );
}

Future<void> saveUidToPrefs(User? user) async {
  if (user != null && user.uid != null) {
    String uid = user.uid!;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
  }
}


