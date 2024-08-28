import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'report_form_screen.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'home_page.dart'; 
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'community_screen.dart';
import 'profile_management.dart';


class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedIndex = 5;  

  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
    ReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _screens[_selectedIndex]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Reports'),
        backgroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('reports')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No reports found.');
            return Center(child: Text('No reports found.'));
          } else {
            print('Fetched ${snapshot.data!.docs.length} reports.');
            snapshot.data!.docs.forEach((doc) => print(doc.data())); 

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var report = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(report['type_of_violence'] ?? 'No Type'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report['description'] ?? 'No Description'),
                      if (report['media_url'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(report['media_url']),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _showReportForm(report),
                        color: Colors.teal,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('reports')
                              .doc(report.id)
                              .delete();
                          setState(() {});
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReportForm(),
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  void _showReportForm([DocumentSnapshot? report]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportFormScreen(report: report)),
    ).then((_) => setState(() {}));
  }
}
