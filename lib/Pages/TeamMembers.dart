import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Services/FirebaseServices.dart';
import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilities/Classes.dart';
import '../Utilities/PopUp.dart';
import '../Utilities/UserPage.dart';

import 'AdminPage.dart';
import 'FreeUsersPage.dart';
import 'PaymentPage.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({Key? key}) : super (key: key);

  @override
  TeamMembersPageState createState() => TeamMembersPageState();
}

class TeamMembersPageState extends State<TeamMembersPage> {
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
    var actualUserTeam = actualUserData[0];
    // Fetch users collection from the API with a query
    final apiUrl = Uri.parse('http://127.0.0.1:8000/nebula_users/called_teammembers?Team=$actualUserTeam');
    var response = await http.get(apiUrl);
    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      List<NebulaUser> users = getUsersFromDynamicList(responseBody);
      if (actualUserData[1] == 'Admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const AdminPage(),
          ),
        );
      }
      setState(() {
        userList = users;
      });
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
            title: Text('Nebula Manager - TeamMembers - Your Team: ${actualUserData[0]}'),
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
                            teamLeaderUpdateUser(user, context, fetchUsers);
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
}