import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strong_sister/services/openai_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:strong_sister/firebase_options.dart';
import 'package:strong_sister/screens/login.dart';
import 'package:strong_sister/screens/register.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';

void main() async {
  // await dotenv.load(fileName: ".env");
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
  runApp(
    MultiProvider(
      providers: [
        Provider<OpenAIService>(
          create: (_) => OpenAIService(dotenv.env['OPENAI_API_KEY']!),
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
      },
    );
  }
}
