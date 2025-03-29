import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_model.dart';

class WorkoutStorageService {
  // Singleton pattern
  static final WorkoutStorageService _instance = WorkoutStorageService._internal();
  factory WorkoutStorageService() => _instance;
  WorkoutStorageService._internal();
  
  // Storage key for workouts
  static const String _workoutsKey = 'saved_workouts';
  
  // Save a workout to local storage
  Future<bool> saveWorkout(WorkoutModel workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing workouts
      final List<String> workouts = prefs.getStringList(_workoutsKey) ?? [];
      
      // Add new workout
      workouts.add(workout.toJsonString());
      
      // Save updated list
      final success = await prefs.setStringList(_workoutsKey, workouts);
      
      return success;
    } catch (e) {
      debugPrint('Error saving workout: $e');
      return false;
    }
  }
  
  // Get all saved workouts
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get saved workouts
      final List<String> workoutStrings = prefs.getStringList(_workoutsKey) ?? [];
      
      // Convert to WorkoutModel objects
      final workouts = workoutStrings.map((workoutString) {
        try {
          return WorkoutModel.fromJsonString(workoutString);
        } catch (e) {
          debugPrint('Error parsing workout: $e');
          return null;
        }
      }).whereType<WorkoutModel>().toList();
      
      // Sort by date (newest first)
      workouts.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      return workouts;
    } catch (e) {
      debugPrint('Error loading workouts: $e');
      return [];
    }
  }
  
  // Delete a workout by ID
  Future<bool> deleteWorkout(String workoutId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing workouts
      final List<String> workoutStrings = prefs.getStringList(_workoutsKey) ?? [];
      
      // Filter out the workout to delete
      final updatedWorkoutStrings = workoutStrings.where((workoutString) {
        try {
          final workout = jsonDecode(workoutString);
          return workout['id'] != workoutId;
        } catch (e) {
          return true; // Keep entries that can't be parsed
        }
      }).toList();
      
      // Save updated list
      if (updatedWorkoutStrings.length != workoutStrings.length) {
        final success = await prefs.setStringList(_workoutsKey, updatedWorkoutStrings);
        return success;
      }
      
      return false; // Workout not found
    } catch (e) {
      debugPrint('Error deleting workout: $e');
      return false;
    }
  }
  
  // Clear all saved workouts
  Future<bool> clearAllWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_workoutsKey);
      return success;
    } catch (e) {
      debugPrint('Error clearing workouts: $e');
      return false;
    }
  }
}
