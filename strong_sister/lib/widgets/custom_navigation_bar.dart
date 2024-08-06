import 'package:flutter/material.dart';
import '../screens/home_page.dart'; // Ensure this is correctly importing HomeScreen
import '../screens/ai_chatbot.dart'; // Adjust paths as necessary
import '../screens/safe_contacts.dart'; // Adjust paths as necessary
// import '../screens/feed_screen.dart';
import '../screens/profile_management.dart'; // Adjust paths as necessary

class CustomNavigationBar extends StatefulWidget {
  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _selectedIndex = 0;

  // List of screens or widgets corresponding to each navigation item
  final List<Widget> _screens = [
    HomeScreen(),
    // ContactsScreen(),
    // ChatbotScreen(),
    // FeedScreen(),
    // ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chatbot',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.feed),
          label: 'Feed',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
