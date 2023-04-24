import 'package:flutter/material.dart';
import 'package:nebula_team_manager/Services/PopUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Services/UserServices.dart';
import 'Services/Logs.dart';

import 'Services/CustomPainter.dart';
import 'Classes.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super (key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  //actualUserData[0] = Team, [1] = UserType
  List<String> actualUserData = ['', ''];
  List<NebulaUser> userList = []; // List to store fetched users

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  void fetchUsers() async {
    actualUserData = await getAcualUserDataFromFirestore();

    // Fetch users collection from Firestore with a query
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Users').get();

    // Loop through the documents in the collection
    List<NebulaUser> users = getUsersFromQuerySnapshot(querySnapshot); // Temporary list to store fetched users

    // Update the state with the fetched users
    setState(() {
      userList = users;
    });
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
