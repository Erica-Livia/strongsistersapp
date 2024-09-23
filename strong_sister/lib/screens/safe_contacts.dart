import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:strong_sister/models/contact.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';
import 'package:strong_sister/screens/camera_screen.dart';
import '../widgets/custom_navigation_bar.dart';
import 'dart:io';

class SafeContactsScreen extends StatefulWidget {
  @override
  _SafeContactsScreenState createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends State<SafeContactsScreen> {
  int _selectedIndex = 1;
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  List<Contact> _contacts = [];
  Contact _newContact = Contact(id: '', name: '', phone: '', relationship: '');
  bool _isEditing = false;
  int _currentIndex = -1;
  File? _selectedImage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  String _userId = '';

  @override
  void initState() {
    super.initState();
    _authenticateAndLoadContacts();
  }

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => _screens[index]),
      );
    }
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
      Navigator.pushReplacementNamed(context, '/auth-check');
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

  Future<void> _addOrUpdateContact() async {
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

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
          'image': imageUrl ?? _contacts[_currentIndex].image,
        });
        setState(() {
          _contacts[_currentIndex] = Contact(
            id: _contacts[_currentIndex].id,
            name: _nameController.text,
            phone: _phoneController.text,
            relationship: _relationshipController.text,
            image: imageUrl ?? _contacts[_currentIndex].image,
          );
          _isEditing = false;
          _currentIndex = -1;
          _selectedImage = null;
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
            phone: _nameController.text,
            relationship: _relationshipController.text,
            image: imageUrl,
          ));
          _selectedImage = null;
        });
      }
      print('Contact added/updated successfully');
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding/updating contact: $e');
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_images')
          .child('$_userId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(image);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  void _showContactModal() {
    if (!_isEditing) {
      _newContact = Contact(id: '', name: '', phone: '', relationship: '');
      _nameController.clear();
      _phoneController.clear();
      _relationshipController.clear();
      _selectedImage = null;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_isEditing ? 'Edit Contact' : 'Add Contact'),
          content: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _isEditing && _newContact.image?.isNotEmpty == true
                            ? NetworkImage(_newContact.image!)
                            : null,
                    child: _selectedImage == null
                        ? Icon(
                            Icons.camera_alt,
                            size: 40,
                          )
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
    _selectedImage = null; // Reset image selection for editing
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
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(child: _buildContactList()),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isEditing = false;
            _currentIndex = -1;
            _newContact =
                Contact(id: '', name: '', phone: '', relationship: '');
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
            backgroundImage: contact.image != null && contact.image!.isNotEmpty
                ? NetworkImage(contact.image!)
                : AssetImage('assets/images/default_avatar.png')
                    as ImageProvider,
            radius: 30,
          ),
          title: Text(
            '${contact.name}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle:
              Text('${contact.phone}\nRelationship: ${contact.relationship}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.call),
                onPressed: () => _makeCall(contact.phone),
                color: Colors.green,
              ),
              IconButton(
                icon: Icon(Icons.edit),
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
  String? image;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relationship,
    this.image,
  });
}
