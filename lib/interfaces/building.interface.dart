import 'package:test_1/interfaces/building.enum.dart';

class Building {
  final String id;
  final String name;
  Map<String, BigInt> cost;
  final Map<String, BigInt> production;
  final BigInt durability;
  final BuildingType type;
  final bool infiniteDurability;
  BigInt amount;
  BigInt currentDurability;

  Building({
    required this.id,
    required this.name,
    required this.cost,
    required this.production,
    required this.durability,
    required this.type,
    required this.infiniteDurability,

    BigInt? amount,
    BigInt? currentDurability,
  }) : amount = amount ?? BigInt.from(0),
       currentDurability = currentDurability ?? durability;

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
      durability: BigInt.from(json['durability']),
      type: BuildingType.values.firstWhere(
        (e) => e.toString() == 'BuildingType.${json['type']}',
      ),
      infiniteDurability: json['infiniteDurability'] as bool,
      amount: BigInt.parse(json['amount'] as String),
      currentDurability: BigInt.parse(json['currentDurability'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount.toString(),
    'currentDurability': currentDurability.toString(),
    'durability': durability.toString(),
    'cost': cost.map((k, v) => MapEntry(k, v.toString())),
    'production': production.map((k, v) => MapEntry(k, v.toString())),
    'type': type.toString().split('.').last,
    'infiniteDurability': infiniteDurability,
  };
}
