import 'package:flutter/material.dart';
import '../widgets/custom_navigation_bar.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<String> _posts = [
    "Welcome to the community!",
    "Check out this new resource.",
    "Share your thoughts here.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(_posts[index]),
              subtitle: Text("User Name"), // Replace with actual user data
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement post creation logic here
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }
}
