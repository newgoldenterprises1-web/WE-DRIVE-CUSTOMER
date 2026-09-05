import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  LocationService._();

  static final Geocoding _geocoding = Geocoding();

  /// Returns the device's current readable address.
  /// Returns null when location cannot be obtained.
  static Future<String?> getCurrentAddress() async {
    try {
      // 1. Check whether device location/GPS is enabled.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }

      // 2. Check permission.
      var permission = await Geolocator.checkPermission();

      // 3. Request permission if not granted yet.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // 4. Stop when permission is denied.
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      // 5. Get current position.
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 0,
          timeLimit: Duration(seconds: 20),
        ),
      );

      // 6. Convert coordinates into address.
      final placemarks = await _geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // 7. Fallback to coordinates if reverse geocoding returns nothing.
      if (placemarks.isEmpty) {
        return _coordinates(position);
      }

      final place = placemarks.first;

      final parts = <String>[];

      void addPart(String? value) {
        final text = value?.trim() ?? '';

        if (text.isEmpty) return;

        if (!parts.contains(text)) {
          parts.add(text);
        }
      }

      addPart(place.name);
      addPart(place.street);
      addPart(place.subLocality);
      addPart(place.locality);
      addPart(place.administrativeArea);
      addPart(place.postalCode);

      if (parts.isNotEmpty) {
        return parts.join(', ');
      }

      return _coordinates(position);
    } on LocationServiceDisabledException {
      return null;
    } on PermissionDeniedException {
      return null;
    } catch (_) {
      return null;
    }
  }

  static String _coordinates(Position position) {
    return '${position.latitude.toStringAsFixed(6)}, '
        '${position.longitude.toStringAsFixed(6)}';
  }
}