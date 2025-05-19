import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/building/building.component.dart';
import 'package:test_1/interfaces/building.enum.dart';
import 'package:test_1/services/game_state.service.dart';

class BuildingListComponent extends StatelessWidget {
  const BuildingListComponent({super.key, required this.type});

  final BuildingType type;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    // Filtrer les BuildingGroup par type.
    final groups =
        gameState.buildingManager.buildingGroups.values
            .where((group) => group.config.type == type)
            .toList();
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return BuildingComponent(
          key: ValueKey(groups[index].config.id),
          group: groups[index],
        );
      },
    );
  }
}
