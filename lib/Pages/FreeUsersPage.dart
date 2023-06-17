import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Services/FirebaseServices.dart';
import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilities/Classes.dart';
import '../Utilities/UserPage.dart';
import '../Utilities/PopUp.dart';

import 'TeamMembers.dart';
import 'PaymentPage.dart';

class FreeUsersPage extends StatefulWidget {
  const FreeUsersPage({Key? key}) : super (key: key);

  @override
  FreeUsersPageState createState() => FreeUsersPageState();
}

class FreeUsersPageState extends State<FreeUsersPage> {
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
      final apiUrl = Uri.parse('http://127.0.0.1:8000/nebula_users/without_team');
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
    Widget screen;
    if (actualUserData[1] == 'User') {
      screen = buildUserScreen(context);
      return screen;
    } else {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple[600],
            title: const Text('Nebula Manager - Users Without Team'),
            actions: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_business),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const FreeUsersPage(),
                        ),
                      );
                    },
                  ),
                  const Text('Users Without Team'),
                ],
              ),
              const SizedBox(height: 10), // Add a SizedBox to create space between rows
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.business_outlined),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const TeamMembersPage(),
                        ),
                      );
                    },
                  ),
                  const Text('Team Members'),
                ],
              ),
              const SizedBox(height: 10), // Add a SizedBox to create space between rows
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.info),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const PaymentPage(),
                        ),
                      );
                    },
                  ),
                  const Text('Team Infos'),
                ],
              ),
              const SizedBox(height: 10), // Add a SizedBox to create space between rows
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
                          if (actualUserData[1] == 'TeamLeader') {
                            addUser(user,context, actualUserData[0], fetchUsers);
                          } else {
                            showDialogWithErrorMessage("You don't have the permission for that", context);
                          }
                        },
                        child: const Icon(Icons.add),
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
}