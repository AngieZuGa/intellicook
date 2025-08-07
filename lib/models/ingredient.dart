class Ingredient {
  final int? id;
  final String name;
  final double quantity;
  final String unit;

  Ingredient({this.id, required this.name, required this.quantity, required this.unit});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'],
    );
  }
}