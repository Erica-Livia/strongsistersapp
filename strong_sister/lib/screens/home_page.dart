import 'package:flutter/material.dart';
import '../widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Instant transition to the selected screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.0), // Additional space at the top
            // Location and Emergency Information Section
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
                        'Location: Kabuga, Kigali, Rwanda',
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
                          'assets/emergency_image.jpg', // Ensure the image is in the assets directory
                          height: 120.0, // Increased height for the image
                          width: 120.0, // Increased width for the image
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // SOS Button Section
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.white, // Changed background to white
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer white circles with grey borders (radar-like effect)
                    _buildRadarCircle(210.0),
                    _buildRadarCircle(180.0),
                    _buildRadarCircle(140.0),
                    GestureDetector(
                      onTap: () {
                        // Handle SOS button tap
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 120.0,
                            width: 120.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEF5350), // Light red background
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
                              ], // Darker red button color
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
                                    'Shake your phone',
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
            // Emergency Type Section
            Container(
              padding: EdgeInsets.all(16.0),
              color: Color(0xFFF5F5FA), // Light background color
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
                    childAspectRatio:
                        2, // Adjust ratio to make buttons more balanced
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling in the grid
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.report,
                        label: 'Violence',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.warning_amber_rounded,
                        label: 'Other',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.health_and_safety,
                        label: 'Medical',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.car_crash,
                        label: 'Accident',
                        onPressed: () {
                          // Handle button press
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
        backgroundColor: Color(0xFFEF9A9A), // Light red button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0), // Rounded button
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40.0,
            color: Color(0xFFC62828), // Darker red icon color
          ),
          SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white, // White text for better contrast
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
