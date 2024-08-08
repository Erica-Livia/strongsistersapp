// lib/models/contact.dart

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
