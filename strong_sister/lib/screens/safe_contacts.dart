import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:strong_sister/models/contact.dart';
import '../widgets/custom_navigation_bar.dart';
import '../widgets/buildContactList.dart';

class SafeContactsScreen extends StatefulWidget {
  @override
  _SafeContactsScreenState createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends State<SafeContactsScreen> {
  List<Contact> _contacts = [];
  Contact _newContact = Contact(id: '', name: '', phone: '', relationship: '', image: '');
  bool _isEditing = false;
  int _currentIndex = -1;
  File? _image;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  String _userId = '';

  @override
  void initState() {
    super.initState();
    _authenticateAndLoadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _authenticateAndLoadContacts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userId = user.uid;
      _loadContacts();
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> _loadContacts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('safeContacts')
          .get();
      final contacts = snapshot.docs.map((doc) {
        final data = doc.data();
        return Contact(
          id: doc.id,
          name: data['contactName'] ?? '',
          phone: data['contactNumber'] ?? '',
          relationship: data['relationship'] ?? '',
          image: data['image'] ?? '',
        );
      }).toList();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      print('Error loading contacts: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String> _uploadImage() async {
    if (_image == null) return '';

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('user_${_userId}_contacts')
          .child('${DateTime.now().toIso8601String()}.jpg');
      await ref.putFile(_image!);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  Future<void> _addOrUpdateContact() async {
    try {
      String imageUrl = await _uploadImage();

      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('safeContacts')
            .doc(_contacts[_currentIndex].id)
            .update({
          'contactName': _nameController.text,
          'contactNumber': _phoneController.text,
          'relationship': _relationshipController.text,
          if (imageUrl.isNotEmpty) 'image': imageUrl,
        });
        setState(() {
          _contacts[_currentIndex] = Contact(
            id: _contacts[_currentIndex].id,
            name: _nameController.text,
            phone: _phoneController.text,
            relationship: _relationshipController.text,
            image: imageUrl.isNotEmpty ? imageUrl : _contacts[_currentIndex].image,
          );
          _isEditing = false;
          _currentIndex = -1;
        });
      } else {
        final docRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('safeContacts')
            .add({
          'contactName': _nameController.text,
          'contactNumber': _phoneController.text,
          'relationship': _relationshipController.text,
          'image': imageUrl,
        });
        setState(() {
          _contacts.add(Contact(
            id: docRef.id,
            name: _nameController.text,
            phone: _phoneController.text,
            relationship: _relationshipController.text,
            image: imageUrl,
          ));
        });
      }
      print('Contact added/updated successfully');
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding/updating contact: $e');
    }
  }

  void _showContactModal() {
    if (!_isEditing) {
      _newContact = Contact(id: '', name: '', phone: '', relationship: '', image: '');
      _nameController.clear();
      _phoneController.clear();
      _relationshipController.clear();
      _image = null;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_isEditing ? 'Edit Contact' : 'Add Contact'),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : (_isEditing && _contacts[_currentIndex].image.isNotEmpty
                              ? NetworkImage(_contacts[_currentIndex].image)
                              : null) as ImageProvider<Object>?,
                      child: _image == null && (!_isEditing || _contacts[_currentIndex].image.isEmpty)
                          ? Icon(Icons.add_a_photo, size: 40)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Contact Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _relationshipController,
                    decoration: InputDecoration(
                      labelText: 'Relationship',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _addOrUpdateContact();
                setState(() {});
              },
              child: Text(_isEditing ? 'Update Contact' : 'Add Contact'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleEditContact(int index) {
    setState(() {
      _newContact = _contacts[index];
      _isEditing = true;
      _currentIndex = index;
    });
    _nameController.text = _contacts[index].name;
    _phoneController.text = _contacts[index].phone;
    _relationshipController.text = _contacts[index].relationship;
    _image = null; // Reset the image when editing
    _showContactModal();
  }

  void _handleDeleteContact(int index) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('safeContacts')
          .doc(_contacts[index].id)
          .delete();
      
      // Delete the image from storage if it exists
      if (_contacts[index].image.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(_contacts[index].image).delete();
      }
      
      setState(() => _contacts.removeAt(index));
      print('Contact deleted successfully');
    } catch (e) {
      print('Error deleting contact: $e');
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    try {
      await launchUrl(launchUri);
    } catch (e) {
      print('Error making call: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        backgroundColor: Colors.white,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildContactList()),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isEditing = false;
            _currentIndex = -1;
            _newContact = Contact(id: '', name: '', phone: '', relationship: '', image: '');
          });
          _showContactModal();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (context, index) => Divider(height: 20),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundImage: contact.image.isNotEmpty
                ? NetworkImage(contact.image)
                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
            radius: 30,
          ),
          title: Text(
            '${contact.name}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${contact.phone}\nRelationship: ${contact.relationship}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.call),
                onPressed: () => _makeCall(contact.phone),
                color: Colors.green,
              ),
              IconButton(
                icon: SvgPicture.asset('assets/edit.svg'),
                onPressed: () => _handleEditContact(index),
                color: Colors.teal,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _handleDeleteContact(index),
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
}

class Contact {
  String id;
  String name;
  String phone;
  String relationship;
  String image;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.image,
  });
}