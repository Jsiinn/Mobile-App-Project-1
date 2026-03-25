import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/workout_provider.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  Map<String, dynamic>? _selectedExercise;
  int _restSeconds = 0;
  Timer? _restTimer;
  bool _isResting = false;
  int _setNumber = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<WorkoutProvider>();
      if (!provider.isWorkoutActive) {
        await provider.startWorkout();
      }
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restSeconds = seconds;
      _isResting = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_restSeconds > 0) {
          _restSeconds--;
        } else {
          _isResting = false;
          t.cancel();
        }
      });
    });
  }

  Future<void> _logSet(WorkoutProvider provider) async {
    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise.')),
      );
      return;
    }
    final reps = int.tryParse(_repsController.text);
    final weight = double.tryParse(_weightController.text);
    if (reps == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid reps and weight.')),
      );
      return;
    }
    await provider.addSet({
      'workout_id': provider.activeWorkoutId,
      'exercise_id': _selectedExercise!['id'],
      'set_number': _setNumber,
      'reps': reps,
      'weight': weight,
    });
    setState(() => _setNumber++);
    _repsController.clear();
    _weightController.clear();
    _startRestTimer(90);
  }

  Future<void> _finishWorkout(WorkoutProvider provider) async {
    if (provider.currentSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log at least one set to save.')),
      );
      return;
    }
    await provider.finishWorkout();
    if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<bool> _onWillPop(WorkoutProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave workout?'),
        content: const Text('Your session will be lost if you leave now.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Stay')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (result == true) await provider.cancelWorkout();
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final scheme = Theme.of(context).colorScheme;
    final unit = provider.unitPreference;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) await _onWillPop(provider);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Session'),
          actions: [
            TextButton(
              onPressed: () => _finishWorkout(provider),
              child: const Text('Finish'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Exercise picker
            DropdownButtonFormField<Map<String, dynamic>>(
              value: _selectedExercise,
              decoration: const InputDecoration(
                labelText: 'Select exercise',
                border: OutlineInputBorder(),
              ),
              items: provider.exercises
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e['name']),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedExercise = val),
            ),
            const SizedBox(height: 16),

            // Reps and weight inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight ($unit)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _logSet(provider),
              icon: const Icon(Icons.add),
              label: Text('Log Set $_setNumber'),
            ),
            const SizedBox(height: 24),

            // Rest timer
            if (_isResting)
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: scheme.onPrimaryContainer),
                      const SizedBox(width: 12),
                      Text(
                        'Rest: ${_restSeconds}s',
                        style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(() => _isResting = false),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Logged sets
            if (provider.currentSets.isNotEmpty) ...[
              Text('Logged Sets',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...provider.currentSets.asMap().entries.map((e) {
                final s = e.value;
                final exercise = provider.exercises.firstWhere(
                  (ex) => ex['id'] == s['exercise_id'],
                  orElse: () => {'name': 'Unknown'},
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text(exercise['name']),
                    subtitle: Text(
                        'Set ${s['set_number']} · ${s['reps']} reps · ${s['weight']}$unit'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => provider.removeSet(s['id']),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
