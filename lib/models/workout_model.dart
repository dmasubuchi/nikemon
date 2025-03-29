import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class WorkoutModel {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final List<Position> route;
  final double totalDistance; // in meters
  final Duration duration;
  
  WorkoutModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.route,
    required this.totalDistance,
    required this.duration,
  });
  
  // Calculate average pace in minutes per kilometer
  double get averagePace {
    if (totalDistance <= 0 || duration.inSeconds <= 0) return 0;
    
    // Convert distance to kilometers and duration to minutes
    final distanceInKm = totalDistance / 1000;
    final durationInMinutes = duration.inSeconds / 60;
    
    // Calculate pace (minutes per kilometer)
    return durationInMinutes / distanceInKm;
  }
  
  // Format pace as mm:ss per km
  String get formattedPace {
    final pace = averagePace;
    if (pace <= 0) return '00:00';
    
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Calculate calories burned (simplified estimation)
  int get caloriesBurned {
    // Simple estimation: 1 km running burns about 60 calories
    return ((totalDistance / 1000) * 60).round();
  }
  
  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalDistance': totalDistance,
      'duration': duration.inSeconds,
      'route': route.map((position) => {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': position.timestamp.toIso8601String(),
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
        'altitudeAccuracy': 0.0,
        'headingAccuracy': 0.0,
      }).toList(),
    };
  }
  
  // Create string representation for storage
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  // Create WorkoutModel from JSON
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      totalDistance: json['totalDistance'],
      duration: Duration(seconds: json['duration']),
      route: (json['route'] as List).map((positionJson) => Position(
        latitude: positionJson['latitude'],
        longitude: positionJson['longitude'],
        timestamp: DateTime.parse(positionJson['timestamp']),
        accuracy: positionJson['accuracy'],
        altitude: positionJson['altitude'],
        heading: positionJson['heading'],
        speed: positionJson['speed'],
        speedAccuracy: positionJson['speedAccuracy'],
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      )).toList(),
    );
  }
  
  // Create WorkoutModel from JSON string
  factory WorkoutModel.fromJsonString(String jsonString) {
    return WorkoutModel.fromJson(jsonDecode(jsonString));
  }
}

// Extension to convert Position objects to LatLng objects for Google Maps
extension RouteConversion on WorkoutModel {
  List<LatLng> toLatLngList() {
    return route.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}
