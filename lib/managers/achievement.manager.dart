import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_1/interfaces/achievement.interface.dart';
import 'package:test_1/interfaces/achievement.enum.dart';
import 'package:test_1/managers/resource.manager.dart';
import 'package:test_1/managers/building.manager.dart';
import 'dart:async';


class AchievementManager extends ChangeNotifier {
  static final AchievementManager _instance = AchievementManager._internal();
  final Map<String, Achievement> _achievements = {};
  BigInt _totalPoints = BigInt.zero;

  factory AchievementManager() {
    return _instance;
  }

  AchievementManager._internal();

  Map<String, Achievement> get achievements => _achievements;
  BigInt get totalPoints => _totalPoints;

  Stream<Achievement> get achievementUnlockStream => _achievementStreamController.stream;
  final _achievementStreamController = StreamController<Achievement>.broadcast();

  Future<void> initialize() async {
    await _initializeAchievements();
    _startListening();
    notifyListeners();
  }

  Future<void> _initializeAchievements() async {
    try {
      // Charger le fichier game_data.json
      final String jsonString = await rootBundle.loadString('assets/data/game_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Vérifier si la section achievements existe
      if (jsonData.containsKey('achievements') && jsonData['achievements'] is List) {
        final achievementsList = jsonData['achievements'] as List;
        
        // Parcourir chaque achievement et l'ajouter à la map
        for (final achievementJson in achievementsList) {
          final achievement = Achievement.fromJson(achievementJson);
          _achievements[achievement.id] = achievement;
        }
        
        debugPrint('${_achievements.length} achievements chargés depuis game_data.json');
      } else {
        throw Exception('Aucune section achievements trouvée dans game_data.json');
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des achievements: $e');
      throw Exception('Erreur lors du chargement des achievements: $e');
    }
  }
  
  // ignore: unused_element
  void _initializeDefaultAchievements() {
    // Cette méthode ne doit plus être utilisée
    throw Exception('Initialisation des achievements par défaut est désactivée');
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

  void _startListening() {
    // Implementation of _startListening method
  }
} 