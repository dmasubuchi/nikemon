import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  bool _isRunning = false;
  final int _seconds = 0;
  final double _distance = 0.0;
  
  // Location service
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  @override
  void initState() {
    super.initState();
    _initLocationService();
  }
  
  Future<void> _initLocationService() async {
    // Get current position
    final position = await _locationService.getCurrentPosition();
    
    // Update UI if mounted
    if (!mounted) return;
    
    setState(() {
      _currentPosition = position;
    });
  }
  
  void _startLocationTracking() {
    // Get position stream
    final positionStream = _locationService.getPositionStream();
    
    if (positionStream != null) {
      _positionStreamSubscription = positionStream.listen((Position position) {
        // Print coordinates to console
        debugPrint('Location update: ${position.latitude}, ${position.longitude}');
        
        // Update UI if mounted
        if (!mounted) return;
        
        setState(() {
          _currentPosition = position;
          
          // Calculate distance if previous position exists
          if (_currentPosition != null && _isRunning) {
            // Distance calculation would go here in a real app
            // This is just a placeholder for now
          }
        });
      });
    }
  }
  
  void _stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
  
  @override
  void dispose() {
    _stopLocationTracking();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Running'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
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
                    '${_distance.toStringAsFixed(2)} KM',
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
                      _buildStatColumn('PACE', '0\'00"'),
                      _buildStatColumn('TIME', _formatTime(_seconds)),
                      _buildStatColumn('CALORIES', '0'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Display current location
                  if (_currentPosition != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'CURRENT LOCATION',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'LAT: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'LNG: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
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
                _isRunning
                    ? _buildControlButton(
                        Icons.pause,
                        Colors.white,
                        () {
                          setState(() {
                            _isRunning = false;
                            _stopLocationTracking();
                          });
                        },
                      )
                    : _buildControlButton(
                        Icons.play_arrow,
                        Colors.green,
                        () {
                          setState(() {
                            _isRunning = true;
                            _startLocationTracking();
                          });
                        },
                      ),
                const SizedBox(width: 20),
                _buildControlButton(
                  Icons.stop,
                  Colors.red,
                  () {
                    _stopLocationTracking();
                    Navigator.pushReplacementNamed(context, '/result');
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

  Widget _buildControlButton(IconData icon, Color color, VoidCallback onPressed) {
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
}
