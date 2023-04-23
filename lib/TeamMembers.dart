import 'package:flutter/material.dart';
import 'package:nebula_team_manager/FreeUsersPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'Services/Logs.dart';
import 'Services/PopUp.dart';

import 'Classes.dart';
import 'AdminPage.dart';

class TeamMembersPage extends StatefulWidget {
  const TeamMembersPage({Key? key}) : super (key: key);

  @override
  _TeamMembersPageState createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {
  List<NebulaUser> userList = []; // List to store fetched users
  String userTeam = '';
  String userType = '';

  @override
  void initState() {
    super.initState();
    fetchUsers(); // Fetch users when the widget is initialized
  }

  void fetchUsers() async {
    //get user UID
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('uid');

    //get user data from firestore
    QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('Users').where('UserId', isEqualTo: uid).get();
    if (querySnapshot.docs.isNotEmpty) {
      // Access the first document in the querySnapshot
      QueryDocumentSnapshot doc = querySnapshot.docs.first;
      userTeam = doc['Team'];
      userType = doc['UserType'];

      if (userType == 'Admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdminPage(),
          ),
        );
      }

    // Fetch users collection from Firestore with a query
    querySnapshot =
    await FirebaseFirestore.instance.collection('Users').where('Team', isEqualTo: userTeam).where('Team', isNotEqualTo: '').get();

    // Loop through the documents in the collection
    List<NebulaUser> users = []; // Temporary list to store fetched users
    querySnapshot.docs.forEach((doc) {
      // Access document fields using doc['field_name']
      String userId = doc['UserId'];
      String name = doc['Name'];
      String email = doc['Email'];
      String userType = doc['UserType'];
      String team = doc['Team'];
      String subtype = doc['SubType'];

      // Create User objects and add to the temporary list
      NebulaUser user = NebulaUser(
        UserId: userId,
        Name: name,
        Email: email,
        UserType: userType,
        Team: team,
        SubType: subtype,
      );
      users.add(user);
    });

    // Update the state with the fetched users
    setState(() {
      userList = users;
    });
  }
  }

  void updateUserFunc(NebulaUser user) async {
    try {
      // Get a reference to the user document in Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').where('UserId', isEqualTo: user.UserId).limit(1).get();

      // Create a map with the updated data
      Map<String, dynamic> updatedData = {
        'Name': user.Name,
        'UserType': user.UserType,
        'UserId': user.UserId,
        'Email': user.Email,
        'Team': user.Team,
        'SubType': user.SubType,
      };

      // Update the user document in Firestore
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(updatedData);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Updated')),
      );
    } catch (e) {
      showDialogWithErrorMessage('An error occurred', context);
    }
  }

  void updateUser(NebulaUser user) async {
    String username = user.Name;
    String subtype = user.SubType;
    List<String> subtypes = ['Basic', 'Medium', 'Premium'];
    String usertype = user.UserType;
    List<String> usertypes = ['User', 'TeamLeader'];

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: user.Name,
                  ),
                  onChanged: (value) {
                    setState(() {
                      username = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: subtype,
                  items: subtypes.map((subs) {
                    return DropdownMenuItem(
                      value: subs,
                      child: Text(subs),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      subtype = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: usertype,
                  items: usertypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      usertype = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete Membership'),
                onPressed: () {
                  if (userType == 'TeamLeader') {
                    deleteUser(user);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Error'),
                        content: const Text("You Don't have the permission for that"),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              TextButton(
                child: const Text('Update'),
                onPressed: () {
                  NebulaUser updatedUser = NebulaUser(UserId: user.UserId, Name: username, Team: user.Team, Email: user.Email, SubType: subtype, UserType: usertype);
                  updateUserFunc(updatedUser);
                  Navigator.of(context).pop(); // Close the pop-up dialog
                },
              ),
            ],
          );
        });
    fetchUsers();
  }

  void deleteUserMembership(NebulaUser user) async {
    if (userType == 'User') {
      return (showDialogWithErrorMessage("You Don't have the permission for that", context));
    }
    try {
      // Get a reference to the user document in Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Users').where('UserId', isEqualTo: user.UserId).limit(1).get();

      // Create a map with the updated data
      Map<String, dynamic> updatedData = {
        'Name': user.Name,
        'UserType': user.UserType,
        'UserId': user.UserId,
        'Email': user.Email,
        'Team': '',
        'SubType': user.SubType,
      };

      // Update the user document in Firestore
      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update(updatedData);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Membership Deleted')),
      );
    } catch (e) {
      showDialogWithErrorMessage('An error occurred', context);
    }
  }

  void deleteUser(NebulaUser user) async {
    // Function to add a new user
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete User Membership'),
          content: Column(
            children: [
              Text(user.Name),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  //push database update
                  deleteUserMembership(user);
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    if (userType =='User') {
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
                          if (userType == 'TeamLeader') {
                            deleteUser(user);
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