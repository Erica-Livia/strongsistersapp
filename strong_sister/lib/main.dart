import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strong_sister/screens/login.dart';
import 'package:strong_sister/screens/register.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';
import 'package:strong_sister/screens/location_screen.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/openai_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => OpenAIService()), // Provide OpenAIService
      ],
      child: MaterialApp(
        title: 'Strong Sister',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/contacts': (context) => SafeContactsScreen(),
          '/aichatbot': (context) => AIChatbotScreen(),
          '/community': (context) => CommunityScreen(),
          '/profile': (context) => ProfileScreen(),
          '/camera': (context) => CameraScreen(),
          '/location': (context) => LocationScreen(),
        },
      ),
    ),
  );
}
