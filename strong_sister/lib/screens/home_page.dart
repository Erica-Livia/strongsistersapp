import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';
import 'package:strong_sister/screens/emergency_action_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  DateTime? lastPressed; // To track the last back button press time
  String _location = "Fetching location..."; // Placeholder for location
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = "Location services are disabled.";
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _fetchAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print("Error in getting location: ${e.toString()}");
      setState(() {
        _location = "Failed to get location: ${e.toString()}";
      });
    }
  }

  Future<void> _fetchAddressFromCoordinates(double latitude, double longitude) async {
    try {
      String url = 'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en';

      http.Response response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        setState(() {
          _location = "${data['city']}, ${data['principalSubdivision']}, ${data['countryName']}";
        });
      } else {
        setState(() {
          _location = "Failed to get location details.";
        });
      }
    } catch (e) {
      print("Error in fetching address: ${e.toString()}");
      setState(() {
        _location = "Failed to fetch address.";
      });
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(16.0),
                height: MediaQuery.of(context).size.height * 0.33,
                color: Color(0xFFF5F5FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _location,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Are you in an emergency?",
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                "Shake your phone or click the emergency button, your live location will be shared with the nearest help center and your emergency contacts.",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          flex: 1,
                          child: Image.asset(
                            'assets/emergency_image.jpg',
                            height: 120.0,
                            width: 120.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                color: Colors.white,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildRadarCircle(210.0),
                      _buildRadarCircle(180.0),
                      _buildRadarCircle(140.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EmergencyActionScreen(
                                emergencyType: 'General Emergency',
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 120.0,
                              width: 120.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEF5350),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFEF5350),
                                    blurRadius: 4.0,
                                    spreadRadius: 2.0,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFD50000),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFFD50000),
                                    blurRadius: 4.0,
                                    spreadRadius: 3.0,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.phone_android,
                                      size: 40.0,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'SOS Button',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                color: Color(0xFFF5F5FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is your emergency?',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 2,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildEmergencyButton(
                          icon: Icons.report,
                          label: 'Violence',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyActionScreen(
                                  emergencyType: 'Violence',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildEmergencyButton(
                          icon: Icons.warning_amber_rounded,
                          label: 'Other',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyActionScreen(
                                  emergencyType: 'Other',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildEmergencyButton(
                          icon: Icons.health_and_safety,
                          label: 'Medical',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyActionScreen(
                                  emergencyType: 'Medical',
                                ),
                              ),
                            );
                          },
                        ),
                        _buildEmergencyButton(
                          icon: Icons.car_crash,
                          label: 'Accident',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyActionScreen(
                                  emergencyType: 'Accident',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildRadarCircle(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEF9A9A),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFEF9A9A),
            blurRadius: 2.0,
            spreadRadius: 1.0,
          ),
        ],
        border: Border.all(
          color: Color.fromARGB(176, 239, 154, 154),
          width: 2.0,
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(14.0),
        backgroundColor: Color(0xFFEF9A9A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40.0,
            color: Color(0xFFC62828),
          ),
          SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
