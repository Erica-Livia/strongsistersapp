import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../widgets/custom_navigation_bar.dart';
import 'home_page.dart';
import 'ai_chatbot.dart';
import 'safe_contacts.dart';
import 'community_screen.dart';
import 'camera_screen.dart';
import 'reports_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 5;
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  String _userEmail = '';
  String _userLocation = 'Set Location';

  DateTime? lastPressed;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name'];
            _userEmail = userDoc['email'];
            _userLocation = userDoc['location'] ?? 'Set Location';
          });
        } else {
          print('User document does not exist');
        }
      } else {
        print('No user is currently signed in');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _updateUserLocation(String newLocation) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'location': newLocation,
        });
        setState(() {
          _userLocation = newLocation;
        });
      } else {
        print('No user is currently signed in');
      }
    } catch (e) {
      print('Error updating user location: $e');
    }
  }

  Future<void> _setUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      String url =
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${position.latitude}&longitude=${position.longitude}&localityLanguage=en';

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        String newLocation =
            "${data['city']}, ${data['principalSubdivision']}, ${data['countryName']}";
        _updateUserLocation(newLocation);
      } else {
        print("Failed to fetch location from API");
      }
    } catch (e) {
      print('Error setting user location: $e');
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const backPressDuration = Duration(seconds: 2);

    if (lastPressed == null ||
        now.difference(lastPressed!) > backPressDuration) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: backPressDuration,
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Profile'),
          backgroundColor: Colors.grey[200],
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // Handle edit profile action
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Center the user info
              Center(
                child: Column(
                  children: [
                    Text(
                      '$_userName',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_userEmail',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileAction(
                        Icons.location_pin, _userLocation, 'Set Location'),
                    _buildProfileAction(Icons.language, 'App Language', ''),
                    ListTile(
                      leading: Icon(Icons.report),
                      title: Text('My Reports'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReportsScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.help),
                      title: Text('Help'),
                      onTap: () async {
                        _launchUrl('https://strong-sister.vercel.app/');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.update),
                      title: Text('Update the app'),
                      onTap: () async {
                        _launchUrl('https://new-version-ecru.vercel.app/');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout'),
                      onTap: () {
                        _showLogoutWarning(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildProfileAction(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      onTap: () {
        if (title == _userLocation) {
          _setUserLocation();
        } else if (title == 'Logout') {
          _showLogoutWarning(context);
        }
      },
    );
  }

  void _showLogoutWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
              child: Text('Logout'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
