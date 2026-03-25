class User {
  final int? id;
  final String username;
  final String unitPreference;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.unitPreference,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'unit_preference': unitPreference,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      unitPreference: map['unit_preference'],
      createdAt: map['created_at'],
    );
  }
}
