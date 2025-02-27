import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/resource.interface.dart';

class GameState extends ChangeNotifier {
  final Map<String, Resource> resources;
  final Map<String, Building> buildingConfigs;
  final List<Building> buildingInstances = [];

  Timer? _timer;

  GameState({required this.resources, required this.buildingConfigs}) {
    for (var res in resources.values) {
      res.amount = res.initialAmount;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
  }

  void clickResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.unlock) {
      resource.amount = resource.amount + resource.value;
      notifyListeners();
    }
  }

  void buyBuilding(String buildingId) {
    final config = buildingConfigs[buildingId];
    if (config == null) return;

    for (var entry in config.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      if (resources[resourceId]!.amount < cost) {
        return;
      }
    }

    for (var entry in config.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      resources[resourceId]!.amount -= cost;
    }

    final newBuilding = Building(
      id: config.id,
      name: config.name,
      cost: config.cost,
      production: config.production,
      durability: config.durability,
      type: config.type,
      infiniteDurability: config.infiniteDurability,
      amount: 1,
      currentDurability: config.durability,
    );

    buildingInstances.add(newBuilding);
    notifyListeners();
  }

  int calculatMaxBuy(String buildingId) {
    final building = buildingConfigs[buildingId];
    if (building == null) return 0;

    int maxPossible = 999999999;
    for (var entry in building.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final current = resources[resourceId]?.amount ?? 0;
      final possibleForThisResource = current ~/ cost;
      if (possibleForThisResource < maxPossible) {
        maxPossible = possibleForThisResource;
      }
    }

    return maxPossible;
  }

  void buyBuildingMax(String buildingId) {
    final building = buildingConfigs[buildingId];
    final maxPossible = calculatMaxBuy(buildingId);

    if (maxPossible <= 0 || building == null) return;

    for (var entry in building.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      resources[resourceId]!.amount -= (cost * maxPossible);
    }

    for (int i = 0; i < maxPossible; i++) {
      final newBuilding = Building(
        id: building.id,
        name: building.name,
        cost: building.cost,
        production: building.production,
        durability: building.durability,
        type: building.type,
        infiniteDurability: building.infiniteDurability,
        amount: 1,
        currentDurability: building.durability,
      );
      buildingInstances.add(newBuilding);
    }

    notifyListeners();
  }

  void tick() {
    const int degradationPerTick = 1;

    for (int i = buildingInstances.length - 1; i >= 0; i--) {
      final building = buildingInstances[i];

      building.production.forEach((resourceId, production) {
        resources[resourceId]?.amount += production;
      });

      if (!building.infiniteDurability) {
        building.currentDurability -= degradationPerTick;
        if (building.currentDurability <= 0) {
          buildingInstances.removeAt(i);
          continue;
        }
      }
    }

    notifyListeners();
  }

  void unlockResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource != null && !resource.unlock) {
      resources[resourceId] = Resource(
        id: resource.id,
        name: resource.name,
        initialAmount: resource.initialAmount,
        unlock: true,
        value: resource.value,
      );
      notifyListeners();
    }
  }

  int reateProduction(String resourceId) {
    int production = 0;
    for (var building in buildingInstances) {
      production += building.production[resourceId] ?? 0;
    }
    return production;
  }

  void sellResource(String resourceId, int quantity) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.amount < quantity) return;

    resource.amount -= quantity;
    final goldResource = resources['gold'];
    if (goldResource != null) {
      goldResource.amount += resource.value * quantity;
    }

    notifyListeners();
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
