import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'onboarding_screens.dart';  // <-- Import onboarding screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _resetOnboardingFlagOnce(); //just for check onboarding

    Timer(const Duration(seconds: 2), () {
      _checkOnboardingStatus();
    });
  }
  // just for check onboarding
  Future<void> _resetOnboardingFlagOnce() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', false); // 👈 Force reset
  }


  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_complete') ?? false;

    if (!mounted) return;

    if (completed) {
      // Onboarding done, go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      // Not done, show onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreens()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Optional background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo5.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'Platr',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.deepOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
