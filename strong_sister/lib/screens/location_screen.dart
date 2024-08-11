import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String? _address;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Convert the coordinates to a human-readable address
      String address = await _getAddressFromLatLng(position.latitude, position.longitude);

      // Navigate to HomeScreen and pass the address
      Navigator.pushReplacementNamed(context, '/home', arguments: {
        'address': address,
        'timestamp': DateTime.now(),
      });
    } catch (e) {
      setState(() {
        _address = 'Failed to get location: $e';
      });
    }
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      Placemark place = placemarks[0];
      return "${place.locality}, ${place.subAdministrativeArea}, ${place.country}";
    } catch (e) {
      return "Failed to get address";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _address == null
            ? CircularProgressIndicator()
            : Text('Location: $_address'),
      ),
    );
  }
}
