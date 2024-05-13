import 'package:edutrack/Screens/home_screen.dart';
import 'package:edutrack/Screens/providers/login_provider.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Admin';
  final FirestoreAuthService _authService = FirestoreAuthService();

  void _login() async {
    String? errorMessage = await _authService.loginWithCredentials(
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SafeArea(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/img.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'EduTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 68.0),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              DropdownButtonFormField(
                value: _selectedRole,
                items: <String>['Admin', 'Parent', 'Student']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Role',
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                child: Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
               // onPressed:  _login,
                onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                }

              ),
              SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}
