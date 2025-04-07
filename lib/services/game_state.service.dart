// lib/game_state.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/managers/building.manager.dart';
import 'package:test_1/managers/market.manager.dart';
import 'package:test_1/managers/resource.manager.dart';
import 'package:test_1/managers/achievement.manager.dart';
import 'package:test_1/managers/event.manager.dart';

class GameState extends ChangeNotifier {
  final ResourceManager resourceManager;
  final BuildingManager buildingManager;
  final MarketManager marketManager;
  final AchievementManager achievementManager;
  final EventManager eventManager;

  Timer? _timer;
  Timer? _tradingTimer;
  Timer? _saveTimer;
  Timer? _achievementCheckTimer;

  // Game objectives and achievements
  final BigInt dolardTarget = BigInt.from(1000000);
  final Map<String, Map<String, BigInt>> statistics = {
    'resources': {},
    'buildings': {},
    'market': {},
  };

  // Game events
  final List<GameEvent> activeEvents = [];
  final List<GameEvent> eventHistory = [];

  bool isGameWon = false;

  GameState({
    required this.resourceManager,
    required this.buildingManager,
    required this.achievementManager,
    required this.marketManager,
    required this.eventManager,
  }) {
    _initializeTimers();
  }

  void _initializeTimers() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
    _tradingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      trade();
    });
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      saveGame();
    });
    _achievementCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAchievements();
    });
  }

  void _checkAchievements() {
    final totalClicks = statistics['resources']?['totalClicks'] ?? BigInt.zero;
    final totalTrades = statistics['market']?['totalTrades'] ?? BigInt.zero;
    final minutesPlayed = statistics['buildings']?['timePlayed'] ?? BigInt.zero;

    achievementManager.checkAchievements(
      resourceManager: resourceManager,
      buildingManager: buildingManager,
      totalClicks: totalClicks,
      totalTrades: totalTrades,
      minutesPlayed: minutesPlayed,
    );
  }

  void clickResource(String resourceId) {
    resourceManager.clickResource(resourceId);
    _updateStatistics('resources', 'totalClicks', BigInt.one);
    notifyListeners();
  }

  void sellResource(String resourceId, BigInt quantity) {
    final resource = resourceManager.resources[resourceId];
    if (resource == null || resource.amount < quantity) return;

    final currency = resourceManager.resources['dollar'];
    if (currency == null) return;

    final revenue = (resource.value * quantity).toInt();
    resource.amount -= quantity;
    currency.amount += BigInt.from(revenue);

    _updateStatistics('market', resourceId, quantity);
    _checkGameWin();
    notifyListeners();
  }

  void buyResource(String resourceId, BigInt quantity) {
    final resource = resourceManager.resources[resourceId];
    final currency = resourceManager.resources['dollar'];
    if (resource == null || currency == null) return;

    final totalCost = (resource.value * quantity).toInt();
    if (currency.amount < BigInt.from(totalCost)) return;

    currency.amount -= BigInt.from(totalCost);
    resource.amount += quantity;

    _updateStatistics('market', resourceId, quantity);
    notifyListeners();
  }

  void _updateStatistics(String category, String resourceId, BigInt amount) {
    final categoryStats = statistics[category];
    if (categoryStats == null) return;

    categoryStats[resourceId] = (categoryStats[resourceId] ?? BigInt.zero) + amount;
  }

  void _checkGameWin() {
    final dollar = resourceManager.resources['dollar']?.amount ?? BigInt.zero;
    if (dollar >= dolardTarget) {
      isGameWon = true;
      notifyListeners();
    }
  }

  void addEvent(GameEvent event) {
    activeEvents.add(event);
    eventHistory.add(event);
    _applyEventEffects(event);
    notifyListeners();
  }

  void _applyEventEffects(GameEvent event) {
    // Apply the effects of the event (e.g., temporary multipliers)
    switch (event.type) {
      case EventType.productionBoost:
        // Puisque la production est final, nous devons appliquer l'effet temporairement d'une autre façon
        // Par exemple, en ajoutant un multiplicateur temporaire dans le BuildingManager
        // Pour simplifier, nous augmentons temporairement la production des ressources
        resourceManager.resources.forEach((id, resource) {
          resource.value = BigInt.from((resource.value.toDouble() * event.multiplier).round());
        });
        break;
      case EventType.marketVolatility:
        marketManager.setVolatility(event.multiplier);
        break;
      case EventType.resourceBonus:
        // Apply resource bonus multiplier to all resources
        resourceManager.resources.forEach((id, resource) {
          resource.value = BigInt.from((resource.value.toDouble() * event.multiplier).round());
        });
        break;
      case EventType.buildingDiscount:
        // Apply building cost discount
        final discountMultiplier = BigInt.from(event.multiplier.round());
        buildingManager.buildings.forEach((id, building) {
          building.cost = building.cost.map((key, value) => 
            MapEntry(key, value ~/ discountMultiplier)
          );
        });
        break;
    }
  }

  Future<void> saveGame() async {
    try {
      final saveData = {
        'resources': resourceManager.resources.map((key, value) => MapEntry(key, value.toJson())),
        'buildings': buildingManager.buildings.map((key, value) => MapEntry(key, value.toJson())),
        'statistics': statistics.map(
          (category, values) => MapEntry(
            category,
            values.map((key, value) => MapEntry(key, value.toString())),
          ),
        ),
        'achievements': achievementManager.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'isGameWon': isGameWon,
      };

      // Implement actual save logic
      final jsonString = jsonEncode(saveData);
      debugPrint('Game saved successfully: ${jsonString.substring(0, 100)}...');
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadGame() async {
    try {
      // Implement actual load logic
      final json = {}; // Load from storage
      
      // Load resources
      final resourcesJson = json['resources'] as Map<String, dynamic>;
      resourcesJson.forEach((key, value) {
        final resource = resourceManager.resources[key];
        if (resource != null) {
          resource.amount = BigInt.parse(value['amount'] as String);
          resource.isUnlocked = value['isUnlocked'] as bool;
        }
      });

      // Load buildings
      final buildingsJson = json['buildings'] as Map<String, dynamic>;
      buildingsJson.forEach((key, value) {
        final building = buildingManager.buildings[key];
        if (building != null) {
          building.amount = BigInt.parse(value['amount'] as String);
          building.currentDurability = BigInt.parse(value['currentDurability'] as String);
        }
      });

      // Load statistics
      final stats = json['statistics'] as Map<String, dynamic>;
      stats.forEach((category, values) {
        statistics[category] = (values as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, BigInt.parse(value as String)),
        );
      });

      // Load achievements
      achievementManager.fromJson(json['achievements'] as Map<String, dynamic>);

      isGameWon = json['isGameWon'] as bool? ?? false;

      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void unlockResource(String resourceId) {
    resourceManager.unlockResource(resourceId);
    notifyListeners();
  }

  void buyBuilding(String buildingId) {
    try {
      buildingManager.buyBuildings(buildingId, BigInt.one, resourceManager);
      _updateStatistics('buildings', buildingId, BigInt.one);
      _checkAchievements();
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void buyBuildingMax(String buildingId) {
    try {
      final maxPossible = buildingManager.calculateMaxBuy(buildingId, resourceManager);
      if (maxPossible > BigInt.zero) {
        buildingManager.buyBuildings(buildingId, maxPossible, resourceManager);
        _updateStatistics('buildings', buildingId, maxPossible);
        _checkAchievements();
      }
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  void tick() {
    buildingManager.updateBuildings(resourceManager);
    notifyListeners();
  }

  bool get objectiveReached {
    final dollar = resourceManager.resources['dollar']?.amount ?? BigInt.zero;
    return dollar >= dolardTarget;
  }

  static String formatResourceAmount(BigInt amount) {
    if (amount < BigInt.from(1000)) {
      return amount.toString();
    }
    double value = amount.toDouble();
    int divisions = 0;
    while (value >= 1000) {
      value /= 1000;
      divisions++;
    }
    return '${value.toStringAsFixed(2)} ${_intToAlphabeticSuffix(divisions)}';
  }

  static String _intToAlphabeticSuffix(int n) {
    String result = '';
    while (n > 0) {
      n--; // ajuste car A correspond à 1
      int remainder = n % 26;
      result = String.fromCharCode(65 + remainder) + result;
      n = n ~/ 26;
    }
    return result;
  }

  static Future<GameState> loadGameState() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/game_data.json',
    );
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    final List<dynamic> resourcesData = jsonData['resources'];
    final Map<String, Resource> resources = {
      for (var res in resourcesData)
        (res['id'] as String): Resource.fromJson(res),
    };

    final List<dynamic> buildingsData = jsonData['buildings'];
    final Map<String, Building> buildings = {
      for (var building in buildingsData)
        (building['id'] as String): Building.fromJson(building),
    };

    final gameState = GameState(
      resourceManager: ResourceManager(resources: resources),
      buildingManager: BuildingManager(),
      achievementManager: AchievementManager(),
      marketManager: MarketManager(
        resourceIds: resources.keys.toList(),
        volatility: 0.05,
      ),
      eventManager: EventManager(),
    );

    gameState.buildingManager.initializeBuildings(buildings);
    return gameState;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tradingTimer?.cancel();
    _saveTimer?.cancel();
    _achievementCheckTimer?.cancel();
    saveGame();
    super.dispose();
  }

  void trade() {
    marketManager.updatePrices({});
  }

  void _handleError(dynamic error) {
    // Log error and potentially show user feedback
    debugPrint('Game error: $error');
  }
}

class GameException implements Exception {
  final String message;
  GameException(this.message);
  @override
  String toString() => message;
}

class GameEvent {
  final String id;
  final String name;
  final String description;
  final EventType type;
  final double multiplier;
  final Duration duration;

  GameEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.multiplier,
    required this.duration,
  });
}

enum EventType {
  productionBoost,
  marketVolatility,
  resourceBonus,
  buildingDiscount,
}
