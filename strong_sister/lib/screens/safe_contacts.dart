import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_navigation_bar.dart';

class SafeContactsScreen extends StatefulWidget {
  @override
  _SafeContactsScreenState createState() => _SafeContactsScreenState();
}

class _SafeContactsScreenState extends State<SafeContactsScreen> {
  List<Contact> _contacts = [];
  Contact _newContact = Contact(id: '', name: '', phone: '');
  bool _isEditing = false;
  int _currentIndex = -1;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final String _userId = 'user_id';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
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
      );
    }).toList();
    setState(() {
      _contacts = contacts;
    });
  }

  void _showContactModal() {
    _newContact = Contact(id: '', name: '', phone: '');
    _nameController.text = _newContact.name;
    _phoneController.text = _newContact.phone;

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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_isEditing) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(_userId)
                      .collection('safeContacts')
                      .doc(_contacts[_currentIndex].id)
                      .update({
                    'contactName': _nameController.text,
                    'contactNumber': _phoneController.text,
                  });
                  setState(() {
                    _contacts[_currentIndex] = Contact(
                      id: _contacts[_currentIndex].id,
                      name: _nameController.text,
                      phone: _phoneController.text,
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
                  });
                  setState(() {
                    _contacts.add(Contact(
                      id: docRef.id,
                      name: _nameController.text,
                      phone: _phoneController.text,
                    ));
                  });
                }
                _newContact = Contact(id: '', name: '', phone: '');
                Navigator.of(context).pop();
              },
              child: Text(_isEditing ? 'Update Contact' : 'Add Contact'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.teal,
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
    _showContactModal();
  }

  void _handleDeleteContact(int index) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('safeContacts')
        .doc(_contacts[index].id)
        .delete();
    setState(() => _contacts.removeAt(index));
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
        onPressed: () => _showContactModal(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
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
            backgroundImage:
                NetworkImage(contact.image ?? 'https://via.placeholder.com/50'),
            radius: 30,
          ),
          title: Text(
            '${contact.name}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(contact.phone),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
  String? image;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.image,
  });
}
