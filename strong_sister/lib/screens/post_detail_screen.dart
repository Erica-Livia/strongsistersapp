// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:strong_sister/widgets/custom_navigation_bar.dart';
// import '/services/post_service.dart';


// class PostDetailScreen extends StatelessWidget {
//   final String postId;
//   final PostService _postService = PostService();
//   final TextEditingController _commentController = TextEditingController();

//   PostDetailScreen({required this.postId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Post Details')),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder(
//               stream: _postService.getPostComments(postId),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) return CircularProgressIndicator();

//                 final comments = snapshot.data!.docs;
//                 return ListView.builder(
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(comments[index]['content']),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           TextField(
//             controller: _commentController,
//             decoration: InputDecoration(labelText: 'Add a comment'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_commentController.text.isNotEmpty) {
//                 _postService.addComment(postId, _commentController.text);
//                 _commentController.clear();
//               }
//             },
//             child: Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }
