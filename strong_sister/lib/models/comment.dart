import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String content;
  final String nickname;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.content,
    required this.nickname,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      id: doc.id,
      postId: doc['postId'],
      content: doc['content'],
      nickname: doc['nickname'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'content': content,
      'nickname': nickname,
      'timestamp': timestamp,
    };
  }
}
