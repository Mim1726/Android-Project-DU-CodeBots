import 'package:flutter/material.dart';

class about_us_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final teamMembers = [
      {'name': 'Anika Sanzida Upoma', 'email': 'anika@gmail.com', 'role': 'Developer'},
      {'name': 'Bob', 'email': 'bob@example.com', 'role': 'Designer'},
      {'name': 'Charlie', 'email': 'charlie@example.com', 'role': 'Manager'},
    ];

    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: teamMembers.map((member) {
          return Card(
            child: ListTile(
              title: Text(member['name']!),
              subtitle: Text('Role: ${member['role']}'),
              trailing: IconButton(
                icon: Icon(Icons.email),
                onPressed: () {
                  final email = member['email']!;
                  // Logic to send an email
                  print('Sending email to $email');
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
