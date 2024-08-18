import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:strong_sister/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final PostService _postService = PostService();
  String? _nickname;
  bool _isNicknameSet = false;
  PlatformFile? _selectedFile;
  String? _fileUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _checkNickname();
  }

  Future<void> _checkNickname() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance
          .collection('usersNickNames')
          .doc(userId)
          .get();
      if (userDoc.exists && userDoc.data()!.containsKey('nickname')) {
        setState(() {
          _nickname = userDoc['nickname'];
          _isNicknameSet = true;
        });
      } else {
        _showNicknameDialog();
      }
    } else {
      print('User is not authenticated');
    }
  }

  void _showNicknameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Nickname'),
          content: TextField(
            controller: _nicknameController,
            decoration: InputDecoration(hintText: 'Enter your nickname'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_nicknameController.text.isNotEmpty) {
                  setState(() {
                    _nickname = _nicknameController.text;
                    _isNicknameSet = true;
                  });
                  Navigator.of(context).pop();
                  _saveNickname();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveNickname() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('usersNickNames')
          .doc(userId)
          .set({'nickname': _nickname}, SetOptions(merge: true));
    }
  }

  Future<void> _selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    try {
      final fileRef = FirebaseStorage.instance
          .ref()
          .child('post_documents')
          .child(_selectedFile!.name);

      await fileRef.putData(_selectedFile!.bytes!);
      final fileUrl = await fileRef.getDownloadURL();
      setState(() {
        _fileUrl = fileUrl;
      });
    } catch (e) {
      print('File upload error: $e');
    }
  }

  void _submitPost() async {
    if (_contentController.text.isNotEmpty && _nickname != null) {
      if (_selectedFile != null) {
        setState(() {
          _isUploading = true;
        });
        await _uploadFile();
      }

      // Proceed to the CommunityScreen and show the progress
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: LinearProgressIndicator(
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          duration: Duration(seconds: 5), // Set duration as needed
        ),
      );

      // Perform the post submission in the background
      try {
        await _postService.addPost(
            _contentController.text, _fileUrl ?? '', _nickname!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post. Please try again.'),
          ),
        );
      }

      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Post')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLength: 300,
              decoration: InputDecoration(
                labelText: 'Post Content',
              ),
            ),
            SizedBox(height: 20),
            if (!_isNicknameSet)
              ElevatedButton(
                onPressed: _showNicknameDialog,
                child: Text('Set Nickname'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select Document'),
            ),
            if (_selectedFile != null)
              Text('Selected File: ${_selectedFile!.name}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _submitPost,
              child: Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
