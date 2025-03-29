import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/workout_tracker.dart';
import '../services/workout_storage_service.dart';
import 'result_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Services
  final LocationService _locationService = LocationService();
  final WorkoutTracker _workoutTracker = WorkoutTracker();

  // State variables
  bool _isRunning = false;
  bool _isLoading = false;
  Position? _currentPosition;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    try {
      // Get current position
      final position = await _locationService.getCurrentPosition();

      // Update UI if mounted
      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle location errors
      if (!mounted) return;

      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              // Open app settings
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
    }
  }

  void _startWorkout() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Start workout tracking
      final success = await _workoutTracker.startWorkout();

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      if (success) {
        // Start timer
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _seconds++;
            });
          }
        });

        setState(() {
          _isRunning = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to start workout. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted after async operation
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _pauseWorkout() {
    // Pause timer
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });

    // Workout paused successfully
  }

  void _stopWorkout() {
    // Stop timer
    _timer?.cancel();
    _timer = null;

    // Stop workout tracking
    final workout = _workoutTracker.stopWorkout();

    if (workout != null) {
      debugPrint('Workout completed: ${workout.totalDistance.toStringAsFixed(2)} meters');

      // Navigate to result screen with workout data
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(workout: workout),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _workoutTracker.stopWorkout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current stats from workout tracker
    final distance = _workoutTracker.totalDistance;
    final formattedPace = _workoutTracker.formattedPace;
    final currentPosition = _workoutTracker.lastPosition ?? _currentPosition;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Running'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _workoutTracker.stopWorkout();
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'DISTANCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${(distance / 1000).toStringAsFixed(2)} KM',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn('PACE', formattedPace),
                      _buildStatColumn('TIME', _formatTime(_seconds)),
                      _buildStatColumn(
                          'CALORIES', '${_calculateCalories(distance)}'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Display route info
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ROUTE TRACKING',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Points: ${_workoutTracker.route.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        if (currentPosition != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            'LAT: ${currentPosition.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'LNG: ${currentPosition.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : (_isRunning
                        ? _buildControlButton(
                            Icons.pause,
                            Colors.white,
                            () {
                              _pauseWorkout();
                            },
                          )
                        : _buildControlButton(
                            Icons.play_arrow,
                            Colors.green,
                            () {
                              _startWorkout();
                            },
                          )),
                const SizedBox(width: 20),
                _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : _buildControlButton(
                        Icons.stop,
                        Colors.red,
                        () {
                          _stopWorkout();
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        backgroundColor: color,
      ),
      child: Icon(
        icon,
        size: 40,
        color: Colors.black,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int _calculateCalories(double distanceInMeters) {
    // Simple estimation: 1 km running burns about 60 calories
    return ((distanceInMeters / 1000) * 60).round();
  }
}
