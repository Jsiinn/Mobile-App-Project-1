import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/bottom_nav.dart';

class AiTrainerScreen extends StatelessWidget {
  const AiTrainerScreen({super.key});

  List<Map<String, String>> _getSuggestions(WorkoutProvider provider) {
    final workouts = provider.workouts;
    final exercises = provider.exercises;

    if (exercises.isEmpty) {
      return [
        {
          'title': 'Add exercises first',
          'desc': 'Head to the library and add some exercises to get started.',
        }
      ];
    }

    if (workouts.isEmpty) {
      return [
        {
          'title': 'Full Body Starter',
          'desc':
              'Great for your first session — covers all major muscle groups.',
        },
        {
          'title': 'Mobility & Warmup',
          'desc': 'Light movement to get your body ready for training.',
        },
      ];
    }

    final recentCount = workouts.length;
    if (recentCount % 3 == 0) {
      return [
        {
          'title': 'Rest Day',
          'desc': 'You\'ve been consistent — recovery is part of the quest.',
        }
      ];
    }

    final muscleGroups =
        exercises.map((e) => e['muscle_group'] as String).toSet().toList();
    muscleGroups.shuffle();
    final suggested = muscleGroups.take(2).toList();

    return suggested
        .map((m) => {
              'title': '$m Day',
              'desc': 'Focus on $m exercises based on your library.',
            })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final scheme = Theme.of(context).colorScheme;
    final suggestions = _getSuggestions(provider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Trainer')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header card
          Card(
            color: scheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.smart_toy,
                      color: scheme.onPrimaryContainer, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your AI Trainer',
                            style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                          'Suggestions based on your workout history',
                          style: TextStyle(color: scheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Suggested for today',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...suggestions.map((s) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(Icons.fitness_center,
                                color: scheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 12),
                          Text(s['title']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(s['desc']!,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/workout'),
                          child: const Text('Start this workout'),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 4,
        onTap: (i) => _navigate(context, i),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/library');
        break;
      case 3:
        Navigator.pushNamed(context, '/progress');
        break;
      case 4:
        break;
    }
  }
}
