import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  Future<DocumentReference> addPost(
      String content, String imageUrl, String nickname) async {
    return await postsCollection.add({
      'content': content,
      'imageUrl': imageUrl,
      'nickname': nickname,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // method to handle likes
  Future<void> likePost(String postId, String userId) async {
    final postRef = postsCollection.doc(postId);
    final userLikeRef = postRef.collection('likes').doc(userId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      final userLikeSnapshot = await transaction.get(userLikeRef);

      if (postSnapshot.exists) {
        if (userLikeSnapshot.exists) {
          // User has already liked the post, remove the like
          transaction.update(postRef, {'likes': FieldValue.increment(-1)});
          transaction.delete(userLikeRef);
        } else {
          // User has not liked the post, add the like
          transaction.update(postRef, {'likes': FieldValue.increment(1)});
          transaction
              .set(userLikeRef, {'timestamp': FieldValue.serverTimestamp()});
        }
      }
    });
  }

  Future<bool> hasUserLikedPost(String postId, String userId) async {
    final userLikeRef =
        postsCollection.doc(postId).collection('likes').doc(userId);
    final userLikeSnapshot = await userLikeRef.get();
    return userLikeSnapshot.exists;
  }

  // method to handle comments
  Future<void> addComment(
      String postId, String comment, String nickname) async {
    final postRef = postsCollection.doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (snapshot.exists) {
        int newComments = snapshot.get('comments') + 1;
        transaction.update(postRef, {'comments': newComments});

        postRef.collection('comments').add({
          'comment': comment,
          'nickname': nickname,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // method to retrieve comments
  Stream<QuerySnapshot> getComments(String postId) {
    return postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
