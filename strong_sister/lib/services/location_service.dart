import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Map<String, String>?> getUserLocation() async {
    try {
      // Check if location services are enabled
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        print('Location services are disabled.');
        return null; // Optionally return an error message to inform the user
      }

      // Request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print('Location permissions are permanently denied.');
          return null;
        } else if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
          return null;
        }
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // Using high accuracy mode
        forceAndroidLocationManager:
            false, // Optional for Android without Google Play Services
      );

      // Convert to string for ease of use
      String latitude = position.latitude.toString();
      String longitude = position.longitude.toString();

      // Return the latitude and longitude as a map
      return {'latitude': latitude, 'longitude': longitude};
    } catch (e) {
      print('Error retrieving location: $e');
      return null;
    }
  }
}
