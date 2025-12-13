class CartItem {
  final String name;
  final int battery;
  final double range;
  final double weight;

  CartItem({
    required this.name,
    required this.battery,
    required this.range,
    required this.weight,
  });

  CartItem copyWith({
    String? name,
    int? battery,
    double? range,
    double? weight,
  }) {
    return CartItem(
      name: name ?? this.name,
      battery: battery ?? this.battery,
      range: range ?? this.range,
      weight: weight ?? this.weight,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json['name'],
      battery: json['battery'],
      range: (json['range'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'battery': battery,
      'range': range,
      'weight': weight,
    };
  }
}