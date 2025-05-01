import 'package:flutter/material.dart';
import 'welcome_page.dart';

class signup_page extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<signup_page> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender;
  DateTime? _dateOfBirth;
  bool _termsAccepted = false;

  final List<Map<String, String>> validUsers = [
    {'email': 'sumitasmia515@gmail.com', 'password': 'password1'},
    {'email': 'user2@example.com', 'password': 'password2'},
    {'email': 'user3@example.com', 'password': 'password3'},
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      bool isValidUser = validUsers.any((user) =>
      user['email'] == _emailController.text &&
          user['password'] == _passwordController.text);
      if (isValidUser) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => welcome_page(
              name: _nameController.text,
              email: _emailController.text,
              gender: _gender!,
              dateOfBirth: _dateOfBirth!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                value != null && value.length >= 3 ? null : 'Minimum 3 characters required',
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value != null &&
                    value.contains('@') &&
                    value.contains('.')
                    ? null
                    : 'Invalid email format',
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value != null && value.length >= 6 ? null : 'Minimum 6 characters required',
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                validator: (value) => value != null ? null : 'Gender is required',
              ),
              TextButton(
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateOfBirth = pickedDate;
                    });
                  }
                },
                child: Text(_dateOfBirth == null
                    ? 'Select Date of Birth'
                    : 'DOB: ${_dateOfBirth!.toLocal()}'),
              ),
              CheckboxListTile(
                title: Text('Accept Terms & Conditions'),
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              ElevatedButton(
                onPressed: _termsAccepted ? _submitForm : null,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
