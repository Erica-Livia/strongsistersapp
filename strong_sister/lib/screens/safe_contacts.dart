import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  bool _showModal = false;
  List<Contact> _contacts = [];
  Contact _newContact = Contact(name: '', phone: '');
  bool _isEditing = false;
  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    // Load contacts from local storage (implementation needed)
    // You can use shared_preferences package for local storage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Circle'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => setState(() => _showModal = true),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_showModal) _buildModal(context),
            Expanded(child: _buildContactList()),
          ],
        ),
      ),
    );
  }

  Widget _buildModal(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black.withOpacity(0.5)),
        Center(
          child: Material(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isEditing ? 'Edit Contact' : 'Add Contact',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Contact Name'),
                    onChanged: (value) {
                      setState(() => _newContact.name = value);
                    },
                    controller: TextEditingController(text: _newContact.name),
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: 'Phone Number'),
                    onChanged: (value) {
                      setState(() => _newContact.phone = value);
                    },
                    controller: TextEditingController(text: _newContact.phone),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleAddContact(),
                    child: Text(_isEditing ? 'Update Contact' : 'Add Contact'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage:
                NetworkImage(contact.image ?? 'https://via.placeholder.com/50'),
          ),
          title: Text('${contact.name} - ${contact.phone}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: SvgPicture.asset('assets/edit.svg'),
                onPressed: () => _handleEditContact(index),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _handleDeleteContact(index),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAddContact() {
    if (_isEditing) {
      setState(() {
        _contacts[_currentIndex] = _newContact;
        _isEditing = false;
        _currentIndex = -1;
      });
    } else {
      setState(() => _contacts.add(_newContact));
    }
    _newContact = Contact(name: '', phone: '');
    _showModal = false;
  }

  void _handleEditContact(int index) {
    setState(() {
      _newContact = _contacts[index];
      _isEditing = true;
      _currentIndex = index;
      _showModal = true;
    });
  }

  void _handleDeleteContact(int index) {
    setState(() => _contacts.removeAt(index));
  }
}

class Contact {
  String name;
  String phone;
  String? image;

  Contact({required this.name, required this.phone, this.image});
}
