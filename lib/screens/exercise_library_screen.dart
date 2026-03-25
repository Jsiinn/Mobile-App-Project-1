import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/bottom_nav.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final _filters = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Shoulders',
    'Arms',
    'Core'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final scheme = Theme.of(context).colorScheme;

    final exercises = _selectedFilter == 'All'
        ? provider.exercises
        : provider.exercises
            .where((e) => e['muscle_group'] == _selectedFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Library')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.loadExercises();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                provider.searchExercises(val);
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _filters[i] == _selectedFilter;
                return FilterChip(
                  label: Text(_filters[i]),
                  selected: selected,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = _filters[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center,
                            size: 64, color: scheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text('No exercises yet',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first exercise',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: exercises.length,
                    itemBuilder: (_, i) {
                      final ex = exercises[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Text(
                              ex['name'][0].toUpperCase(),
                              style: TextStyle(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(ex['name']),
                          subtitle: Text(ex['muscle_group']),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showExerciseDialog(
                                    context, provider,
                                    exercise: ex),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _confirmDelete(context, provider, ex['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExerciseDialog(context, provider),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 1,
        onTap: (i) => _navigate(context, i),
      ),
    );
  }

  void _showExerciseDialog(BuildContext context, WorkoutProvider provider,
      {Map<String, dynamic>? exercise}) {
    final nameController = TextEditingController(text: exercise?['name'] ?? '');
    final equipmentController =
        TextEditingController(text: exercise?['equipment'] ?? '');
    String selectedMuscle = exercise?['muscle_group'] ?? 'Chest';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setS) => AlertDialog(
          title: Text(exercise == null ? 'Add Exercise' : 'Edit Exercise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Exercise name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedMuscle,
                decoration: const InputDecoration(
                  labelText: 'Muscle group',
                  border: OutlineInputBorder(),
                ),
                items: ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) => setS(() => selectedMuscle = val!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: equipmentController,
                decoration: const InputDecoration(
                  labelText: 'Equipment (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                final data = {
                  'name': nameController.text.trim(),
                  'muscle_group': selectedMuscle,
                  'equipment': equipmentController.text.trim(),
                  'notes': '',
                };
                if (exercise == null) {
                  await provider.addExercise(data);
                } else {
                  await provider
                      .updateExercise({...data, 'id': exercise['id']});
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(exercise == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WorkoutProvider provider, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete exercise?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await provider.deleteExercise(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
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
