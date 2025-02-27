import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/market/item.component.dart';
import 'package:test_1/game_state.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marché')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Convertir la map en liste
          final resourcesList = gameState.getResourcesList;
          return ListView.builder(
            itemCount: resourcesList.length,
            itemBuilder: (context, index) {
              final resource = resourcesList[index];
              return MarketItem(key: ValueKey(resource.id), resource: resource);
            },
          );
        },
      ),
    );
  }
}
