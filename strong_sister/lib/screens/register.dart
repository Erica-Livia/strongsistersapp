import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        // Show error if passwords do not match
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Passwords do not match"),
        ));
        return;
      }

      try {
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': _emailController.text,
          'name': _nameController.text,
        });

        Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Registration failed: $e"),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 50),
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Color(0xFFE8ECF4),
              ),
              SizedBox(height: 20),
              Text(
                'Hello! Register to get started',
                style: TextStyle(
                  color: Color(0xFF1E232C),
                  fontSize: 30,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildTextFormField(
                      controller: _nameController,
                      labelText: 'Username',
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _emailController,
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    _buildTextFormField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm password',
                      obscureText: true,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF93232A),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _register,
                      child: Text(
                        'Register',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Color(0xFF1E232C),
                            fontSize: 15,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/');
                          },
                          child: Text(
                            'Login Now',
                            style: TextStyle(
                              color: Color(0xFF93232A),
                              fontSize: 15,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Color(0xFFF6F7F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Color(0xFFE8ECF4)),
        ),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $labelText' : null,
    );
  }
}
