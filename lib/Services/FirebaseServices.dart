import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Utilities/PopUp.dart';
import '../Utilities/Classes.dart';

List<NebulaSubscription> getNebulaSubscription(List<dynamic> querySnapshot) {
  List<NebulaSubscription> subscriptions = [];

  for (var doc in querySnapshot) {
    String name = doc['Name'];
    double price = doc['Price'];

    NebulaSubscription subscription = NebulaSubscription(
      Name: name,
      Price: price,
    );
    subscriptions.add(subscription);
  }
  return subscriptions;
}

List<NebulaTeamSubscriptions> getTeamSubscriptions(List<NebulaUser> userList, List<NebulaSubscription> nebulaSubscription) {
  List<NebulaTeamSubscriptions> teamSubscriptions = [
    NebulaTeamSubscriptions(
      Name: nebulaSubscription[0].Name,
      Quantity: 0,
      Price: nebulaSubscription[0].Price,
    ),
    NebulaTeamSubscriptions(
      Name: nebulaSubscription[1].Name,
      Quantity: 0,
      Price: nebulaSubscription[1].Price,
    ),
    NebulaTeamSubscriptions(
      Name: nebulaSubscription[2].Name,
      Quantity: 0,
      Price: nebulaSubscription[2].Price,
    ),
  ];
  List<NebulaTeamSubscriptions> updatedTeamSubscriptions = [];

  for (NebulaTeamSubscriptions subscription in teamSubscriptions) {
    int quantity = 0;
    for (NebulaUser user in userList) {
      if (user.SubType == subscription.Name) {
        quantity += 1;
      }
    }
    updatedTeamSubscriptions.add(NebulaTeamSubscriptions(
      Name: subscription.Name,
      Quantity: quantity,
      Price: subscription.Price,
    ));
  }
  return updatedTeamSubscriptions;
}

List<NebulaUser> getUsersFromDynamicList(List<dynamic> dynamicList) {
  List<NebulaUser> nebulaUserList = [];

  for (dynamic item in dynamicList) {
    String userId = item['UserId'] ?? '';
    String name = item['Name'] ?? '';
    String email = item['Email'] ?? '';
    String userType = item['UserType'] ?? '';
    String team = item['Team'] ?? '';
    String subType = item['SubType'] ?? '';

    NebulaUser nebulaUser = NebulaUser(
      UserId: userId,
      Name: name,
      Email: email,
      UserType: userType,
      Team: team,
      SubType: subType,
    );
    nebulaUserList.add(nebulaUser);
  }
  return nebulaUserList;
}

Future<List<String>> getActualUserDataFromFirestore() async {
  List<String> userdata = ['', ''];
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? uid = prefs.getString('uid');

  print(uid);

  // Get user data from the API
  final apiUrl = Uri.parse('http://127.0.0.1:8000/user_data?uid=$uid');
  var response = await http.get(apiUrl);
  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = jsonDecode(response.body);
    userdata[0] = responseBody['Team'];
    userdata[1] = responseBody['UserType'];
  }
  userdata[0] = "Team A";
  userdata[1] = "TeamLeader";
  print(userdata);
  return userdata;
}

void updateUser(NebulaUser user, BuildContext context, String updateType, Function fetchUsers) async {
  try {
    final apiUrl = Uri.parse('http://127.0.0.1:8000/nebula_users');
    final response = await http.put(
      apiUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserId': user.UserId,
        'Name': user.Name,
        'UserType': user.UserType,
        'Email': user.Email,
        'Team': user.Team,
        'SubType': user.SubType,
      }),
    );
    if (response.statusCode == 200) {
      fetchUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(updateType)),
      );
    } else {
      showDialogWithErrorMessage('Failed to update user', context);
    }
  } catch (e) {
    showDialogWithErrorMessage('An error occurred: $e', context);
  }
}


void adminUpdateUser(NebulaUser user, BuildContext context, Function fetchUsers) async {
  String username = user.Name;
  String updateuserteam = user.Team;
  String subtype = user.SubType;
  List<String> subtypes = ['Basic', 'Medium', 'Premium'];
  String usertype = user.UserType;
  List<String> usertypes = ['User', 'TeamLeader', 'Admin'];

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
                  username = value;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Team',
                  hintText: updateuserteam,
                ),
                onChanged: (value) {
                  updateuserteam = value;
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
                  subtype = newValue!;
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
                  usertype = newValue!;
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
              child: const Text('Update'),
              onPressed: () {
                updateUser(NebulaUser(UserId: user.UserId, Name: username, Team: updateuserteam, Email: user.Email, SubType: subtype, UserType: usertype), context, 'User Updated', fetchUsers);
                Navigator.of(context).pop();// Close the pop-up dialog
              },
            ),
          ],
        );
      }
  );
}

Future<void> addUser(NebulaUser user, BuildContext context, String team, Function fetchUsers) async {
  // Show an alert dialog to confirm the addition of the user
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add User To Team'),
        content: Column(
          children: [
            Text(user.Name),
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
            child: const Text('OK'),
            onPressed: () async {
              // Add the user membership to Firestore and update the UI
              updateUser(NebulaUser(UserId: user.UserId, Name: user.Name, Email: user.Email, UserType: user.UserType, Team: team, SubType: user.SubType),context, 'User Added To Your Team', fetchUsers);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void deleteUser(NebulaUser user, BuildContext context, Function fetchUsers) async {
  // Function to add a new user
  return showDialog(
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
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              //push database update
              updateUser(NebulaUser(UserId: user.UserId, Name: user.Name, Email: user.Email, UserType: 'User', Team: '', SubType: user.SubType), context, 'Membership Deleted', fetchUsers);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void teamLeaderUpdateUser(NebulaUser user, BuildContext context, Function fetchUsers) async {
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
                  username = value;
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
                  subtype = newValue!;
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
                  usertype = newValue!;
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
                deleteUser(user, context, fetchUsers);
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                NebulaUser updatedUser = NebulaUser(UserId: user.UserId, Name: username, Team: user.Team, Email: user.Email, SubType: subtype, UserType: usertype);
                updateUser(updatedUser, context, 'User Updated', fetchUsers);
                Navigator.of(context).pop(); // Close the pop-up dialog
              },
            ),
          ],
        );
      }
  );
}