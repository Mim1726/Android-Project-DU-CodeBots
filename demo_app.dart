import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SignUp Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SignUpPage(),
        '/welcome': (context) => WelcomePage(),
        '/about': (context) => AboutUsPage(),
      },
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender;
  DateTime? _dob;
  bool _acceptedTerms = false;

  final validUsers = {
    'user1@example.com': 'password123',
    'user2@example.com': 'securepass',
    'user3@example.com': 'mypassword',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                value == null || value.length < 3 ? 'Enter at least 3 characters' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value != null &&
                    value.contains('@') &&
                    value.contains('.')
                    ? null
                    : 'Enter a valid email',
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) =>
                value != null && value.length >= 6 ? null : 'Enter at least 6 characters',
              ),
              DropdownButtonFormField<String>(
                value: _gender,
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
                decoration: InputDecoration(labelText: 'Gender'),
                validator: (value) => value == null ? 'Select gender' : null,
              ),
              ListTile(
                title: Text(
                    _dob == null ? 'Select Date of Birth' : _dob!.toLocal().toString().split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _dob = picked);
                },
              ),
              CheckboxListTile(
                value: _acceptedTerms,
                onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                title: Text('Accept Terms & Conditions'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_dob == null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Select Date of Birth')));
                      return;
                    }
                    if (!_acceptedTerms) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('You must accept Terms')));
                      return;
                    }
                    final email = _emailController.text;
                    final password = _passwordController.text;
                    if (validUsers[email] == password) {
                      Navigator.pushNamed(context, '/welcome',
                          arguments: {
                            'fullName': _fullNameController.text,
                            'email': email,
                            'gender': _gender,
                            'dob': _dob!.toLocal().toString().split(' ')[0],
                          });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Invalid email or password')));
                    }
                  }
                },
                child: Text('Sign Up'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map userDetails = ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              icon: Icon(Icons.info))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, ${userDetails['fullName']}!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('Email: ${userDetails['email']}'),
            Text('Gender: ${userDetails['gender']}'),
            Text('Date of Birth: ${userDetails['dob']}'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              child: Text('About Us'),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  final List<Map<String, String>> teamMembers = [
    {
      'name': 'Anika Sanjida',
      'roll': '02',
      'email': 'anika@example.com',
      'photo': 'https://via.placeholder.com/100'
    },
    {
      'name': 'Suraiya jannant',
      'roll': '17',
      'email': 'suraiya@example.com',
      'photo': 'https://via.placeholder.com/100'
    },
    {
      'name': 'Ishrat Jahan',
      'roll': '52',
      'email': 'Ishrat@example.com',
      'photo': 'https://via.placeholder.com/100'
    },
    {
      'name': 'Tasmia sultana',
      'roll': '54',
      'email': 'Tasmia@example.com',
      'photo': 'https://via.placeholder.com/100'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Our App', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ...teamMembers.map((member) => Card(
              child: ListTile(
                leading: member['photo'] != null
                    ? Image.network(member['photo']!)
                    : Icon(Icons.person, size: 40),
                title: Text(member['name']!),
                subtitle: Text('Roll: ${member['roll']}'),
                trailing: IconButton(
                  icon: Icon(Icons.email),
                  onPressed: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: member['email'],
                    );
                    if (await canLaunchUrl(emailLaunchUri)) {
                      await launchUrl(emailLaunchUri);
                    }
                  },
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}


