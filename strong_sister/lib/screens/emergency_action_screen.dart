import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyActionScreen extends StatefulWidget {
  final String emergencyType;

  EmergencyActionScreen({required this.emergencyType});

  @override
  _EmergencyActionScreenState createState() => _EmergencyActionScreenState();
}

class _EmergencyActionScreenState extends State<EmergencyActionScreen> {
  String? _activeButton;

  // Function to call the nearest police station
  void _callPolice() async {
    const phoneNumber = 'tel:112'; // Replace with actual police station number
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Actions for ${widget.emergencyType}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'What would you like to do next to report the incident? Please select the most suitable way for you, we will request for help for you.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeButton == 'CALL_POLICE'
                    ? Colors.red
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  _activeButton = 'CALL_POLICE';
                });
                _callPolice();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CALL THE POLICE'),
                  Icon(Icons.phone),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeButton == 'SEEK_SHELTER'
                    ? Colors.red
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  _activeButton = 'SEEK_SHELTER';
                });
                // Implement your logic here
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('SEEK NEARBY SHELTER'),
                  Icon(Icons.home_filled),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeButton == 'RECORD_AUDIO'
                    ? Colors.red
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  _activeButton = 'RECORD_AUDIO';
                });
                // Implement your logic here
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECORD AN AUDIO'),
                  Icon(Icons.mic),
                ],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeButton == 'RECORD_VIDEO'
                    ? Colors.red
                    : Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                setState(() {
                  _activeButton = 'RECORD_VIDEO';
                });
                // Implement your logic here
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('RECORD VIDEO/TAKE PHOTO'),
                  Icon(Icons.videocam),
                ],
              ),
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
}
