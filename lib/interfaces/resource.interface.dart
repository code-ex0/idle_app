class Resource {
  final String id;
  final String name;
  final BigInt initialAmount;
  final String icon;
  BigInt value;
  BigInt amount;
  final Map<String, BigInt>? unlockCost; // Coût pour débloquer
  bool isUnlocked;

  Resource({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.icon,
    required this.value,
    BigInt? amount,
    this.unlockCost,
    this.isUnlocked = false,
  }) : amount = amount ?? initialAmount;

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      name: json['name'] as String,
      initialAmount: BigInt.from(json['initialAmount']),
      icon: json['icon'] as String? ?? 'default_icon',
      value: BigInt.from(json['value']),
      amount: BigInt.from(json['initialAmount']),
      unlockCost: json['unlockCost'] != null
          ? (json['unlockCost'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, BigInt.from(value)),
            )
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialAmount': initialAmount.toString(),
    'icon': icon,
    'value': value.toString(),
    'amount': amount.toString(),
    'unlockCost': unlockCost?.map((key, value) => MapEntry(key, value.toString())),
    'isUnlocked': isUnlocked,
  };
}
