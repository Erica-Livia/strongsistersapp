import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Navigate to home screen after successful login
        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40),
              Text(
                'Welcome back! Glad to see you, Again!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E232C),
                ),
              ),
              SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Color(0xFFF7F8F9),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Color(0xFFF7F8F9),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE8ECF4)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF6A707C),
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF93232A), // Set the background color
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _login,
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Don’t have an account? ',
                          style: TextStyle(color: Color(0xFF1E232C)),
                        ),
                        TextSpan(
                          text: 'Register Now',
                          style: TextStyle(color: Color(0xFF93232A)),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}