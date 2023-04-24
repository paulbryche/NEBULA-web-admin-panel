
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nebula_team_manager/Pages/LoginPage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBA9v2bdmBfIQ-PkbiixM9VRMMq4WiomB8",
        projectId: "nebula-team-management",
        messagingSenderId: "497279347858",
        appId: "1:497279347858:web:aa9eb6cadb2d0727f8ca4b")
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula Manager - Home Page',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginPage(),
    );
  }
}