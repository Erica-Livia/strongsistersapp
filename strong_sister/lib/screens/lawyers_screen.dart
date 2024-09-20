import 'package:flutter/material.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_feed_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class LawyersScreen extends StatefulWidget {
  @override
  _LawyersScreenState createState() => _LawyersScreenState();
}

class _LawyersScreenState extends State<LawyersScreen> {
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

  // Dummy list of lawyers
  final List<Map<String, String>> lawyers = [
    {
      'name': 'Jane Akimana',
      'title': 'Human Rights Lawyer',
      'description': 'Jane Akimana is a dedicated human rights lawyer with 10 years of experience advocating for women\'s rights...',
      'imageUrl': 'https://example.com/lawyer1.jpg',
    },
    {
      'name': 'Chanelle Kigeme',
      'title': 'Family Law Specialist',
      'description': 'Chanelle Kigeme specializes in family law and has helped hundreds of women navigate complex legal cases...',
      'imageUrl': 'https://example.com/lawyer2.jpg',
    },
    // Add more lawyers as needed
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
        title: Text('Lawyers'),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: lawyers.map((lawyer) {
            return LawyerCard(
              name: lawyer['name']!,
              title: lawyer['title']!,
              description: lawyer['description']!,
              imageUrl: lawyer['imageUrl']!,
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex, // Ensure the index stays at 4
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class LawyerCard extends StatelessWidget {
  final String name;
  final String title;
  final String description;
  final String imageUrl;

  const LawyerCard({
    required this.name,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl, // Load the image from the provided URL
                height: 100, // Small image size
                width: 100, // Make it a small square
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _showPaymentDialog(context, name);
              },
              child: Text('Book an Appointment'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show the payment dialog
  void _showPaymentDialog(BuildContext context, String lawyerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text('Payment for $lawyerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your payment details to book an appointment with $lawyerName'),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            ElevatedButton(
              child: Text('Pay'),
              onPressed: () {
                // Implement payment functionality here
                print('Payment confirmed for $lawyerName');
                Navigator.of(context).pop(); // Close the dialog after payment
              },
            ),
          ],
        );
      },
    );
  }
}