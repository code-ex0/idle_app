class Resource {
  final String id;
  final String name;
  final int initialAmount;
  final bool unlock;
  final int value;
  final bool isCurrency;
  BigInt amount;

  Resource({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.unlock,
    required this.value,
    this.isCurrency = false,
    BigInt? amount,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'unlock': unlock,
    'value': value,
    'amount': amount.toString(),
  };
}
