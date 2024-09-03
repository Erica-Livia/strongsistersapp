import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strong_sister/firebase_options.dart';
import 'package:strong_sister/screens/login.dart';
import 'package:strong_sister/screens/register.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';
import 'package:strong_sister/screens/auth_check_screen.dart';
import 'package:strong_sister/services/openai_service.dart';

void main() async {
  dotenv.load(fileName: "../.env");
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    print("Firebase initialized successfully");
  } catch (e, stackTrace) {
    print("Error initializing Firebase: $e");
    print("Stack trace: $stackTrace");
  }
  runApp(
    MultiProvider(
      providers: [
        Provider<OpenAIService>(
          create: (_) => OpenAIService(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strong Sister',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthCheckScreen(),
      routes: {
        '/auth-check': (context) => AuthCheckScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/contacts': (context) => SafeContactsScreen(),
        '/aichatbot': (context) => AIChatbotScreen(),
        '/community': (context) => CommunityScreen(),
        '/profile': (context) => ProfileScreen(),
        '/camera': (context) => CameraScreen(),
      },
    );
  }
}

class AuthCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
