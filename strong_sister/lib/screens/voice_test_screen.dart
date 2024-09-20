import 'package:flutter/material.dart';
import 'package:strong_sister/services/voice_recognition_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TestVoiceRecognitionScreen extends StatefulWidget {
  @override
  _TestVoiceRecognitionScreenState createState() =>
      _TestVoiceRecognitionScreenState();
}

class _TestVoiceRecognitionScreenState
    extends State<TestVoiceRecognitionScreen> {
  final VoiceRecognitionService _voiceRecognitionService =
      VoiceRecognitionService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Voice Recognition'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading spinner
            : ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true; // Set loading to true
                  });

                  try {
                    // Check if the user is logged in
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      // If not logged in, navigate to login screen or show error
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please log in to continue.'),
                        ),
                      );
                      return;
                    }

                    // Start the voice recognition process for testing
                    await _voiceRecognitionService.startListening();
                  } catch (e) {
                    print('Error during voice recognition: $e');
                  } finally {
                    setState(() {
                      _isLoading = false; // Set loading back to false
                    });
                  }
                },
                child: Text('Start Voice Recognition'),
              ),
      ),
    );
  }
}
