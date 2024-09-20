import 'package:flutter/material.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_feed_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class DoctorsScreen extends StatefulWidget {
  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
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

  // Dummy list of doctors
  final List<Map<String, String>> doctors = [
    {
      'name': 'Confince Pamella',
      'title': 'Mental Health and Wellness Fellow',
      'description': 'Confiance is the Mental Health and Wellness Mastercard Foundation Scholar Fellow at Solid Minds. '
          'In 2018, she obtained her BSc Hons Degree in Psychology at the University of Zimbabwe (UZ). She has '
          '15 years of experience in key areas of peer counselling, mental health advocacy, girl child safeguarding, '
          'youth and women empowerment, project management, and digital marketing. At Solid Minds, she supports all '
          'the activities including but not limited to stigma reduction workshops, psychoeducation digital marketing '
          'campaigns, and designing peer counselling programs. Confiance works in English, French, Swahili, and Kirundi.',
      'imageUrl':
          'https://res.cloudinary.com/dbyfuuq7o/image/upload/v1725566468/IMG_8506_ebqgjl.jpg',
    },
    {
      'name': 'Dr. John Doe',
      'title': 'General Practitioner',
      'description':
          'Dr. John Doe is an experienced general practitioner providing care and medical services '
              'in underprivileged areas...',
      'imageUrl':
          'https://res.cloudinary.com/dbyfuuq7o/image/upload/v1721808951/cld-sample.jpg',
    },
    // Add more doctors as needed
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
        title: Text('Doctors'),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: doctors.map((doctor) {
            return DoctorCard(
              name: doctor['name']!,
              title: doctor['title']!,
              description: doctor['description']!,
              imageUrl: doctor['imageUrl']!,
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

class DoctorCard extends StatelessWidget {
  final String name;
  final String title;
  final String description;
  final String imageUrl;

  const DoctorCard({
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
                // Implement booking functionality here
                print('Book an appointment with $name');
              },
              child: Text('Book an Appointment'),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.red), // Red button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
