class TelemetryData {
  final double battery; // 0-100
  final double rangeToUser; // meter
  final double weight; // kg
  final int calories; // kcal
  final int steps;

  TelemetryData({
    this.battery = 0,
    this.rangeToUser = 0,
    this.weight = 0,
    this.calories = 0,
    this.steps = 0,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      battery: (json['battery'] ?? 0).toDouble(),
      rangeToUser: (json['range'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toInt(),
      steps: (json['steps'] ?? 0).toInt(),
    );
  }

  TelemetryData copyWith({
    double? battery,
    double? rangeToUser,
    double? weight,
    int? calories,
    int? steps,
  }) {
    return TelemetryData(
      battery: battery ?? this.battery,
      rangeToUser: rangeToUser ?? this.rangeToUser,
      weight: weight ?? this.weight,
      calories: calories ?? this.calories,
      steps: steps ?? this.steps,
    );
  }
}
