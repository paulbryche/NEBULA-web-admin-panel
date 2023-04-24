import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Services/FirebaseServices.dart';
import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilitaries/Classes.dart';
import '../Utilitaries/UserPage.dart';
import '../Utilitaries/TeamTableScreen.dart';

import 'TeamMembers.dart';
import 'FreeUsersPage.dart';

class PayementPage extends StatefulWidget {
  const PayementPage({Key? key}) : super (key: key);

  @override
  _PayementPageState createState() => _PayementPageState();
}

class _PayementPageState extends State<PayementPage> {
  //actualUserData[0] = Team, [1] = UserType
  List<String> actualUserData = ['', ''];
  List<NebulaUser> userList = []; // List to store fetched users
  List<NebulaTeamSubscriptions> teamSubcriptions = [];

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  void fetchUsers() async {
    actualUserData = await getAcualUserDataFromFirestore();

    // Fetch users collection from Firestore with a query
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Users').where('Team', isEqualTo: actualUserData[0]).where('Team', isNotEqualTo: '').get();

    // Loop through the documents in the collection
    List<NebulaUser> users = getUsersFromQuerySnapshot(querySnapshot);

    querySnapshot =
    await FirebaseFirestore.instance.collection('Subscriptions').get();

    List<NebulaSubscription> nebulaSubscription = getNebulaSubscription(querySnapshot);
    print(nebulaSubscription[0].Name);
    print(nebulaSubscription[1].Name);
    print(nebulaSubscription[2].Name);
    List<NebulaTeamSubscriptions> yourTeamSubcriptions = getTeamSubscriptions( users, nebulaSubscription);

    // Update the state with the fetched users
    setState(() {
      userList = users;
      teamSubcriptions = yourTeamSubcriptions;
    });
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
            title: Text('Nebula Manager - Team Subcriptions - Your Team: ${actualUserData[0]}'),
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
                          builder: (context) => const PayementPage(),
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
            child: buildBillTable(teamSubcriptions),
          )
      );
    }
  }
}