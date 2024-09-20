import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SafeContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getSafeContact() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        // Get the safeContacts collection within the user document
        QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('safeContacts')
            .get();

        if (contactsSnapshot.docs.isNotEmpty) {
          // Assuming you want the first contact
          var firstContact = contactsSnapshot.docs.first;
          String contactNumber = firstContact['contactNumber'];
          return contactNumber; // Return the contact number
        } else {
          print('No safe contacts found');
        }
      }
    } catch (e) {
      print('Error fetching safe contact: $e');
    }
    return null;
  }
}
