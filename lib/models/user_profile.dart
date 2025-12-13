class UserProfile {
  final String name;
  final String email;
  final int steps;
  final int calories;

  UserProfile({
    required this.name,
    required this.email,
    required this.steps,
    required this.calories,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? steps,
    int? calories,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'],
      email: json['email'],
      steps: json['steps'],
      calories: json['calories'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'steps': steps,
      'calories': calories,
    };
  }
}