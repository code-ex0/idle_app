// lib/managers/building_manager.dart
import 'package:test_1/interfaces/building_group.interface.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/managers/resource.manager.dart';

class BuildingManager {
  final Map<String, Building> buildingConfigs;
  final Map<String, BuildingGroup> buildingGroups = {};

  BuildingManager({required this.buildingConfigs}) {
    // Créer un BuildingGroup pour chaque configuration.
    for (var config in buildingConfigs.values) {
      buildingGroups[config.id] = BuildingGroup(config: config);
    }
  }

  /// Ajoute une unité au groupe de bâtiment correspondant.
  void buyBuilding(String buildingId, ResourceManager resourceManager) {
    final config = buildingConfigs[buildingId];
    if (config == null) return;
    config.cost.forEach((resourceId, cost) {
      if (resourceManager.resources[resourceId]!.amount < cost) return;
    });
    config.cost.forEach((resourceId, cost) {
      resourceManager.resources[resourceId]!.amount -= cost;
    });
    buildingGroups[buildingId]?.addUnit();
  }

  BigInt calculateMaxBuy(String buildingId, ResourceManager resourceManager) {
    final config = buildingConfigs[buildingId];
    if (config == null) return BigInt.zero;
    BigInt maxPossible = BigInt.from(1) << 32;
    config.cost.forEach((resourceId, cost) {
      final current =
          resourceManager.resources[resourceId]?.amount ?? BigInt.zero;
      final possibleForResource = current ~/ cost;
      if (possibleForResource < maxPossible) {
        maxPossible = possibleForResource;
      }
    });
    return maxPossible;
  }

  void buyBuildingMax(String buildingId, ResourceManager resourceManager) {
    final config = buildingConfigs[buildingId];
    if (config == null) return;
    final maxPossible = calculateMaxBuy(buildingId, resourceManager);
    if (maxPossible <= BigInt.zero) return;
    config.cost.forEach((resourceId, cost) {
      resourceManager.resources[resourceId]!.amount -= cost * maxPossible;
    });
    buildingGroups[buildingId]?.addUnits(maxPossible);
  }

  /// Applique la production et la dégradation pour chaque BuildingGroup.
  void tick(ResourceManager resourceManager) {
    const int degradationPerTick = 1;
    buildingGroups.forEach((id, group) {
      group.config.production.forEach((resourceId, production) {
        resourceManager.resources[resourceId]?.amount +=
            production * group.count;
      });
      if (!group.config.infiniteDurability) {
        group.degrade(degradationPerTick);
      }
    });
  }

  BigInt rateProduction(String resourceId) {
    BigInt production = BigInt.zero;
    buildingGroups.forEach((id, group) {
      production += group.totalProduction(resourceId);
    });
    return production;
  }
}
