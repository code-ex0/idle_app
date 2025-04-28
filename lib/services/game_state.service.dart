// lib/game_state.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
    _tradingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      trade();
    });
    _saveTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      saveGame();
    });
    _achievementCheckTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) {
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
      gameState: this,
    );
  }

  void clickResource(String resourceId, {int amount = 1}) {
    final resource = resourceManager.resources[resourceId];
    if (resource != null) {
      resource.amount += BigInt.from(amount);
      notifyListeners();
    }
  }

  void sellResource(
    String resourceId,
    BigInt quantity, [
    double? specificPrice,
  ]) {
    final resource = resourceManager.resources[resourceId];
    if (resource == null || resource.amount < quantity) return;

    final currency = resourceManager.resources['dollar'];
    if (currency == null) return;

    final price = specificPrice ?? marketManager.prices[resourceId] ?? 1.0;
    final revenue = (price * quantity.toDouble()).toInt();
    resource.amount -= quantity;
    currency.amount += BigInt.from(revenue);

    _updateStatistics('market', resourceId, quantity);
    _checkGameWin();
    notifyListeners();
  }

  void buyResource(
    String resourceId,
    BigInt quantity, [
    double? specificPrice,
  ]) {
    final resource = resourceManager.resources[resourceId];
    final currency = resourceManager.resources['dollar'];
    if (resource == null || currency == null) return;

    final price = specificPrice ?? marketManager.prices[resourceId] ?? 1.0;
    final totalCost = (price * quantity.toDouble()).toInt();
    if (currency.amount < BigInt.from(totalCost)) return;

    currency.amount -= BigInt.from(totalCost);
    resource.amount += quantity;

    _updateStatistics('market', resourceId, quantity);
    notifyListeners();
  }

  void _updateStatistics(String category, String resourceId, BigInt amount) {
    final categoryStats = statistics[category];
    if (categoryStats == null) return;

    categoryStats[resourceId] =
        (categoryStats[resourceId] ?? BigInt.zero) + amount;
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
          resource.value = BigInt.from(
            (resource.value.toDouble() * event.multiplier).round(),
          );
        });
        break;
      case EventType.marketVolatility:
        marketManager.setVolatility(event.multiplier);
        break;
      case EventType.resourceBonus:
        // Apply resource bonus multiplier to all resources
        resourceManager.resources.forEach((id, resource) {
          resource.value = BigInt.from(
            (resource.value.toDouble() * event.multiplier).round(),
          );
        });
        break;
      case EventType.buildingDiscount:
        // Apply building cost discount
        final discountMultiplier = BigInt.from(event.multiplier.round());
        buildingManager.buildings.forEach((id, building) {
          building.cost = building.cost.map(
            (key, value) => MapEntry(key, value ~/ discountMultiplier),
          );
        });
        break;
    }
  }

  Future<void> saveGame() async {
    try {
      final saveData = {
        'resources': resourceManager.resources.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'buildings': buildingManager.buildings.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
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
      saveData.forEach((key, value) {
        debugPrint('$key: $value');
      });

      // Implement actual save logic - TODO in production code
      // Don't create unused variables
      // final jsonString = jsonEncode(saveData);
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> loadGame() async {
    try {
      // Implement actual load logic
      final json = {}; // Load from storage
      if (json.isEmpty) {
        throw Exception('Aucune donnée de sauvegarde trouvée');
      }

      // Vérifier que toutes les sections requises existent
      if (!json.containsKey('resources') ||
          !json.containsKey('buildings') ||
          !json.containsKey('statistics') ||
          !json.containsKey('achievements')) {
        throw Exception('Les données de sauvegarde sont incomplètes');
      }

      // Load resources
      final resourcesJson = json['resources'] as Map<String, dynamic>;
      resourcesJson.forEach((key, value) {
        final resource = resourceManager.resources[key];
        if (resource != null) {
          resource.amount = BigInt.parse(value['amount'] as String);
          resource.isUnlocked = value['isUnlocked'] as bool;
        } else {
          throw Exception(
            'Ressource inconnue dans les données de sauvegarde: $key',
          );
        }
      });

      // Load buildings
      final buildingsJson = json['buildings'] as Map<String, dynamic>;
      buildingsJson.forEach((key, value) {
        final building = buildingManager.buildings[key];
        if (building != null) {
          building.amount = BigInt.parse(value['amount'] as String);
          building.currentDurability = BigInt.parse(
            value['currentDurability'] as String,
          );
        } else {
          throw Exception(
            'Bâtiment inconnu dans les données de sauvegarde: $key',
          );
        }
      });

      // Load statistics
      final stats = json['statistics'] as Map<String, dynamic>;
      stats.forEach((category, values) {
        if (!statistics.containsKey(category)) {
          throw Exception('Catégorie de statistique inconnue: $category');
        }
        statistics[category] = (values as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, BigInt.parse(value as String)),
        );
      });

      // Load achievements
      try {
        achievementManager.fromJson(
          json['achievements'] as Map<String, dynamic>,
        );
      } catch (e) {
        throw Exception('Erreur lors du chargement des succès: $e');
      }

      isGameWon = json['isGameWon'] as bool? ?? false;

      notifyListeners();
    } catch (e) {
      _handleError(e);
      throw Exception('Erreur lors du chargement de la sauvegarde: $e');
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
      final maxPossible = buildingManager.calculateMaxBuy(
        buildingId,
        resourceManager,
      );
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
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/game_data.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      // Vérifier que toutes les sections requises existent
      if (!jsonData.containsKey('resources') ||
          !jsonData.containsKey('buildings')) {
        throw Exception(
          'Le fichier game_data.json est incomplet. Les sections resources et buildings sont requises.',
        );
      }

      final List<dynamic> resourcesData = jsonData['resources'];
      if (resourcesData.isEmpty) {
        throw Exception('Aucune ressource trouvée dans game_data.json');
      }

      final Map<String, Resource> resources = {
        for (var res in resourcesData)
          (res['id'] as String): Resource.fromJson(res),
      };

      final List<dynamic> buildingsData = jsonData['buildings'];
      if (buildingsData.isEmpty) {
        throw Exception('Aucun bâtiment trouvé dans game_data.json');
      }

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

      await gameState.achievementManager.initialize();
      gameState.buildingManager.initializeBuildings(buildings);
      return gameState;
    } catch (e) {
      debugPrint('Erreur lors du chargement des données du jeu: $e');
      throw Exception('Erreur lors du chargement des données du jeu: $e');
    }
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
    _executeReadyLimitOrders();
  }

  /// Exécute les ordres limites qui sont prêts
  void _executeReadyLimitOrders() {
    bool anyOrderExecuted = false;
    final executedOrderIds = <String, List<String>>{};

    // Pour chaque ressource, vérifier s'il y a des ordres prêts à exécuter
    for (final resourceId in marketManager.prices.keys) {
      final readyOrders = marketManager.getReadyLimitOrders(resourceId);
      if (readyOrders.isEmpty) continue;
      executedOrderIds[resourceId] = [];

      for (final order in readyOrders) {
        if (order.executionPrice == null) {
          continue;
        }

        if (order.type == OrderType.buy) {
          // Pour un ordre d'achat, vérifier si le joueur a assez d'argent
          final currency = resourceManager.resources['dollar'];
          if (currency == null) {
            continue;
          }

          final totalCost =
              (order.executionPrice! * order.quantity.toDouble()).toInt();
          if (currency.amount >= BigInt.from(totalCost)) {
            // Exécuter l'ordre d'achat
            final resource = resourceManager.resources[resourceId];
            if (resource == null) {
              continue;
            }

            // Déduire le coût
            currency.amount -= BigInt.from(totalCost);

            // Ajouter les ressources
            resource.amount += order.quantity;

            // Enregistrer la transaction
            marketManager.addTransaction(
              resourceId,
              MarketTransaction(
                timestamp: DateTime.now(),
                quantity: order.quantity,
                price: order.executionPrice!,
                isBuy: true,
              ),
            );

            // Marquer l'ordre comme exécuté
            order.markAsExecuted(order.executionPrice!);
            anyOrderExecuted = true;

            // Ajouter à l'historique des ordres exécutés
            marketManager.addExecutedLimitOrder(resourceId, order);

            // Ajouter l'ID à la liste des ordres exécutés
            executedOrderIds[resourceId]!.add(order.id);

            // Mettre à jour les statistiques
            _updateStatistics('market', resourceId, order.quantity);

            // Incrémenter le compteur d'ordres exécutés
            statistics['market']?['executed_orders'] =
                (statistics['market']?['executed_orders'] ?? BigInt.zero) +
                BigInt.one;
          }
        } else if (order.type == OrderType.sell) {
          // Pour un ordre de vente, vérifier si le joueur a assez de ressources
          final resource = resourceManager.resources[resourceId];
          if (resource == null || resource.amount < order.quantity) {
            continue;
          }

          // Déduire les ressources
          resource.amount -= order.quantity;

          // Ajouter les gains
          final currency = resourceManager.resources['dollar'];
          if (currency == null) {
            continue;
          }

          final revenue =
              (order.executionPrice! * order.quantity.toDouble()).toInt();
          currency.amount += BigInt.from(revenue);

          // Enregistrer la transaction
          marketManager.addTransaction(
            resourceId,
            MarketTransaction(
              timestamp: DateTime.now(),
              quantity: order.quantity,
              price: order.executionPrice!,
              isBuy: false,
            ),
          );

          // Marquer l'ordre comme exécuté
          order.markAsExecuted(order.executionPrice!);
          anyOrderExecuted = true;

          // Ajouter à l'historique des ordres exécutés
          marketManager.addExecutedLimitOrder(resourceId, order);

          // Ajouter l'ID à la liste des ordres exécutés
          executedOrderIds[resourceId]!.add(order.id);

          // Mettre à jour les statistiques
          _updateStatistics('market', resourceId, order.quantity);

          // Incrémenter le compteur d'ordres exécutés
          statistics['market']?['executed_orders'] =
              (statistics['market']?['executed_orders'] ?? BigInt.zero) +
              BigInt.one;

          _checkGameWin();
        }
      }
    }

    // Supprimer les ordres exécutés de la liste principale
    for (final resourceId in executedOrderIds.keys) {
      if (executedOrderIds[resourceId]!.isNotEmpty) {
        marketManager.removeExecutedOrders(
          resourceId,
          executedOrderIds[resourceId]!,
        );
      }
    }

    // Notifier les écouteurs seulement si au moins un ordre a été exécuté
    if (anyOrderExecuted) {
      notifyListeners();
    }
  }

  /// Crée un ordre limite d'achat
  bool createBuyLimitOrder(
    String resourceId,
    BigInt quantity,
    double targetPrice,
  ) {
    if (quantity <= BigInt.zero) return false;

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final order = LimitOrder(
      id: orderId,
      type: OrderType.buy,
      resourceId: resourceId,
      quantity: quantity,
      targetPrice: targetPrice,
      createdAt: DateTime.now(),
    );

    marketManager.addLimitOrder(resourceId, order);
    return true;
  }

  /// Crée un ordre limite de vente
  bool createSellLimitOrder(
    String resourceId,
    BigInt quantity,
    double targetPrice,
  ) {
    if (quantity <= BigInt.zero) return false;

    // Vérifier si le joueur a assez de ressources
    final resource = resourceManager.resources[resourceId];
    if (resource == null || resource.amount < quantity) return false;

    final orderId = DateTime.now().millisecondsSinceEpoch.toString();
    final order = LimitOrder(
      id: orderId,
      type: OrderType.sell,
      resourceId: resourceId,
      quantity: quantity,
      targetPrice: targetPrice,
      createdAt: DateTime.now(),
    );

    marketManager.addLimitOrder(resourceId, order);
    return true;
  }

  /// Annule un ordre limite
  bool cancelLimitOrder(String resourceId, String orderId) {
    return marketManager.cancelLimitOrder(resourceId, orderId);
  }

  /// Récupère tous les ordres limites pour une ressource
  List<LimitOrder> getLimitOrders(String resourceId) {
    return marketManager.getLimitOrders(resourceId);
  }

  void _handleError(dynamic error) {
    // Enregistrer l'erreur et potentiellement afficher un retour à l'utilisateur
    debugPrint('Erreur dans le jeu: $error');
    // Ne pas masquer l'erreur, la laisser se propager
    throw Exception('Erreur dans le jeu: $error');
  }

  // Génère un faux historique de prix pour les ressources
  List<double> generateFakePriceHistory(String resourceId, {int count = 50}) {
    // Utiliser la valeur actuelle de la ressource comme point de départ
    final resource = resourceManager.resources[resourceId];
    if (resource == null) return List.generate(count, (_) => 1.0);

    final baseValue = resource.value.toDouble();
    final result = <double>[];

    // Paramètres de volatilité pour rendre l'historique réaliste
    final volatility = 0.05; // 5% de volatilité
    final trend =
        0.001 *
        (math.Random().nextDouble() * 2 -
            1); // tendance légère à la hausse ou à la baisse

    double currentValue =
        baseValue * 0.7; // commencer avec une valeur plus basse que l'actuelle

    for (int i = 0; i < count; i++) {
      // Ajouter un bruit aléatoire
      final change = (math.Random().nextDouble() * 2 - 1) * volatility;
      // Ajouter une tendance
      currentValue = currentValue * (1 + change + trend);
      // Limiter les variations extrêmes
      currentValue = math.max(
        baseValue * 0.5,
        math.min(baseValue * 1.5, currentValue),
      );
      result.add(currentValue);
    }

    return result;
  }

  /// Force l'exécution des ordres limites immédiatement, utile pour tester
  void forceExecuteLimitOrders() {
    trade();
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
