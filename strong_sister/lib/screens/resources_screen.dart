import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_feed_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class ResourcesScreen extends StatefulWidget {
  @override
  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
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

  // Dummy list of articles
  List<Map<String, String>> articles = [
    {
      'title': "Burundi: information for victims of rape and sexual assault",
      'description':
          "If you’ve been sexually assaulted it’s important to remember that it was not your fault. Rape and Sexual assault is always wrong...",
      'timeAgo': "10 days ago",
      'author': "Foreign & Development Office",
      'url':
          "https://www.gov.uk/government/publications/burundi-information-for-victims-of-rape-and-sexual-assault/burundi-information-for-victims-of-rape-and-sexual-assault"
    },
    {
      'title': "Rape-the hidden human rights abuse",
      'description':
          "Like all human rights abuses in Burundi, rape has become an entrenched feature of the crisis because the perpetrators...",
      'timeAgo': "5 days ago",
      'author': "Amnesty International",
      'url':
          "https://www.amnesty.org/en/wp-content/uploads/2021/08/afr160062004en.pdf"
    },
    {
      'title': "Violence Prevention Initiative",
      'description':
          "The Violence Prevention Initiative is a multi-departmental, government-community partnership to find long-term solutions to violence against those most at risk...",
      'timeAgo': "20 days ago",
      'author': "Bonnie Green",
      'url':
          "https://www.gov.nl.ca/vpi/tips-and-tools/tips-for-youth-to-prevent-gender-based-violence-and-inequality/"
    },
    {
      'title': "Sexual violence against women and girls in Burundi",
      'description':
          "The World Health Organization indicates that 35% of women worldwide have experienced violence. In war-torn zones like Burundi, sexual violence was part of everyday life...",
      'timeAgo': "15 days ago",
      'author': "Jese Leos",
      'url':
          "https://www.researchgate.net/publication/315793464_SEXUAL_VIOLENCE_AGAINST_WOMEN_AND_GIRLS_IN_BURUNDI"
    }
  ];

  String searchQuery = '';

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

  // Function to launch URL
  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resources', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar at the top
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Search Articles",
                hintText: "Enter article title...",
                prefixIcon: Icon(Icons.search, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.black54),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  if (searchQuery.isEmpty ||
                      article['title']!
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase())) {
                    return _buildArticleCard(article);
                  }
                  return Container(); // Return an empty container if no match
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // Function to build a styled article card
  Widget _buildArticleCard(Map<String, String> article) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  child: Icon(Icons.article, color: Color(0xFFD50000)),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    article['title']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              article['description']!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  article['author']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                Text(
                  article['timeAgo']!,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(article['url']!),
              icon: Icon(Icons.open_in_new),
              label: Text("Read More"),
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(color: Color(0xFFD50000)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
