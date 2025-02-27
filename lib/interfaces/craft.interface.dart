class Craft {
  final String id;
  final String name;
  // Coût en ressources pour réaliser le craft
  final Map<String, int> cost;
  // Output du craft : peut être un objet ou un effet. Ici, on le définit comme un mapping.
  final Map<String, dynamic> output;

  Craft({
    required this.id,
    required this.name,
    required this.cost,
    required this.output,
  });

  factory Craft.fromJson(Map<String, dynamic> json) {
    return Craft(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: Map<String, int>.from(json['cost']),
      output: Map<String, dynamic>.from(json['output']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cost': cost,
    'output': output,
  };
}
