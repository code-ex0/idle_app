import 'package:flutter/material.dart';
import 'package:test_1/component/building.component.dart';
import 'package:test_1/interfaces/building.enum.dart';
import 'package:test_1/interfaces/building.interface.dart';

class BuildingListComponent extends StatelessWidget {
  const BuildingListComponent({
    super.key,
    required this.buildings,
    required this.type,
    required this.buildingInstances,
  });
  final Map<String, Building> buildings;
  final List<Building> buildingInstances;
  final BuildingType type;
  List<Building> get filteredBuildingsInstances {
    return buildingInstances.where((b) => b.type == type).toList();
  }

  List<Building> get filteredBuildings {
    return buildings.values.where((b) => b.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: filteredBuildings.length,
      itemBuilder: (context, index) {
        return BuildingComponent(
          key: ValueKey(filteredBuildings[index].id),
          building: filteredBuildings[index],
          // buildInstance filter all by id of building return a list of building
          buildingInstance:
              filteredBuildingsInstances
                  .where((b) => b.id == filteredBuildings[index].id)
                  .toList(),
        );
      },
    );
  }
}
