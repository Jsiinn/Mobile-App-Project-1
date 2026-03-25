import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/bottom_nav.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final scheme = Theme.of(context).colorScheme;
    final workouts = provider.workouts;
    final streak = provider.getStreak();

    return Scaffold(
      appBar: AppBar(title: const Text('Progress & Stats')),
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                      size: 64, color: scheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No data yet',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Complete workouts to see your progress',
                      style: TextStyle(color: scheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stat cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Workouts',
                        value: '${workouts.length}',
                        icon: Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Day Streak',
                        value: '$streak',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Simple bar chart
                Text('Workouts this week',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _WeeklyChart(workouts: workouts),
                const SizedBox(height: 24),

                // Workout history
                Text('Workout History',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...workouts.map((w) {
                  final date = DateTime.parse(w['date']);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(Icons.fitness_center,
                            color: scheme.onPrimaryContainer),
                      ),
                      title: const Text('Workout'),
                      subtitle: Text('${date.day}/${date.month}/${date.year}'),
                    ),
                  );
                }),
              ],
            ),
      bottomNavigationBar: BottomNav(
        currentIndex: 3,
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
        break;
      case 4:
        Navigator.pushNamed(context, '/ai');
        break;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> workouts;
  const _WeeklyChart({required this.workouts});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final counts = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return workouts.where((w) {
        final d = DateTime.parse(w['date']);
        return d.year == day.year && d.month == day.month && d.day == day.day;
      }).length;
    });
    final maxCount = counts.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final ratio = maxCount == 0 ? 0.0 : counts[i] / maxCount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: ratio == 0 ? 4 : 80 * ratio,
                    decoration: BoxDecoration(
                      color: ratio > 0 ? scheme.primary : scheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(days[i],
                      style: TextStyle(
                          fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
