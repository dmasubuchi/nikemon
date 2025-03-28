import 'package:geolocator/geolocator.dart';

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
}
