// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';

class LocationUtils {
  /// Checks if the user's current location is in Ethiopia
  // static Future<bool> isLocal() async {
  // try {
  //   // Request permission
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       debugPrint('Location permission denied.');
  //       return false;
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     debugPrint('Location permission permanently denied.');
  //     return false;
  //   }

  //   // Get current position
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   // Reverse geocode to get country
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );

  //   if (placemarks.isNotEmpty) {
  //     String? country = placemarks.first.country;
  //     if (country != null && country.toLowerCase() == 'ethiopia') {
  //       return true;
  //     }
  //   }

  //   return false;
  // } catch (e) {
  //   debugPrint('Error checking location: $e');
  //   return false;
  // }
  // }
}
