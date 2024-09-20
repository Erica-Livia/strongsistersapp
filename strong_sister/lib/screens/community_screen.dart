import 'package:flutter/material.dart';
import 'package:strong_sister/screens/community_feed_screen.dart';
import 'package:strong_sister/screens/resources_screen.dart';
import 'package:strong_sister/screens/doctors_screen.dart';
import 'package:strong_sister/screens/lawyers_screen.dart'; // Import the Lawyers screen
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedIndex = 4; // Set to 4 to remain on the "Feed" section

  // List of screens for navigation
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityFeedScreen(),
    ProfileScreen(),
  ];

  // Handle bottom navigation bar item tap
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Options', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildOptionTile(
                icon: Icons.people,
                color: Colors.red,
                title: 'Community Feed',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommunityFeedScreen()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.article,
                color: Colors.blue,
                title: 'Resources',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResourcesScreen()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.local_hospital,
                color: Colors.red,
                title: 'Doctors',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DoctorsScreen()),
                  );
                },
              ),
              _buildOptionTile(
                icon: Icons.gavel,
                color: Colors.green,
                title: 'Lawyers',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LawyersScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex, // Set the index to 4 to highlight "Feed"
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Function to build styled ListTile options
  Widget _buildOptionTile({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
        tileColor: Colors.grey[100],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      ),
    );
  }
}
