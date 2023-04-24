import 'package:flutter/material.dart';

import '../Services/Logs.dart';
import '../Services/CustomPainter.dart';

Widget buildUserScreen(BuildContext context) {
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
    body: CustomPaint(
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
    ),
  );
}