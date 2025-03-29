import 'package:flutter/material.dart';
import '../services/workout_storage_service.dart';
import '../utils/debug_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _debugMode = false;
  final DebugState _debugState = DebugState();
  
  @override
  void initState() {
    super.initState();
    _loadDebugState();
  }
  
  Future<void> _loadDebugState() async {
    await _debugState.loadState();
    if (mounted) {
      setState(() {
        _debugMode = _debugState.enabled;
      });
    }
  }

  void _clearHistory() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Workouts'),
        content: const Text(
          'This will permanently delete all your workout history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    
    // If user confirmed, clear history
    if (confirmed == true) {
      final success = await WorkoutStorageService().clearAllWorkouts();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Workout history cleared' : 'Failed to clear workout history'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Debug Mode Toggle
          SwitchListTile(
            title: const Text(
              'Debug Mode',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Show additional information for debugging',
              style: TextStyle(color: Colors.grey),
            ),
            value: _debugMode,
            activeColor: Colors.white,
            activeTrackColor: Colors.grey[700],
            onChanged: (value) async {
              setState(() {
                _debugMode = value;
              });
              await _debugState.setEnabled(value);
            },
          ),
          
          const Divider(color: Colors.grey),
          
          // Data Management Section
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Clear History Option
          ListTile(
            title: const Text(
              'Clear All Workout Data',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'This action cannot be undone',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
            onTap: _clearHistory,
          ),
          
          const Divider(color: Colors.grey),
          
          // App Information Section
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'ABOUT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Version Information
          ListTile(
            title: const Text(
              'Version',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              '1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              if (_debugMode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debug build - Not for production use'),
                  ),
                );
              }
            },
          ),
          
          // Debug Information (only visible in debug mode)
          if (_debugMode)
            ListTile(
              title: const Text(
                'Debug Information',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'View technical details',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(
                Icons.code,
                color: Colors.blue,
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Debug Information'),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Build Mode: Debug'),
                          const Text('Platform: Flutter'),
                          const SizedBox(height: 8),
                          const Text('Storage:'),
                          FutureBuilder<int>(
                            future: _getWorkoutCount(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              return Text('Saved Workouts: ${snapshot.data ?? 0}');
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CLOSE'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
  
  Future<int> _getWorkoutCount() async {
    final workouts = await WorkoutStorageService().getAllWorkouts();
    return workouts.length;
  }
}
