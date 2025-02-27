import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/building_list.component.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/building.enum.dart';

class ArtisanatPage extends StatelessWidget {
  const ArtisanatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisanat')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return BuildingListComponent(
            buildings: gameState.buildingConfigs,
            buildingInstances: gameState.buildingInstances,
            type: BuildingType.workshop,
          );
        },
      ),
    );
  }
}
