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
      'comments': 0, // Comment count
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
      final userLikeSnapshot = await transaction.get(userLikeRef);

      if (userLikeSnapshot.exists) {
        // User has already liked the post, remove the like
        transaction.delete(userLikeRef);
      } else {
        // User has not liked the post, add the like
        transaction.set(userLikeRef, {
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Get the total number of likes for a post
  Future<int> getLikesCount(String postId) async {
    final postRef = postsCollection.doc(postId);
    final likesSnapshot = await postRef.collection('likes').get();
    return likesSnapshot.size; // Return the number of documents (likes)
  }

  // Check if the user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    final userLikeRef =
        postsCollection.doc(postId).collection('likes').doc(userId);
    final userLikeSnapshot = await userLikeRef.get();
    return userLikeSnapshot
        .exists; // Return true if the user has liked the post
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
          'nickname': nickname,
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

  // Edit a post's content
  Future<void> editPost(String postId, String newContent) async {
    final postRef = postsCollection.doc(postId);

    await postRef.update({
      'content': newContent,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Delete a post and associated likes/comments
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
