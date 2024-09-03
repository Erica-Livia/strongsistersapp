import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';

class ReportFormScreen extends StatefulWidget {
  final DocumentSnapshot? report;

  ReportFormScreen({this.report});

  @override
  _ReportFormScreenState createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedFile;
  Uint8List? _webImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _typeController.text = widget.report!['type_of_violence'] ?? '';
      _descriptionController.text = widget.report!['description'] ?? '';
    }
  }

  Future<void> _pickMedia() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          _webImage = await pickedFile.readAsBytes(); // Asynchronously read bytes for display
        } else {
          _selectedFile = File(pickedFile.path);
        }
        setState(() {}); // Update the UI
      }
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick media. Please try again.')),
      );
    }
  }

  Future<void> _saveReport() async {
    if (_typeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a type of violence')),
      );
      return;
    }
    if (_descriptionController.text.isEmpty && _selectedFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add a description or select a file')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      String? mediaUrl;
      if (_webImage != null || _selectedFile != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reports')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        print('Uploading image...');
        if (kIsWeb) {
          await ref.putData(_webImage!);
        } else {
          await ref.putFile(_selectedFile!);
        }

        mediaUrl = await ref.getDownloadURL();
        print('Image uploaded successfully: $mediaUrl');
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in.");
      }

      final reportData = {
        'type_of_violence': _typeController.text,
        'description': _descriptionController.text,
        'media_url': mediaUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      print('Saving report to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)               // Get the current user's document
          .collection('reports')        // Add to the reports sub-collection
          .add(reportData);
      print('Report added successfully');

      Navigator.pop(context);
    } catch (e) {
      print('Error saving report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save the report. Please try again.')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'New Report' : 'Edit Report'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _typeController,
                decoration: InputDecoration(labelText: 'Type of Violence'),
                maxLines: 1,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null,
              ),
              SizedBox(height: 16),
              if (kIsWeb && _webImage != null) ...[
                Image.memory(_webImage!), // Display the selected image for web
              ] else if (_selectedFile != null) ...[
                Image.file(_selectedFile!), // Display the selected image for mobile
              ] else ...[
                OutlinedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Capture/Select Media'),
                  onPressed: _pickMedia,
                ),
              ],
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveReport,
                  child: isSaving
                      ? CircularProgressIndicator()
                      : Text(widget.report == null ? 'Submit' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}