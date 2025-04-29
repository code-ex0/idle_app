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
      final available =
          resourceManager.resources[resourceId]?.amount ?? BigInt.zero;
      final possible = available ~/ cost;
      if (possible < maxPossible) {
        maxPossible = possible;
      }
    }

    return maxPossible;
  }

  void buyBuildings(
    String buildingId,
    BigInt amount,
    ResourceManager resourceManager,
  ) {
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

  Map<String, dynamic> toJson() => {
    'buildings': buildings.map((key, value) => MapEntry(key, value.toJson())),
    'buildingGroups': buildingGroups.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
  };

  void fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("Chargement des bâtiments depuis la sauvegarde...");

      // Charger les bâtiments
      if (json.containsKey('buildings')) {
        final buildingsJson = json['buildings'] as Map<String, dynamic>;
        buildingsJson.forEach((key, value) {
          if (buildings.containsKey(key)) {
            debugPrint("Bâtiment trouvé: $key");
            if (value is Map<String, dynamic>) {
              buildings[key]!.amount = BigInt.parse(value['amount'].toString());
              if (value.containsKey('currentDurability')) {
                buildings[key]!.currentDurability = BigInt.parse(
                  value['currentDurability'].toString(),
                );
              }
            }
          } else {
            debugPrint("Bâtiment non trouvé dans l'initialisation: $key");
          }
        });
      } else {
        debugPrint("Pas de bâtiments trouvés dans la sauvegarde");
      }

      // Charger ou recréer les groupes de bâtiments
      // S'assurer que tous les bâtiments ont un groupe correspondant
      buildings.forEach((id, building) {
        if (!buildingGroups.containsKey(id)) {
          debugPrint("Création du groupe de bâtiments pour: $id");
          buildingGroups[id] = BuildingGroup(config: building);
        }
      });

      // Charger les groupes de bâtiments depuis la sauvegarde si disponibles
      if (json.containsKey('buildingGroups')) {
        final groupsJson = json['buildingGroups'] as Map<String, dynamic>;
        groupsJson.forEach((key, value) {
          if (buildings.containsKey(key) && value is Map<String, dynamic>) {
            debugPrint("Chargement du groupe de bâtiments: $key");
            // Recréer le groupe avec les données sauvegardées
            final config = buildings[key]!;
            final group = BuildingGroup(config: config);

            // Mettre à jour le nombre de bâtiments
            group.count = BigInt.parse(value['count'].toString());

            // Charger la liste des durabilités
            if (value.containsKey('listDurabilitys') &&
                value['listDurabilitys'] is List) {
              group.listDurabilitys =
                  (value['listDurabilitys'] as List)
                      .map((d) => BigInt.parse(d.toString()))
                      .toList();
            } else {
              // Si pas de liste, créer une liste basée sur le nombre de bâtiments
              group.listDurabilitys = List.generate(
                group.count.toInt(),
                (_) => config.durability,
              );
            }

            // Mettre à jour la durabilité actuelle
            if (value.containsKey('currentDurability')) {
              group.currentDurability = BigInt.parse(
                value['currentDurability'].toString(),
              );
            }

            // Remplacer le groupe existant
            buildingGroups[key] = group;
          }
        });
      } else {
        debugPrint(
          "Pas de groupes de bâtiments trouvés dans la sauvegarde, initialisation à partir des bâtiments",
        );
        // Initialiser les groupes de bâtiments à partir des bâtiments
        buildings.forEach((id, building) {
          final group = BuildingGroup(config: building);
          group.count = building.amount;
          group.listDurabilitys = List.generate(
            building.amount.toInt(),
            (_) => building.durability,
          );
          buildingGroups[id] = group;
        });
      }

      debugPrint(
        "Chargement des bâtiments terminé: ${buildings.length} bâtiments, ${buildingGroups.length} groupes",
      );
    } catch (e) {
      debugPrint("Erreur lors du chargement des bâtiments: $e");
    }
  }
}
