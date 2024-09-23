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
import 'package:strong_sister/screens/voice_test_screen.dart';
import 'package:strong_sister/services/openai_service.dart';
import 'package:strong_sister/services/voice_recognition_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

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

  // Initialize the background service
  await initializeBackgroundService();

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

// Initialize the background service for voice recognition
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStartService,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStartService,
      onBackground: (service) {
        return true;
      },
    ),
  );

  service.startService(); // Corrected the start method for the service
}

extension on FlutterBackgroundService {
  void startService() {}

  on(String s) {}

  void stopSelf() {}

  void setAsForegroundService() {}

  void setForegroundNotificationInfo(
      {required String title, required String content}) {}
}

// Background service handler for voice recognition
void onStartService(FlutterBackgroundService service) async {
  VoiceRecognitionService _voiceRecognitionService = VoiceRecognitionService();
  _voiceRecognitionService.startListening();

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Implement notification for Android (assuming the app runs on Android)
  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
    service.setForegroundNotificationInfo(
      title: "Voice Recognition Active",
      content: "Listening for the word 'help'...",
    );
  }
}

class AndroidServiceInstance {}

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
        '/voice-test': (context) => TestVoiceRecognitionScreen(),
      },
    );
  }
}

// Authentication check screen
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
          return HomeScreen(); // User is authenticated
        } else {
          return LoginScreen(); // User is not authenticated
        }
      },
    );
  }
}
