import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Services/FirebaseServices.dart';
import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilities/Classes.dart';
import '../Utilities/PopUp.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super (key: key);

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  //actualUserData[0] = Team, [1] = UserType
  List<String> actualUserData = ['', ''];
  List<NebulaUser> userList = []; // List to store fetched users

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  void fetchUsers() async {
    actualUserData = await getActualUserDataFromFirestore();
    try {
      final apiUrl = Uri.parse('http://127.0.0.1:8000/nebula_users');
      var response = await http.get(apiUrl);
      if (response.statusCode == 200) {
        List<dynamic> responseBody = jsonDecode(response.body);
        List<NebulaUser> users = getUsersFromDynamicList(responseBody);
        setState(() {
          userList = users;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple[600],
            title: const Text('Nebula Manager - Admin Page'),
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      signOut(context);
                      // You can add additional code here, such as navigating to a login page
                    },
                  ),
                  const Text('Logout'),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body:
          CustomPaint(
            painter: CurvePainter(),
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    NebulaUser user = userList[index];
                    return ListTile(title: Text(user.Name),
                      subtitle: Text(user.Email),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple, // Change button color here
                        ),
                        onPressed: () {
                          if (actualUserData[1] == 'Admin') {
                            adminUpdateUser(user, context, fetchUsers);
                          } else {
                            showDialogWithErrorMessage("You Don't have the permission for that", context);
                          }
                        },
                        child: const Icon(Icons.update),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
      );
    }
}
