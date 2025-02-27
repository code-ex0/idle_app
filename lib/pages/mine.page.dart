import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/building_list.component.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/building.enum.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mine')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return BuildingListComponent(
            buildings: gameState.buildingConfigs,
            type: BuildingType.quarry,
          );
        },
      ),
    );
  }
}
