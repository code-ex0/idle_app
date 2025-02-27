import 'package:test_1/interfaces/building.enum.dart';

class Building {
  final String id;
  final String name;
  final Map<String, int> cost;
  final Map<String, int> production;
  final int durability;
  final BuildingType type;
  final bool infiniteDurability;
  int amount;
  int currentDurability;

  Building({
    required this.id,
    required this.name,
    required this.cost,
    required this.production,
    required this.durability,
    required this.type,
    required this.infiniteDurability,

    this.amount = 0,
    this.currentDurability = 0,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: Map<String, int>.from(json['cost']),
      production: Map<String, int>.from(json['production']),
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
    'amount': amount,
    'currentDurability': currentDurability,
    'infiniteDurability': infiniteDurability,
  };
}
