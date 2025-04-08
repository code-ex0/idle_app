import 'package:flutter/material.dart';
import 'package:test_1/interfaces/achievement.enum.dart';


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
    // Convertir le type depuis la chaîne JSON
    final typeStr = json['type'] as String;
    final achievementType = AchievementType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == typeStr.toLowerCase(),
      orElse: () => AchievementType.special,
    );
    
    // Convertir l'icône depuis la chaîne JSON ou l'entier
    IconData iconData;
    final iconValue = json['icon'];
    if (iconValue is int) {
      iconData = IconData(iconValue, fontFamily: 'MaterialIcons');
    } else if (iconValue is String) {
      // Mapper les noms d'icônes aux IconData correspondants
      switch (iconValue) {
        case 'forest':
          iconData = Icons.forest;
          break;
        case 'business':
          iconData = Icons.business;
          break;
        case 'mouse':
          iconData = Icons.mouse;
          break;
        case 'shopping_cart':
          iconData = Icons.shopping_cart;
          break;
        case 'timer':
          iconData = Icons.timer;
          break;
        case 'attach_money':
          iconData = Icons.attach_money;
          break;
        case 'trending_up':
          iconData = Icons.trending_up;
          break;
        default:
          iconData = Icons.emoji_events; // Icône par défaut pour les succès
      }
    } else {
      iconData = Icons.emoji_events; // Icône par défaut
    }
    
    // Traiter les requirements pour convertir les valeurs en BigInt
    final Map<String, dynamic> processedRequirements = {};
    (json['requirements'] as Map<String, dynamic>).forEach((key, value) {
      if (value is String) {
        try {
          processedRequirements[key] = BigInt.parse(value);
        } catch (e) {
          processedRequirements[key] = value;
        }
      } else {
        processedRequirements[key] = value;
      }
    });

    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: achievementType,
      requirements: processedRequirements,
      icon: iconData,
      points: json['points'] is String 
          ? BigInt.parse(json['points'] as String)
          : BigInt.from(json['points'] as int),
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