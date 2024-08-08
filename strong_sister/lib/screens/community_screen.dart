import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import '/services/post_service.dart';
import '/screens/create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  final PostService _postService = PostService();
  final String userId =
      'currentUserId'; // Replace with actual user ID retrieval method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Feed'),
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
              return FutureBuilder(
                future: _postService.hasUserLikedPost(post.id, userId),
                builder: (context, likeSnapshot) {
                  bool hasLiked = likeSnapshot.data ?? false;
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post['imageUrl'] != null &&
                            post['imageUrl'].isNotEmpty)
                          Image.network(post['imageUrl']),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(post['content']),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(
                                  hasLiked ? Icons.thumb_up : Icons.thumb_up,
                                  color: hasLiked ? Colors.red : Colors.black,
                                ),
                                onPressed: () {
                                  _postService.likePost(post.id, userId);
                                },
                              ),
                              Text('Likes: ${post['likes']}'),
                              IconButton(
                                icon: Icon(Icons.comment),
                                onPressed: () {
                                  _showCommentsDialog(context, post.id);
                                },
                              ),
                              Text('Comments: ${post['comments']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  void _showCommentsDialog(BuildContext context, String postId) {
    final TextEditingController _commentController = TextEditingController();
    final String nickname =
        'ActualNickname'; // Replace with actual nickname retrieval

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comments'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      shrinkWrap: true,
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
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Add a comment'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                if (_commentController.text.isNotEmpty) {
                  _postService.addComment(
                      postId, _commentController.text, nickname);
                  _commentController.clear();
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }
}
