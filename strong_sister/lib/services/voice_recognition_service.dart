import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'location_service.dart';
import 'alert_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceRecognitionService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  final LocationService _locationService = LocationService();
  final AlertService _alertService = AlertService();

  VoiceRecognitionService() {
    _speech = stt.SpeechToText();
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _isListening = true;
      _speech.listen(onResult: (result) async {
        _recognizedText = result.recognizedWords;
        print('Recognized: $_recognizedText');

        if (_recognizedText.contains('help') ||
            _recognizedText.contains('au secours')) {
          String? safeContact = await getSafeContact();
          String? userName = await getUserName();

          if (safeContact != null && userName != null) {
            // Get the user's location (latitude and longitude)
            Map<String, String>? userLocation =
                await _locationService.getUserLocation();

            if (userLocation != null) {
              // Send WhatsApp alert to the safe contact with the location
              await _alertService.sendEmergencyAlert(safeContact, userName,
                  userLocation['latitude']!, userLocation['longitude']!);
            } else {
              print('Unable to retrieve location');
            }
          } else {
            print('No safe contact or user name found');
          }
        }
      });
    } else {
      print('The user has denied the use of speech recognition');
    }
  }

  Future<void> stopListening() async {
    _speech.stop();
    _isListening = false;
  }

  // Method to get the user's safe contact from Firestore
  Future<String?> getSafeContact() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        QuerySnapshot safeContactsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('safeContacts')
            .limit(1)
            .get();

        if (safeContactsSnapshot.docs.isNotEmpty) {
          DocumentSnapshot safeContactDoc = safeContactsSnapshot.docs.first;
          return safeContactDoc['contactNumber'];
        }
      }
    } catch (e) {
      print('Error fetching safe contact: $e');
    }
    return null;
  }

  // Method to get the user's name from Firestore
  Future<String?> getUserName() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          return userDoc['name'];
        }
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
    return null;
  }
}
