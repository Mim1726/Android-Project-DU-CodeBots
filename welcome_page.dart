import 'package:flutter/material.dart';

class welcome_page extends StatelessWidget {
  final String name;
  final String email;
  final String gender;
  final DateTime dateOfBirth;

  welcome_page({
    required this.name,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, $name!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Email: $email'),
            Text('Gender: $gender'),
            Text('Date of Birth: ${dateOfBirth.toLocal().toString().split(' ')[0]}'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => about_us_page()),
                );
              },
              child: Text('About Us'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for AboutUsPage
class about_us_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Center(child: Text('About Us Content')),
    );
  }
}
