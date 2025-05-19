import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/building/building_list.component.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/building.enum.dart';

class ArtisanatPage extends StatelessWidget {
  const ArtisanatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artisanat')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return BuildingListComponent(type: BuildingType.workshop);
        },
      ),
    );
  }
}
