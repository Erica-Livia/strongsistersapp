import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:strong_sister/firebase_options.dart';
import 'package:strong_sister/screens/login.dart';
import 'package:strong_sister/screens/register.dart';
import 'package:strong_sister/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized successfully");
  } catch (e, stackTrace) {
    print("Error initializing Firebase: $e");
    print("Stack trace: $stackTrace");
  }
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strong Sister',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
