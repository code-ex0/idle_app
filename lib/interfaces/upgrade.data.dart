class Upgrade {
  final String id;
  final String name;
  final int level;
  // Coût de base de l'upgrade
  final Map<String, int> baseCost;
  // Effet de l'upgrade, par exemple un mapping de bonus { bonusType: valeur }
  final Map<String, int> effect;
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
      baseCost: Map<String, int>.from(json['baseCost']),
      effect: Map<String, int>.from(json['effect']),
      infiniteUpgrade: json['infiniteUpgrade'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'level': level,
    'baseCost': baseCost,
    'effect': effect,
    'infiniteUpgrade': infiniteUpgrade,
  };
}
