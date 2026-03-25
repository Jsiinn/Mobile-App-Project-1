class Exercise {
  final int? id;
  final String name;
  final String muscleGroup;
  final String? equipment;
  final String? notes;

  Exercise({
    this.id,
    required this.name,
    required this.muscleGroup,
    this.equipment,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'equipment': equipment,
      'notes': notes,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      muscleGroup: map['muscle_group'],
      equipment: map['equipment'],
      notes: map['notes'],
    );
  }
}
