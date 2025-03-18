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

class GameState extends ChangeNotifier {
  final ResourceManager resourceManager;
  final BuildingManager buildingManager;
  final MarketManager marketManager;

  Timer? _timer;
  Timer? _tradingTimer;

  // Objectif : atteindre un certain nombre de Dolard.
  final BigInt dolardTarget = BigInt.from(1000000);

  GameState({
    required Map<String, Resource> resources,
    required Map<String, Building> buildingConfigs,
  }) : resourceManager = ResourceManager(resources: resources),
       buildingManager = BuildingManager(buildingConfigs: buildingConfigs),
       marketManager = MarketManager(
         resourceIds: resources.keys.toList(),
         volatility: 0.05,
       ) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
    _tradingTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      trade();
    });
  }

  void clickResource(String resourceId) {
    resourceManager.clickResource(resourceId);
    notifyListeners();
  }

  void sellResource(String resourceId, BigInt quantity) {
    // Vérifier que la ressource existe et qu'on a suffisamment de stock.
    final resource = resourceManager.resources[resourceId];
    if (resource == null || resource.amount < quantity) return;

    // Déduire la quantité vendue.
    resource.amount -= quantity;

    // Récupérer le prix courant du marché pour cette ressource.
    final marketPrice = marketManager.prices[resourceId] ?? 1.0;

    // Calculer le revenu de la vente.
    // Ici, on peut utiliser la valeur de base de la ressource (resource.value) ou le prix du marché.
    // Par exemple, revenu = quantity * resource.value * marketPrice.
    // Vous pouvez ajuster cette formule selon votre modèle économique.
    final double revenue = marketPrice * resource.value * quantity.toDouble();

    // Créditer la monnaie (ici, on suppose que la ressource monétaire s'appelle 'dollar').
    final currency = resourceManager.resources['dollar'];
    if (currency != null) {
      // On peut convertir le revenu en BigInt (en supposant que le revenu est arrondi)
      currency.amount += BigInt.from(revenue);
    }

    // Mettre à jour la pression de vente sur le marché.
    // On considère que la quantité vendue influence la pression (volume en double).
    marketManager.sellMarket(resourceId, quantity.toInt());

    // Notifier les auditeurs pour mettre à jour l'UI.
    notifyListeners();
  }

  void buyResource(String resourceId, BigInt quantity) {
    // Vérifier que la ressource existe et qu'on a suffisamment de monnaie.
    final resource = resourceManager.resources[resourceId];
    final currency = resourceManager.resources['dollar'];
    if (resource == null || currency == null) return;

    // Calculer le coût total de l'achat.
    final marketPrice = marketManager.prices[resourceId] ?? 1.0;
    final totalCost = marketPrice * quantity.toDouble();

    // Vérifier que l'acheteur a suffisamment de monnaie.
    if (currency.amount < BigInt.from(totalCost)) return;

    // Déduire le coût de l'achat.
    currency.amount -= BigInt.from(totalCost);

    // Ajouter la quantité achetée.
    resource.amount += quantity;

    // Mettre à jour la pression d'achat sur le marché.
    // On considère que la quantité achetée influence la pression (volume en double).
    marketManager.buyMarket(resourceId, quantity.toInt());

    // Notifier les auditeurs pour mettre à jour l'UI.
    notifyListeners();
  }

  void unlockResource(String resourceId) {
    resourceManager.unlockResource(resourceId);
    notifyListeners();
  }

  void buyBuilding(String buildingId) {
    buildingManager.buyBuilding(buildingId, resourceManager);
    notifyListeners();
  }

  void buyBuildingMax(String buildingId) {
    buildingManager.buyBuildingMax(buildingId, resourceManager);
    notifyListeners();
  }

  void tick() {
    buildingManager.tick(resourceManager);
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
    final Map<String, Building> buildingConfigs = {
      for (var building in buildingsData)
        (building['id'] as String): Building.fromJson(building),
    };

    return GameState(resources: resources, buildingConfigs: buildingConfigs);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tradingTimer?.cancel();
    super.dispose();
  }

  void trade() {
    marketManager.updatePrices();
  }
}
