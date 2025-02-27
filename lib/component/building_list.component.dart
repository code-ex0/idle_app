import 'package:flutter/material.dart';
import 'package:test_1/component/building.component.dart';
import 'package:test_1/interfaces/building.enum.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/building_group.interface.dart';

class BuildingListComponent extends StatelessWidget {
  const BuildingListComponent({
    super.key,
    required this.buildings,
    required this.type,
  });
  final Map<String, Building> buildings;
  final BuildingType type;

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
        );
      },
    );
  }
}
