import 'package:flutter/material.dart';
import 'package:nebula_team_manager/Services/PopUp.dart';
import 'package:nebula_team_manager/TeamMembers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Services/UserServices.dart';
import 'Services/Logs.dart';
import 'Classes.dart';

class FreeUsersPage extends StatefulWidget {
  const FreeUsersPage({Key? key}) : super (key: key);

  @override
  _FreeUsersPageState createState() => _FreeUsersPageState();
}

class _FreeUsersPageState extends State<FreeUsersPage> {
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
    await FirebaseFirestore.instance.collection('Users').where('Team', isEqualTo: '').get();

    // Loop through the documents in the collection
    List<NebulaUser> users = getUsersFromQuerySnapshot(querySnapshot);

    // Update the state with the fetched users
    setState(() {
      userList = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (actualUserData[1] =='User') {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepPurple[600],
            title: const Text('Nebula Manager'),
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
            child: Column(
              children: [
                Row(
                  children: const [
                    Text('Nothing to see here. You can logout.'),
                  ],
                )
              ],
            ),
          )
      );
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
                          primary: Colors.deepPurple, // Change button color here
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