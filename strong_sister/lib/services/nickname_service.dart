import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> setNickname(String userId, String nickname) async {
  DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  await userRef.set({
    'nickname': nickname,
  }, SetOptions(merge: true));
}
