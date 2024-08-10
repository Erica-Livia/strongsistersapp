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
      body: SingleChildScrollView(
        // Make the screen scrollable
        child: Column(
          children: [
            // Location and Emergency Information Section
            Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.33,
              color: Color(0xFFF5F5FA),
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
                          color: Colors.black,
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
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              "Shake your phone or click the emergency button, your live location will be shared with the nearest help center and your emergency contacts.",
                              style: TextStyle(
                                color: Colors.black,
                              ),
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
              color: Color.fromARGB(255, 235, 235, 245),
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
                          color: Color(0xFFCDBCB2),
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
                          color: Color(0xFF93232A), // Red button color
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
            Container(
              padding: EdgeInsets.all(16.0),
              color: Color(0xFFF5F5FA), // Light background color
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is your emergency?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
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
                      _buildEmergencyButton(
                        icon: Icons.health_and_safety,
                        label: 'Medical Emergency',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.car_crash,
                        label: 'Car Accident',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.fire_truck,
                        label: 'Fire',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                      _buildEmergencyButton(
                        icon: Icons.warning,
                        label: 'Other',
                        onPressed: () {
                          // Handle button press
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        backgroundColor: Color(0xFFCDBCB2), // Beige button color
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
            color: Color(0xFF93232A), // Dark red icon color
          ),
          SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
