import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/bottom_nav.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final scheme = Theme.of(context).colorScheme;
    final streak = provider.getStreak();
    final recentWorkouts = provider.workouts.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Quest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, provider),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Streak card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department,
                      color: streak > 0 ? Colors.orange : scheme.outline,
                      size: 36),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$streak day streak',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Keep it going!',
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Start workout button
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/workout'),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),

          // Recent workouts
          Text('Recent Workouts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
          const SizedBox(height: 8),
          if (recentWorkouts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.fitness_center,
                        size: 48, color: scheme.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('No workouts yet — start your first quest!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...recentWorkouts.map((w) {
              final date = DateTime.parse(w['date']);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.fitness_center,
                        color: scheme.onPrimaryContainer),
                  ),
                  title: Text('Workout'),
                  subtitle: Text('${date.day}/${date.month}/${date.year}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/progress'),
                ),
              );
            }),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 0,
        onTap: (i) => _navigate(context, i),
      ),
    );
  }

  void _showSettings(BuildContext context, WorkoutProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text('Weight unit'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'kg', label: Text('kg')),
                ButtonSegment(value: 'lb', label: Text('lb')),
              ],
              selected: {provider.unitPreference},
              onSelectionChanged: (val) {
                provider.setUnitPreference(val.first);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/library');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushNamed(context, '/progress');
        break;
      case 4:
        Navigator.pushNamed(context, '/ai');
        break;
    }
  }
}
