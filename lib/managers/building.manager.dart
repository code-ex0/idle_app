// lib/managers/building_manager.dart
import 'package:test_1/interfaces/building_group.interface.dart';
import 'package:test_1/interfaces/building.interface.dart';
// Remove unused import
// import 'package:test_1/interfaces/building.enum.dart';
import 'package:test_1/managers/resource.manager.dart';
import 'package:flutter/material.dart';

class BuildingManager {
  final Map<String, Building> buildings = {};
  final Map<String, BuildingGroup> buildingGroups = {};

  BuildingManager() {
    // Le constructeur ne crée plus de données par défaut
    // Les données doivent être chargées via initializeBuildings
  }

  void addBuilding(String buildingId) {
    buildings[buildingId]?.amount += BigInt.one;
    buildingGroups[buildingId]?.addUnit();
  }

  BigInt calculateMaxBuy(String buildingId, ResourceManager resourceManager) {
    final config = buildings[buildingId];
    if (config == null) return BigInt.zero;

    BigInt maxPossible = BigInt.from(1) << 32; // Un nombre très grand
    for (var entry in config.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final available = resourceManager.resources[resourceId]?.amount ?? BigInt.zero;
      final possible = available ~/ cost;
      if (possible < maxPossible) {
        maxPossible = possible;
      }
    }

    return maxPossible;
  }

  void buyBuildings(String buildingId, BigInt amount, ResourceManager resourceManager) {
    final maxPossible = calculateMaxBuy(buildingId, resourceManager);
    if (maxPossible <= BigInt.zero) return;

    final actualAmount = amount > maxPossible ? maxPossible : amount;
    final config = buildings[buildingId]!;

    // Déduire les coûts
    for (var entry in config.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      resourceManager.resources[resourceId]?.amount -= cost * actualAmount;
    }

    // Ajouter les bâtiments
    buildings[buildingId]?.amount += actualAmount;
    buildingGroups[buildingId]?.addUnits(actualAmount);
  }

  void updateBuildings(ResourceManager resourceManager) {
    BigInt degradationPerTick = BigInt.one;

    for (var group in buildingGroups.values) {
      group.degrade(degradationPerTick);

      for (var entry in group.config.production.entries) {
        final resourceId = entry.key;
        final totalProduction = group.totalProduction(resourceId);
        resourceManager.resources[resourceId]?.amount += totalProduction;
      }
    }
  }

  BigInt rateProduction(String resourceId) {
    BigInt production = BigInt.zero;
    for (var group in buildingGroups.values) {
      production += group.totalProduction(resourceId);
    }
    return production;
  }

  void initializeBuildings(Map<String, Building> buildings) {
    if (buildings.isEmpty) {
      throw Exception('La liste de bâtiments ne peut pas être vide');
    }
    
    this.buildings.clear();
    this.buildings.addAll(buildings);
    
    // Réinitialiser les groupes de bâtiments
    buildingGroups.clear();
    for (var building in buildings.values) {
      buildingGroups[building.id] = BuildingGroup(config: building);
    }
    
    debugPrint('${buildings.length} bâtiments initialisés');
  }
}
