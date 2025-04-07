import 'package:flutter/material.dart';

enum AchievementType {
  resource,
  building,
  market,
  click,
  time,
  special
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final AchievementType type;
  final Map<String, dynamic> requirements;
  final IconData icon;
  final BigInt points;
  final bool isSecret;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.requirements,
    required this.icon,
    required this.points,
    this.isSecret = false,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
      ),
      requirements: json['requirements'] as Map<String, dynamic>,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      points: BigInt.parse(json['points'] as String),
      isSecret: json['isSecret'] as bool? ?? false,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.toString().split('.').last,
    'requirements': requirements,
    'icon': icon.codePoint,
    'points': points.toString(),
    'isSecret': isSecret,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };
} 