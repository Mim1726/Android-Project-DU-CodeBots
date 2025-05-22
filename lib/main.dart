import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import this
// import 'home_screen.dart';  // No need to show HomeScreen directly now

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Platr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'Poppins', // Optional global font
      ),
      home: const SplashScreen(), // Start with splash screen
    );
  }
}
