import 'package:flutter/material.dart';
import 'signup_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Our App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: signup_page(),
    );
  }
}
