import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/workout_model.dart';
import 'location_service.dart';

class WorkoutTracker {
  // Singleton pattern
  static final WorkoutTracker _instance = WorkoutTracker._internal();
  factory WorkoutTracker() => _instance;
  WorkoutTracker._internal();

  // Services
  final LocationService _locationService = LocationService();
  
  // Tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;
  
  // Workout data
  DateTime? _startTime;
  DateTime? _endTime;
  List<Position> _route = [];
  double _totalDistance = 0.0;
  StreamSubscription<Position>? _positionSubscription;
  
  // Current stats
  Position? get lastPosition => _route.isNotEmpty ? _route.last : null;
  List<Position> get route => List.unmodifiable(_route);
  double get totalDistance => _totalDistance;
  Duration get duration {
    if (_startTime == null) return Duration.zero;
    return (_endTime ?? DateTime.now()).difference(_startTime!);
  }
  
  // Calculate current pace in minutes per kilometer
  double get currentPace {
    if (_totalDistance <= 0 || duration.inSeconds <= 0) return 0;
    
    // Convert distance to kilometers and duration to minutes
    final distanceInKm = _totalDistance / 1000;
    final durationInMinutes = duration.inSeconds / 60;
    
    // Calculate pace (minutes per kilometer)
    return durationInMinutes / distanceInKm;
  }
  
  // Format pace as mm:ss per km
  String get formattedPace {
    final pace = currentPace;
    if (pace <= 0) return '00:00';
    
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  // Start tracking a new workout
  Future<bool> startWorkout() async {
    if (_isTracking) return false;
    
    // Reset workout data
    _route = [];
    _totalDistance = 0.0;
    _startTime = DateTime.now();
    _endTime = null;
    
    // Get initial position
    final initialPosition = await _locationService.getCurrentPosition();
    if (initialPosition != null) {
      _route.add(initialPosition);
      debugPrint('Workout started at: ${initialPosition.latitude}, ${initialPosition.longitude}');
    }
    
    // Start position stream
    _positionSubscription = _locationService.getPositionStream()?.listen(_onPositionUpdate);
    
    _isTracking = true;
    return true;
  }
  
  // Stop tracking the current workout
  WorkoutModel? stopWorkout() {
    if (!_isTracking) return null;
    
    _endTime = DateTime.now();
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
    
    debugPrint('Workout ended. Total distance: ${_totalDistance.toStringAsFixed(2)} meters');
    debugPrint('Duration: ${duration.inMinutes} minutes ${duration.inSeconds % 60} seconds');
    debugPrint('Average pace: $formattedPace min/km');
    
    // Create workout model
    if (_route.isNotEmpty) {
      final workout = WorkoutModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: _startTime!,
        endTime: _endTime!,
        route: List.from(_route),
        totalDistance: _totalDistance,
        duration: duration,
      );
      
      return workout;
    }
    
    return null;
  }
  
  // Handle position updates
  void _onPositionUpdate(Position position) {
    if (!_isTracking || _route.isEmpty) return;
    
    // Calculate distance from last point
    final lastPosition = _route.last;
    final distance = _locationService.calculateDistance(lastPosition, position);
    
    // Update total distance and route
    _totalDistance += distance;
    _route.add(position);
    
    // Log update
    debugPrint('Position update: ${position.latitude}, ${position.longitude}');
    debugPrint('Distance: ${_totalDistance.toStringAsFixed(2)} meters');
    debugPrint('Current pace: $formattedPace min/km');
  }
  
  // Reset all workout data
  void reset() {
    stopWorkout();
    _route = [];
    _totalDistance = 0.0;
    _startTime = null;
    _endTime = null;
  }
}
