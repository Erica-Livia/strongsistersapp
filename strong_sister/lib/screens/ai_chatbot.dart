import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:strong_sister/services/openai_service.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class AIChatbotScreen extends StatefulWidget {
  @override
  _AIChatbotScreenState createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  int _selectedIndex = 3;
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

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final user = _auth.currentUser;
    final userId = user?.uid;

    if (userId == null) return;

    final message = {
      'sender': 'user',
      'text': _controller.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() {
      _isLoading = true;
    });

    try {
      // Add user's message to Firestore
      await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .add(message);

      final response = await Provider.of<OpenAIService>(context, listen: false)
          .getChatbotResponse(_controller.text);

      final botMessage = {
        'sender': 'bot',
        'text': response,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add bot's response to Firestore
      await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .add(botMessage);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }

    _controller.clear();
  }

  Future<void> _deleteChatHistory() async {
    final user = _auth.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      await _firestore
          .collection('chat_history')
          .doc(userId)
          .collection('messages')
          .get()
          .then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      setState(() {
        // Update the UI after deleting chat history
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final userId = user?.uid;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow
        title: Text(
          'Support Chat',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              await _deleteChatHistory();
              setState(() {}); // Refresh the UI after deleting chat history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('chat_history')
                  .doc(userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isUser = message['sender'] == 'user';

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 10.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isUser ? Colors.red[400] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              spreadRadius: 2.0,
                            ),
                          ],
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black54,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.red[400]),
                  onPressed: _sendMessage,
                ),
              ],
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
}
