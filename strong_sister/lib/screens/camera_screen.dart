import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:strong_sister/widgets/custom_navigation_bar.dart';
import 'package:strong_sister/screens/home_page.dart';
import 'package:strong_sister/screens/ai_chatbot.dart';
import 'package:strong_sister/screens/safe_contacts.dart';
import 'package:strong_sister/screens/community_screen.dart';
import 'package:strong_sister/screens/profile_management.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _selectedIndex = 2;
  final List<Widget> _screens = [
    HomeScreen(),
    SafeContactsScreen(),
    CameraScreen(),
    AIChatbotScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

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

  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  DateTime? lastPressed; // To track the last back button press time

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    PermissionStatus cameraStatus = await Permission.camera.request();

    if (cameraStatus.isGranted) {
      await _initializeCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _controller = CameraController(cameras![0], ResolutionPreset.high);

      try {
        await _controller?.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<String> _getStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/Strong Sister';
    final folder = Directory(path);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    return path;
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final picture = await _controller!.takePicture();
      final directory = await _getStorageDirectory();
      final filePath =
          '$directory/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await picture.saveTo(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture saved: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const backPressDuration = Duration(seconds: 2);

    if (lastPressed == null ||
        now.difference(lastPressed!) > backPressDuration) {
      lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: backPressDuration,
        ),
      );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the back arrow
          title: Text(
            'Camera',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey[200],
        ),
        body: isCameraInitialized
            ? Column(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _takePicture,
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Take Picture',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
        bottomNavigationBar: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
