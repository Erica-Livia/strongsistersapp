import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is signed in, navigate to the home screen
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/home'));
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      // User is not signed in, show login/register screen
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Strong Sister!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Please login or register to continue.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF93232A),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/');
                },
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Color(0xFF93232A)),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 16, color: Color(0xFF93232A)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
