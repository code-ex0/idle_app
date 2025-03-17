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
  }

  void clickResource(String resourceId) {
    resourceManager.clickResource(resourceId);
    notifyListeners();
  }

  void sellResource(String resourceId, BigInt quantity) {
    resourceManager.sellResource(resourceId, quantity);
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
    marketManager.updatePrices({});

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
    super.dispose();
  }
}
