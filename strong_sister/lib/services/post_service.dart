import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  // Add post with userId to track ownership
  Future<DocumentReference> addPost(
      String content, String imageUrl, String userId) async {
    return await postsCollection.add({
      'content': content,
      'imageUrl': imageUrl,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
    });
  }

  // Get all posts ordered by timestamp
  Stream<QuerySnapshot> getPosts() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Get posts created by a specific user
  Stream<QuerySnapshot> getUserPosts(String userId) {
    return postsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Like or unlike a post
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

  // Check if the user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    final userLikeRef =
        postsCollection.doc(postId).collection('likes').doc(userId);
    final userLikeSnapshot = await userLikeRef.get();
    return userLikeSnapshot.exists;
  }

  // Add a comment to a post
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
          'nickname': nickname, // Add nickname for the comment
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Get comments for a post
  Stream<QuerySnapshot> getComments(String postId) {
    return postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    final postRef = postsCollection.doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (snapshot.exists) {
        // Delete all associated likes and comments
        final likesSnapshot = await postRef.collection('likes').get();
        for (var doc in likesSnapshot.docs) {
          await doc.reference.delete();
        }

        final commentsSnapshot = await postRef.collection('comments').get();
        for (var doc in commentsSnapshot.docs) {
          await doc.reference.delete();
        }

        // Finally, delete the post itself
        await postRef.delete();
      }
    });
  }
}
