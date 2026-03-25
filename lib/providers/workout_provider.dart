import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class WorkoutProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _workouts = [];
  List<Map<String, dynamic>> _currentSets = [];
  int? _activeWorkoutId;
  bool _isWorkoutActive = false;

  List<Map<String, dynamic>> get exercises => _exercises;
  List<Map<String, dynamic>> get workouts => _workouts;
  List<Map<String, dynamic>> get currentSets => _currentSets;
  int? get activeWorkoutId => _activeWorkoutId;
  bool get isWorkoutActive => _isWorkoutActive;

  String get unitPreference => prefs.getString('unit_preference') ?? 'kg';

  WorkoutProvider(this.prefs) {
    loadExercises();
    loadWorkouts();
  }

  Future<void> loadExercises() async {
    _exercises = await _db.getAllExercises();
    notifyListeners();
  }

  Future<void> loadWorkouts() async {
    _workouts = await _db.getAllWorkouts();
    notifyListeners();
  }

  Future<void> searchExercises(String query) async {
    if (query.isEmpty) {
      await loadExercises();
    } else {
      _exercises = await _db.searchExercises(query);
      notifyListeners();
    }
  }

  Future<void> addExercise(Map<String, dynamic> exercise) async {
    await _db.insertExercise(exercise);
    await loadExercises();
  }

  Future<void> updateExercise(Map<String, dynamic> exercise) async {
    await _db.updateExercise(exercise);
    await loadExercises();
  }

  Future<void> deleteExercise(int id) async {
    await _db.deleteExercise(id);
    await loadExercises();
  }

  Future<int> startWorkout() async {
    final workoutId = await _db.insertWorkout({
      'date': DateTime.now().toIso8601String(),
      'notes': '',
    });
    _activeWorkoutId = workoutId;
    _isWorkoutActive = true;
    _currentSets = [];
    prefs.setInt('active_workout_id', workoutId);
    prefs.setBool('is_workout_active', true);
    notifyListeners();
    return workoutId;
  }

  Future<void> addSet(Map<String, dynamic> workoutSet) async {
    await _db.insertWorkoutSet(workoutSet);
    if (_activeWorkoutId != null) {
      _currentSets = await _db.getSetsForWorkout(_activeWorkoutId!);
    }
    notifyListeners();
  }

  Future<void> removeSet(int setId) async {
    await _db.deleteWorkoutSet(setId);
    if (_activeWorkoutId != null) {
      _currentSets = await _db.getSetsForWorkout(_activeWorkoutId!);
    }
    notifyListeners();
  }

  Future<void> finishWorkout() async {
    _isWorkoutActive = false;
    _activeWorkoutId = null;
    _currentSets = [];
    prefs.remove('active_workout_id');
    prefs.setBool('is_workout_active', false);
    await loadWorkouts();
    notifyListeners();
  }

  Future<void> cancelWorkout() async {
    if (_activeWorkoutId != null) {
      for (final set in _currentSets) {
        await _db.deleteWorkoutSet(set['id']);
      }
    }
    _isWorkoutActive = false;
    _activeWorkoutId = null;
    _currentSets = [];
    prefs.remove('active_workout_id');
    prefs.setBool('is_workout_active', false);
    notifyListeners();
  }

  void setUnitPreference(String unit) {
    prefs.setString('unit_preference', unit);
    notifyListeners();
  }

  int getStreak() {
    if (_workouts.isEmpty) return 0;
    int streak = 0;
    DateTime today = DateTime.now();
    for (int i = 0; i < _workouts.length; i++) {
      final workoutDate = DateTime.parse(_workouts[i]['date']);
      final diff = today.difference(workoutDate).inDays;
      if (diff == i) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
