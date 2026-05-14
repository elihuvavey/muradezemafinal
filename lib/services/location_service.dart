// import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    debugPrint('LocationService: Checking location services...');
    bool serviceEnabled;
    // LocationPermission permission;

    // Test if location services are enabled.
    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // debugPrint('LocationService: Location services enabled: $serviceEnabled');

    // if (!serviceEnabled) {
    //   debugPrint('LocationService: Location services are not enabled');
    //   return false;
    // }

    // debugPrint('LocationService: Checking current permission status...');
    // permission = await Geolocator.checkPermission();
    // debugPrint('LocationService: Current permission status: $permission');

    // if (permission == LocationPermission.denied) {
    //   debugPrint('LocationService: Permission denied, requesting permission...');
    //   permission = await Geolocator.requestPermission();
    //   debugPrint('LocationService: New permission status: $permission');

    //   if (permission == LocationPermission.denied) {
    //     debugPrint('LocationService: Permission still denied');
    //     return false;
    //   }
    // }

    // if (permission == LocationPermission.deniedForever) {
    //   debugPrint('LocationService: Permission permanently denied');
    //   return false;
    // }

    // debugPrint('LocationService: Permission granted!');
    return true;
  }

  static Future<bool> checkLocationService(BuildContext context) async {
    // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    // if (!serviceEnabled) {
    //   // Show dialog to enable location
    //   bool? shouldOpenSettings = await showDialog<bool>(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return AlertDialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20),
    //         ),
    //         title: Row(
    //           children: [
    //             Icon(Icons.location_off, color: Colors.red),
    //             const SizedBox(width: 12),
    //             Text(
    //               "Location Disabled",
    //               style: TextStyle(
    //                 fontSize: 20,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //           ],
    //         ),
    //         content: Text(
    //           "Please enable location services to use this feature. Would you like to open location settings?",
    //           style: TextStyle(fontSize: 16),
    //         ),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.of(context).pop(false),
    //             child: Text(
    //               "Not Now",
    //               style: TextStyle(color: Colors.grey[700]),
    //             ),
    //           ),
    //           ElevatedButton.icon(
    //             icon: const Icon(Icons.settings, size: 18),
    //             label: const Text("Open Settings"),
    //             style: ElevatedButton.styleFrom(
    //               backgroundColor: Colors.blue,
    //               foregroundColor: Colors.white,
    //               shape: RoundedRectangleBorder(
    //                 borderRadius: BorderRadius.circular(12),
    //               ),
    //             ),
    //             onPressed: () => Navigator.of(context).pop(true),
    //           ),
    //         ],
    //       );
    //     },
    //   );

    //   if (shouldOpenSettings == true) {
    //     await Geolocator.openLocationSettings();
    //     // Check again after returning from settings
    //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //   }
    // }

    // return serviceEnabled;
    return true;
  }

  // static Future<Position?> getCurrentLocation() async {
  //   try {
  //     debugPrint('LocationService: Getting current location...');
  //     final hasPermission = await requestLocationPermission();
  //     if (!hasPermission) {
  //       debugPrint('LocationService: No permission to get location');
  //       return null;
  //     }

  //     final position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //     debugPrint(
  //         'LocationService: Got position: ${position.latitude}, ${position.longitude}');
  //     return position;
  //   } catch (e) {
  //     debugPrint('LocationService: Error getting location: $e');
  //     return null;
  //   }
  // }
}
