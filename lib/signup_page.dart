import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  String? error;
  bool showMessage = false;

  late AnimationController _controller;
  late Animation<Color?> _bgColor;

  //List<String> dummyEmails = ["test@gmail.com"];
  //List<String> dummyUsernames = ["testuser"];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
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
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      try{
        final email = emailController.text.trim();
        final password = passwordController.text.trim();
        final username = usernameController.text.trim();

        final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final User? user = userCredential.user;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'email': email,
            'username': username,
            'createdAt': Timestamp.now(),
          });

          setState(() {
            showMessage = true;
            error = null;
          });
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = e.message;
        });
      } catch (e) {
        setState(() {
          error = "An error occurred.";
        });
      }
      /*if (dummyEmails.contains(email) || dummyUsernames.contains(username)) {
        setState(() {
          error = "Username or email already exists.";
        });
      } else {
        dummyEmails.add(email);
        dummyUsernames.add(username);

        setState(() {
          showMessage = true;
          error = null;
        });
      }*/

    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Scaffold(
        backgroundColor: _bgColor.value,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Sign Up",
                      style:
                      TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                        labelText: "Username", border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty
                        ? "Enter a username"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText: "Email", border: OutlineInputBorder()),
                    validator: (value) => value!.contains('@')
                        ? null
                        : "Enter a valid email",
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Password", border: OutlineInputBorder()),
                    validator: (value) => value!.length >= 6
                        ? null
                        : "Minimum 6 characters",
                  ),
                  const SizedBox(height: 12),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  if (showMessage)
                    Column(
                      children: [
                        const Text(
                          "Oh! You have an account",
                          style:
                          TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                            );
                          },
                          child: const Text("Go to Login?"),
                        )
                      ],
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _signup,
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
