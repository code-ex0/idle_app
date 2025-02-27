import 'package:test_1/interfaces/building.enum.dart';

class Building {
  final String id;
  final String name;
  final Map<String, BigInt> cost;
  final Map<String, BigInt> production;
  final int durability;
  final BuildingType type;
  final bool infiniteDurability;
  BigInt amount;
  int currentDurability;

  Building({
    required this.id,
    required this.name,
    required this.cost,
    required this.production,
    required this.durability,
    required this.type,
    required this.infiniteDurability,

    BigInt? amount,
    this.currentDurability = 0,
  }) : amount = amount ?? BigInt.from(0);

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: (json['cost'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, BigInt.from(value)),
      ),
      production: (json['production'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, BigInt.from(value)),
      ),
      durability: json['durability'] as int,
      type: buildingTypeFromJson(json['type']),
      infiniteDurability: json['infiniteDurability'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cost': cost,
    'production': production,
    'durability': durability,
    'type': type,
    'amount': amount.toString(),
    'currentDurability': currentDurability,
    'infiniteDurability': infiniteDurability,
  };
}
