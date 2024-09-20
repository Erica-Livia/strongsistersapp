import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/post_service.dart';
import '/screens/create_post_screen.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';

class CommunityFeedScreen extends StatefulWidget {
  @override
  _CommunityFeedScreenState createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final PostService _postService = PostService();
  int _selectedIndex = 4;
  final userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  // Screens for the navigation bar
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityFeedScreen(),
    ProfileScreen(),
  ];

  // Handle the bottom navigation bar tap
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
        title: Text('Community Feed', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _postService.getPosts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              bool isOwner = post['userId'] == userId;

              return Card(
                margin: EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post['imageUrl'] != null && post['imageUrl'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        child: Image.network(
                          post['imageUrl'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        post['content'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: FutureBuilder<bool>(
                                  future: _postService.hasUserLikedPost(
                                      post.id, userId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Icon(Icons.thumb_up,
                                          color: Colors.grey);
                                    }

                                    bool hasLiked = snapshot.data ?? false;

                                    return Icon(
                                      Icons.thumb_up,
                                      color:
                                          hasLiked ? Colors.red : Colors.grey,
                                    );
                                  },
                                ),
                                onPressed: () {
                                  _postService.likePost(post.id, userId);
                                },
                              ),
                              FutureBuilder(
                                future: _postService.getLikesCount(post.id),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text('0');
                                  }
                                  return Text('${snapshot.data}');
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  _showCommentsDialog(context, post.id);
                                },
                              ),
                              Text('${post['comments'] ?? 0}'),
                            ],
                          ),
                          if (isOwner) ...[
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editPost(context, post);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _confirmDeletePost(context, post.id);
                              },
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          );
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, String postId) {
    final TextEditingController _commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: <Widget>[
              Text('Comments', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: StreamBuilder(
                  stream: _postService.getComments(postId),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final comments = snapshot.data?.docs ?? [];

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        var comment = comments[index];
                        return ListTile(
                          title: Text(comment['comment']),
                          subtitle: Text('by ${comment['nickname']}'),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          labelText: 'Add a comment',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.red),
                      onPressed: () async {
                        if (_commentController.text.isNotEmpty) {
                          await _postService.addComment(
                            postId,
                            _commentController.text,
                            'nickname_placeholder', // Replace with actual nickname retrieval logic
                          );
                          _commentController.clear();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editPost(BuildContext context, QueryDocumentSnapshot post) {
    TextEditingController _editController =
        TextEditingController(text: post['content']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(labelText: 'Edit your post'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _postService.editPost(post.id, _editController.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePost(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
            ),
            TextButton(
              onPressed: () {
                _postService.deletePost(postId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
