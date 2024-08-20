import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class EmergencyActionScreen extends StatefulWidget {
  final String emergencyType;

  EmergencyActionScreen({required this.emergencyType});

  @override
  _EmergencyActionScreenState createState() => _EmergencyActionScreenState();
}

class _EmergencyActionScreenState extends State<EmergencyActionScreen> {
  String? _activeButton;
  String? _safeContactNumber;

  @override
  void initState() {
    super.initState();
    _fetchSafeContact();
  }

  // Function to call the nearest police station
  void _callPolice() async {
    const phoneNumber = 'tel:112'; // Replace with actual police station number
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  // Function to fetch the first safe contact
  Future<void> _fetchSafeContact() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('safeContacts')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _safeContactNumber = snapshot.docs.first['contactNumber'];
        });
      }
    }
  }

  // Function to call the first safe contact
  void _callSafeContact() async {
    if (_safeContactNumber != null) {
      final phoneNumber = 'tel:$_safeContactNumber';
      if (await canLaunch(phoneNumber)) {
        await launch(phoneNumber);
      } else {
        throw 'Could not launch $phoneNumber';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No safe contact available')),
      );
    }
  }

  // Function to navigate to the CameraScreen
  void _navigateToCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          'Emergency Actions for ${widget.emergencyType}',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'What would you like to do next to report the incident? Please select the most suitable way for you, we will request for help for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            _buildActionButton(
              label: 'CALL THE POLICE',
              icon: Icons.phone,
              isActive: _activeButton == 'CALL_POLICE',
              onPressed: () {
                setState(() {
                  _activeButton = 'CALL_POLICE';
                });
                _callPolice();
              },
            ),
            SizedBox(height: 10),
            _buildActionButton(
              label: 'CALL SAFE CONTACT',
              icon: Icons.contact_phone,
              isActive: _activeButton == 'CALL_SAFE_CONTACT',
              onPressed: () {
                setState(() {
                  _activeButton = 'CALL_SAFE_CONTACT';
                });
                _callSafeContact();
              },
            ),
            SizedBox(height: 10),
            _buildActionButton(
              label: 'SEEK NEARBY SHELTER',
              icon: Icons.home_filled,
              isActive: _activeButton == 'SEEK_SHELTER',
              onPressed: () {
                setState(() {
                  _activeButton = 'SEEK_SHELTER';
                });
                // Implement your logic here
              },
            ),
            SizedBox(height: 10),
            _buildActionButton(
              label: 'RECORD AN AUDIO',
              icon: Icons.mic,
              isActive: _activeButton == 'RECORD_AUDIO',
              onPressed: () {
                setState(() {
                  _activeButton = 'RECORD_AUDIO';
                });
                _navigateToCamera(); // Navigate to camera screen
              },
            ),
            SizedBox(height: 10),
            _buildActionButton(
              label: 'RECORD VIDEO/TAKE PHOTO',
              icon: Icons.videocam,
              isActive: _activeButton == 'RECORD_VIDEO',
              onPressed: () {
                setState(() {
                  _activeButton = 'RECORD_VIDEO';
                });
                _navigateToCamera(); // Navigate to camera screen
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('Go Back to Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Color(0xFFD50000) : Color(0xFFEF9A9A),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
          Icon(icon, color: Colors.white),
        ],
      ),
    );
  }
}
