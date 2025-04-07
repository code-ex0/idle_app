class Upgrade {
  final String id;
  final String name;
  final int level;
  // Coût de base de l'upgrade
  final Map<String, BigInt> baseCost;
  // Effet de l'upgrade, par exemple un mapping de bonus { bonusType: valeur }
  final Map<String, BigInt> effect;
  // Indique si l'upgrade peut être améliorée indéfiniment
  final bool infiniteUpgrade;

  Upgrade({
    required this.id,
    required this.name,
    required this.level,
    required this.baseCost,
    required this.effect,
    required this.infiniteUpgrade,
  });

  factory Upgrade.fromJson(Map<String, dynamic> json) {
    return Upgrade(
      id: json['id'] as String,
      name: json['name'] as String,
      level: json['level'] as int,
      baseCost: (json['baseCost'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, BigInt.from(value)),
      ),
      effect: (json['effect'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, BigInt.from(value)),
      ),
      infiniteUpgrade: json['infiniteUpgrade'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'baseCost': baseCost.map((key, value) => MapEntry(key, value.toString())),
    'effect': effect.map((key, value) => MapEntry(key, value.toString())),
    'infiniteUpgrade': infiniteUpgrade,
  };
}
