class Resource {
  final String id;
  final String name;
  final int initialAmount;
  bool unlock;
  final int value;
  final bool isCurrency;
  BigInt amount;
  final Map<String, BigInt>? unlockCost; // Coût pour débloquer

  Resource({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.unlock,
    required this.value,
    this.isCurrency = false,
    BigInt? amount,
    this.unlockCost,
  }) : amount = amount ?? BigInt.from(initialAmount);

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      name: json['name'] as String,
      initialAmount: json['initialAmount'] as int,
      unlock: json['unlock'] as bool,
      value: json['value'] as int,
      isCurrency: json['isCurrency'] as bool,
      amount: BigInt.from(json['initialAmount']),
      unlockCost:
          json.containsKey('unlockCost') && json['unlockCost'] != null
              ? (json['unlockCost'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(key, BigInt.from(value)),
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unlock': unlock,
    'value': value,
    'amount': amount.toString(),
    'unlockCost': unlockCost,
  };
}
