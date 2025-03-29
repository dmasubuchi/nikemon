import 'package:shared_preferences/shared_preferences.dart';

class DebugState {
  // Singleton pattern
  static final DebugState _instance = DebugState._internal();
  factory DebugState() => _instance;
  DebugState._internal();

  // Debug mode flag
  bool _enabled = false;
  
  // Getter for debug mode
  bool get enabled => _enabled;
  
  // Setter for debug mode with persistence
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('debug_mode_enabled', value);
  }
  
  // Load debug state from SharedPreferences
  Future<void> loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool('debug_mode_enabled') ?? false;
  }
}
