import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'signup_page.dart';
import 'home_screen.dart';
import 'reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _controller; // background color pulsing
  late Animation<Color?> _bgColor;

  double _scale = 1.0; // for the pop animation

  static const devEmails = [
    'ishratjahan7711@gmail.com',
    'sumitasmia515@gmail.com',
    'mimrobo1726@gmail.com',
    'anikasanzida31593@gmail.com',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _bgColor = ColorTween(
      begin: Colors.white,
      end: const Color(0xFFF2F2F2),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!")),
        );

        // go to home
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Invalid email or password")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/screen_images/screen1.jpg',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.25),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _bgColor.value?.withOpacity(0.9) ?? Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome !",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                        value!.contains('@') ? null : "Enter a valid email",
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                        value!.length >= 6 ? null : "Minimum 6 characters",
                      ),
                      const SizedBox(height: 8),

                      // Forgot Password aligned right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ResetPasswordPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Animated Login Button with pop effect
                      GestureDetector(
                        onTap: () async {
                          // shrink a bit
                          setState(() => _scale = 0.95);
                          await Future.delayed(const Duration(milliseconds: 100));
                          // pop out
                          setState(() => _scale = 1.05);
                          await Future.delayed(const Duration(milliseconds: 100));
                          // settle
                          setState(() => _scale = 1.0);
                          await _login();
                        },
                        child: AnimatedScale(
                          scale: _scale,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                          child: ElevatedButton.icon(
                            onPressed: _login, // handled by GestureDetector
                            icon: const Icon(Icons.login),
                            label: const Text("Login"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
