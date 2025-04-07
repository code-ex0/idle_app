import 'package:flutter/material.dart';
import 'package:test_1/interfaces/achievement.interface.dart';
import 'package:test_1/managers/resource.manager.dart';
import 'package:test_1/managers/building.manager.dart';

class AchievementManager extends ChangeNotifier {
  final Map<String, Achievement> _achievements = {};
  BigInt _totalPoints = BigInt.zero;

  Map<String, Achievement> get achievements => _achievements;
  BigInt get totalPoints => _totalPoints;

  AchievementManager() {
    _initializeAchievements();
  }

  void _initializeAchievements() {
    // Resource achievements
    _achievements['first_wood'] = Achievement(
      id: 'first_wood',
      name: 'Premier Bois',
      description: 'Collectez votre premier bois',
      type: AchievementType.resource,
      requirements: {'resourceId': 'wood', 'amount': BigInt.from(1)},
      icon: Icons.forest,
      points: BigInt.from(10),
    );

    _achievements['wood_master'] = Achievement(
      id: 'wood_master',
      name: 'Maître du Bois',
      description: 'Collectez 1000 bois',
      type: AchievementType.resource,
      requirements: {'resourceId': 'wood', 'amount': BigInt.from(1000)},
      icon: Icons.forest,
      points: BigInt.from(50),
    );

    // Building achievements
    _achievements['first_building'] = Achievement(
      id: 'first_building',
      name: 'Premier Bâtiment',
      description: 'Construisez votre premier bâtiment',
      type: AchievementType.building,
      requirements: {'buildingId': 'any', 'amount': BigInt.from(1)},
      icon: Icons.business,
      points: BigInt.from(20),
    );

    _achievements['building_tycoon'] = Achievement(
      id: 'building_tycoon',
      name: 'Magnat des Bâtiments',
      description: 'Possédez 10 bâtiments de chaque type',
      type: AchievementType.building,
      requirements: {'buildingId': 'all', 'amount': BigInt.from(10)},
      icon: Icons.business,
      points: BigInt.from(100),
    );

    // Click achievements
    _achievements['clicker'] = Achievement(
      id: 'clicker',
      name: 'Clicker',
      description: 'Effectuez 100 clics',
      type: AchievementType.click,
      requirements: {'clicks': BigInt.from(100)},
      icon: Icons.mouse,
      points: BigInt.from(15),
    );

    _achievements['click_master'] = Achievement(
      id: 'click_master',
      name: 'Maître du Clic',
      description: 'Effectuez 1000 clics',
      type: AchievementType.click,
      requirements: {'clicks': BigInt.from(1000)},
      icon: Icons.mouse,
      points: BigInt.from(75),
    );

    // Market achievements
    _achievements['first_trade'] = Achievement(
      id: 'first_trade',
      name: 'Premier Échange',
      description: 'Effectuez votre premier échange sur le marché',
      type: AchievementType.market,
      requirements: {'trades': BigInt.from(1)},
      icon: Icons.shopping_cart,
      points: BigInt.from(25),
    );

    _achievements['market_tycoon'] = Achievement(
      id: 'market_tycoon',
      name: 'Magnat du Marché',
      description: 'Effectuez 100 échanges sur le marché',
      type: AchievementType.market,
      requirements: {'trades': BigInt.from(100)},
      icon: Icons.shopping_cart,
      points: BigInt.from(150),
    );

    // Time achievements
    _achievements['first_hour'] = Achievement(
      id: 'first_hour',
      name: 'Première Heure',
      description: 'Jouez pendant une heure',
      type: AchievementType.time,
      requirements: {'minutes': BigInt.from(60)},
      icon: Icons.timer,
      points: BigInt.from(30),
    );

    // Special achievements
    _achievements['millionaire'] = Achievement(
      id: 'millionaire',
      name: 'Millionnaire',
      description: 'Atteignez 1 million de dollars',
      type: AchievementType.special,
      requirements: {'resourceId': 'dollar', 'amount': BigInt.from(1000000)},
      icon: Icons.attach_money,
      points: BigInt.from(200),
      isSecret: true,
    );
  }

  void checkAchievements({
    required ResourceManager resourceManager,
    required BuildingManager buildingManager,
    required BigInt totalClicks,
    required BigInt totalTrades,
    required BigInt minutesPlayed,
  }) {
    bool hasChanges = false;

    for (var achievement in _achievements.values) {
      if (achievement.isUnlocked) continue;

      bool isUnlocked = false;

      switch (achievement.type) {
        case AchievementType.resource:
          final resourceId = achievement.requirements['resourceId'] as String;
          final requiredAmount = achievement.requirements['amount'] as BigInt;
          final resource = resourceManager.resources[resourceId];
          
          if (resource != null && resource.amount >= requiredAmount) {
            isUnlocked = true;
          }
          break;

        case AchievementType.building:
          final buildingId = achievement.requirements['buildingId'] as String;
          final requiredAmount = achievement.requirements['amount'] as BigInt;
          
          if (buildingId == 'any') {
            isUnlocked = buildingManager.buildings.values.any((b) => b.amount >= requiredAmount);
          } else if (buildingId == 'all') {
            isUnlocked = buildingManager.buildings.values.every((b) => b.amount >= requiredAmount);
          } else {
            final building = buildingManager.buildings[buildingId];
            isUnlocked = building != null && building.amount >= requiredAmount;
          }
          break;

        case AchievementType.click:
          final requiredClicks = achievement.requirements['clicks'] as BigInt;
          isUnlocked = totalClicks >= requiredClicks;
          break;

        case AchievementType.market:
          final requiredTrades = achievement.requirements['trades'] as BigInt;
          isUnlocked = totalTrades >= requiredTrades;
          break;

        case AchievementType.time:
          final requiredMinutes = achievement.requirements['minutes'] as BigInt;
          isUnlocked = minutesPlayed >= requiredMinutes;
          break;

        case AchievementType.special:
          // Special achievements can have custom logic
          final resourceId = achievement.requirements['resourceId'] as String;
          final requiredAmount = achievement.requirements['amount'] as BigInt;
          final resource = resourceManager.resources[resourceId];
          
          if (resource != null && resource.amount >= requiredAmount) {
            isUnlocked = true;
          }
          break;
      }

      if (isUnlocked) {
        achievement.isUnlocked = true;
        achievement.unlockedAt = DateTime.now();
        _totalPoints += achievement.points;
        hasChanges = true;
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.values.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.values.where((a) => !a.isUnlocked && !a.isSecret).toList();
  }

  List<Achievement> getSecretAchievements() {
    return _achievements.values.where((a) => a.isSecret).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'achievements': _achievements.map((key, value) => MapEntry(key, value.toJson())),
      'totalPoints': _totalPoints.toString(),
    };
  }

  void fromJson(Map<String, dynamic> json) {
    _achievements.clear();
    final achievementsJson = json['achievements'] as Map<String, dynamic>;
    achievementsJson.forEach((key, value) {
      _achievements[key] = Achievement.fromJson(value);
    });
    _totalPoints = BigInt.parse(json['totalPoints'] as String);
    notifyListeners();
  }
} 