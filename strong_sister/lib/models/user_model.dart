import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nickname;

  UserModel({
    required this.id,
    required this.nickname,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      id: doc.id,
      nickname: doc['nickname'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
    };
  }
}
