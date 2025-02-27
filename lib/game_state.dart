import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/interfaces/building_group.interface.dart'; // Le fichier où se trouve la classe BuildingGroup

class GameState extends ChangeNotifier {
  final Map<String, Resource> resources;
  final Map<String, Building> buildingConfigs;
  final Map<String, BuildingGroup> buildingGroups = {};
  Timer? _timer;

  GameState({required this.resources, required this.buildingConfigs}) {
    // Initialiser les quantités des ressources.
    for (var res in resources.values) {
      res.amount = BigInt.from(res.initialAmount);
    }
    // Créer un groupe pour chaque configuration de bâtiment.
    for (var config in buildingConfigs.values) {
      buildingGroups[config.id] = BuildingGroup(config: config);
    }
    // Démarrer le tick du jeu toutes les secondes.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      tick();
    });
  }

  bool _canAfford(Map<String, BigInt> cost) {
    for (var entry in cost.entries) {
      final resourceId = entry.key;
      final required = entry.value;
      final resource = resources[resourceId];
      if (resource == null || resource.amount < required) {
        return false;
      }
    }
    return true;
  }

  void _deductCost(Map<String, BigInt> cost, BigInt multiplier) {
    for (var entry in cost.entries) {
      final resourceId = entry.key;
      final costPerUnit = entry.value;
      resources[resourceId]!.amount -= costPerUnit * multiplier;
    }
  }

  /// Simule un clic qui produit une ressource (si débloquée).
  void clickResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.unlock) {
      resource.amount += BigInt.from(resource.value);
      notifyListeners();
    }
  }

  /// Achète un bâtiment individuellement.
  void buyBuilding(String buildingId) {
    final config = buildingConfigs[buildingId];
    if (config == null) return;
    if (!_canAfford(config.cost)) return;
    _deductCost(config.cost, BigInt.one);
    // Ajoute une unité dans le BuildingGroup correspondant.
    buildingGroups[buildingId]?.addUnit();
    notifyListeners();
  }

  BigInt calculateMaxBuy(String buildingId) {
    final config = buildingConfigs[buildingId];
    if (config == null) return BigInt.zero;
    BigInt maxPossible = BigInt.from(1) << 32;
    for (var entry in config.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final current = resources[resourceId]?.amount ?? BigInt.zero;
      final possibleForThisResource = current ~/ cost;
      if (possibleForThisResource < maxPossible) {
        maxPossible = possibleForThisResource;
      }
    }
    return maxPossible;
  }

  /// Achète le maximum possible de bâtiments pour un type donné.
  void buyBuildingMax(String buildingId) {
    final config = buildingConfigs[buildingId];
    if (config == null) return;
    final maxPossible = calculateMaxBuy(buildingId);
    if (maxPossible <= BigInt.zero) return;

    _deductCost(config.cost, maxPossible);
    for (int i = 0; i < maxPossible.toInt(); i++) {
      buildingGroups[buildingId]?.addUnit();
    }
    notifyListeners();
  }

  /// Tick de jeu : production et dégradation.
  void tick() {
    const int degradationPerTick = 1;

    buildingGroups.forEach((id, group) {
      // Production : pour chaque ressource produite par la config, ajoute production * count.
      group.config.production.forEach((resourceId, production) {
        resources[resourceId]?.amount += production * group.count;
      });
      // Appliquer la dégradation si la durabilité n'est pas infinie.
      if (!group.config.infiniteDurability) {
        group.degrade(degradationPerTick);
      }
    });
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

  BigInt rateProduction(String resourceId) {
    BigInt production = BigInt.zero;
    buildingGroups.forEach((id, group) {
      production += group.totalProduction(resourceId);
    });
    return production;
  }

  void sellResource(String resourceId, BigInt quantity) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.amount < quantity) return;
    resource.amount -= quantity;
    final dollarResource = resources['dollar'];
    if (dollarResource != null) {
      dollarResource.amount += BigInt.from(resource.value) * quantity;
    }
    notifyListeners();
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

    final List<dynamic> buildingsData = jsonData['buildings'];
    final Map<String, Building> buildingConfigs = {
      for (var building in buildingsData)
        (building['id'] as String): Building.fromJson(building),
    };

    return GameState(resources: resources, buildingConfigs: buildingConfigs);
  }

  // get resources // filter remove dollar id
  List<Resource> get getResourcesList =>
      resources.values.where((res) => res.id != 'dollar').toList();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
