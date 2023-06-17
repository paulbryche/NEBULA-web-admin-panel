import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Services/FirebaseServices.dart';
import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

import '../Utilities/Classes.dart';
import '../Utilities/UserPage.dart';
import '../Utilities/TeamTableScreen.dart';

import 'TeamMembers.dart';
import 'FreeUsersPage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key? key}) : super (key: key);

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  //actualUserData[0] = Team, [1] = UserType
  List<String> actualUserData = ['', ''];
  List<NebulaUser> userList = []; // List to store fetched users
  List<NebulaTeamSubscriptions> teamSubscriptions = [];

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
    var usersResponse = await http.get(apiUrl);

    // Fetch subscriptions collection from the API
    final subscriptionsApiUrl = Uri.parse('http://127.0.0.1:8000/nebula_subscriptions');
    var subscriptionsResponse = await http.get(subscriptionsApiUrl);

    if (usersResponse.statusCode == 200 && subscriptionsResponse.statusCode == 200) {
      List<dynamic> usersResponseBody = jsonDecode(usersResponse.body);
      List<dynamic> subscriptionsResponseBody = jsonDecode(subscriptionsResponse.body);

      List<NebulaUser> users = getUsersFromDynamicList(usersResponseBody);
      for (var i in users) {
        print(i.SubType);
      }
      List<NebulaSubscription> nebulaSubscription = getNebulaSubscription(subscriptionsResponseBody);
      for (var i in nebulaSubscription) {
        print(i.Name);
      }
      List<NebulaTeamSubscriptions> yourTeamSubscriptions = getTeamSubscriptions(users, nebulaSubscription);

      setState(() {
        userList = users;
        teamSubscriptions = yourTeamSubscriptions;
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
            child: buildBillTable(teamSubscriptions),
          )
      );
    }
  }
}