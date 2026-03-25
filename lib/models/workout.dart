class Workout {
  final int? id;
  final String date;
  final String? notes;

  Workout({
    this.id,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'notes': notes,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      date: map['date'],
      notes: map['notes'],
    );
  }
}
