class WorkoutSet {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final int setNumber;
  final int reps;
  final double weight;

  WorkoutSet({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      workoutId: map['workout_id'],
      exerciseId: map['exercise_id'],
      setNumber: map['set_number'],
      reps: map['reps'],
      weight: map['weight'],
    );
  }
}
