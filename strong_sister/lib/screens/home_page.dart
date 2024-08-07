import 'package:flutter/material.dart';
import '../widgets/custom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Location and Emergency Information Section
          Container(
            padding: EdgeInsets.all(16.0),
            height: MediaQuery.of(context).size.height * 0.33,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Location: Kabuga, Kigali, Rwanda',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Are you in an emergency?",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            "Press shake your phone or click on the emergency button, your live location will be shared with the nearest help center and your emergency contacts.",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Image.asset(
                      'assets/emergency_image.jpg', // Ensure the image is in the assets directory
                      height: 100.0,
                      width: 100.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // SOS Button Section
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // Handle SOS button tap
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 120.0,
                      width: 120.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 100.0,
                      width: 100.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_android,
                              size: 40.0,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              'Shake your phone',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Emergency Type Section
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is your emergency?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildEmergencyButton(
                        icon: Icons.report,
                        label: 'Violence',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.warning_amber_rounded,
                        label: 'Other Incident',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 40.0,
          ),
          SizedBox(height: 8.0),
          Text(label),
        ],
      ),
    );
  }
}
