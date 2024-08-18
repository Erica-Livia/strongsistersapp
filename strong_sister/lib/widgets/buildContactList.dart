import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:strong_sister/models/contact.dart'; // Import the Contact class

class ContactList extends StatelessWidget {
  final List<Contact> contacts;
  final Function(String) onCall;
  final Function(int) onEdit;
  final Function(int) onDelete;

  ContactList({
    required this.contacts,
    required this.onCall,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: contacts.length,
      separatorBuilder: (context, index) => Divider(height: 20),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(contact.image ?? 'https://via.placeholder.com/50'),
            radius: 30,
          ),
          title: Text(
            contact.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${contact.phone}\nRelationship: ${contact.relationship}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.call),
                onPressed: () => onCall(contact.phone),
                color: Colors.green,
              ),
              IconButton(
                icon: SvgPicture.asset('assets/edit.svg'),
                onPressed: () => onEdit(index),
                color: Colors.teal,
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(index),
                color: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
}
