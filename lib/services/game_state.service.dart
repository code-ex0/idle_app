// lib/game_state.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/managers/building.manager.dart';
import 'package:test_1/managers/resource.manager.dart';

class GameState extends ChangeNotifier {
  final ResourceManager resourceManager;
  final BuildingManager buildingManager;

  Timer? _timer;

  // Objectif : atteindre un certain nombre de Dolard.
  final BigInt dolardTarget = BigInt.from(1000000);

  GameState({
    required Map<String, Resource> resources,
    required Map<String, Building> buildingConfigs,
  }) : resourceManager = ResourceManager(resources: resources),
       buildingManager = BuildingManager(buildingConfigs: buildingConfigs) {
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
    final List<String> suffixes = ['A', 'B', 'C', 'D', 'E', 'F'];
    double value = amount.toDouble();
    int suffixIndex = 0;
    while (value >= 1000 && suffixIndex < suffixes.length) {
      value /= 1000;
      suffixIndex++;
    }
    return '${value.toStringAsFixed(2)} ${suffixes[suffixIndex - 1]}';
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

    // Assurer que la ressource "dollar" est présente.
    if (!resources.containsKey('dollar')) {
      resources['dollar'] = Resource(
        id: 'dollar',
        name: 'Dollars',
        initialAmount: 0,
        unlock: true,
        value: 0,
      );
    }

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
