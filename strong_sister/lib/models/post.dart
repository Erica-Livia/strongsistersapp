import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String content;
  final String imageUrl;
  final String videoUrl;
  final String nickname;
  final int likesCount;
  final int commentsCount;
  final Timestamp timestamp;

  Post({
    required this.id,
    required this.content,
    required this.imageUrl,
    required this.videoUrl,
    required this.nickname,
    required this.likesCount,
    required this.commentsCount,
    required this.timestamp,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      content: doc['content'],
      imageUrl: doc['imageUrl'] ?? '',
      videoUrl: doc['videoUrl'] ?? '',
      nickname: doc['nickname'],
      likesCount: doc['likesCount'],
      commentsCount: doc['commentsCount'],
      timestamp: doc['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'nickname': nickname,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'timestamp': timestamp,
    };
  }
}
