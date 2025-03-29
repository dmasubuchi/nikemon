// No imports needed for Material here
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Stream controller for location updates
  Stream<Position>? _positionStream;

  // Current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // Get current position
  Future<Position> getCurrentPosition() async {
    // Check if location services are enabled
    if (!await isLocationServiceEnabled()) {
      throw Exception(
          'Location service is disabled. Please enable GPS in your device settings.');
    }

    // Check if permission is granted
    final permission = await requestPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied) {
        throw Exception(
            'Location permission denied. Please allow location access to track workouts.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permission permanently denied. Please enable location access in app settings.');
    }

    try {
      // Get current position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Position updated successfully
      return _currentPosition!;
    } catch (e) {
      throw Exception('Error getting location: ${e.toString()}');
    }
  }

  // Start location updates
  Stream<Position>? getPositionStream() {
    if (_positionStream != null) {
      return _positionStream;
    }

    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).handleError((error) {
        // Error handled with exception
        throw Exception('Location tracking error: $error');
      });

      return _positionStream;
    } catch (e) {
      // Error handled with exception
      throw Exception('Failed to track location: ${e.toString()}');
    }
  }

  // Calculate distance between two positions in meters
  double calculateDistance(Position start, Position end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}
