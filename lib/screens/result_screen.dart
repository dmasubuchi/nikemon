import 'package:flutter/material.dart';
import '../models/workout_model.dart';
import '../services/workout_storage_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, this.workout});
  
  final WorkoutModel? workout;

  @override
  Widget build(BuildContext context) {
    // Sample workout data for testing
    final testWorkout = workout ?? WorkoutModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now().subtract(const Duration(minutes: 30)),
      endTime: DateTime.now(),
      route: [],
      totalDistance: 4200, // 4.2 km
      duration: const Duration(minutes: 30),
    );
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Workout Complete'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
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
                    '${(testWorkout.totalDistance / 1000).toStringAsFixed(2)} KM',
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
                      _buildStatColumn('PACE', testWorkout.formattedPace),
                      _buildStatColumn('TIME', _formatDuration(testWorkout.duration)),
                      _buildStatColumn('CALORIES', '${testWorkout.caloriesBurned}'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ROUTE SUMMARY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'GPS Points: ${testWorkout.route.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Started: ${_formatDateTime(testWorkout.startTime)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Ended: ${_formatDateTime(testWorkout.endTime)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  Icons.save,
                  'SAVE',
                  () async {
                    // Save workout to history
                    if (workout != null) {
                      // Capture context before async gap
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      
                      final storageService = WorkoutStorageService();
                      final saved = await storageService.saveWorkout(workout!);
                      
                      // Use captured context reference
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(saved 
                            ? 'Workout saved to history' 
                            : 'Failed to save workout'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No workout data to save')),
                      );
                    }
                  },
                ),
                _buildActionButton(
                  Icons.share,
                  'SHARE',
                  () {
                    // Share workout
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing not implemented yet')),
                    );
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

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
