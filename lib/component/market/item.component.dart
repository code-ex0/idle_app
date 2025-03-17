import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({super.key, required this.resource});

  final Resource resource;

  String get priceText => 'Prix de vente: ${resource.value}';

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final stockText = GameState.formatResourceAmount(resource.amount);
    final productionRate = GameState.formatResourceAmount(
      gameState.buildingManager.rateProduction(resource.id),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: Image.asset(
                'assets/icon/resources/${resource.id}.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image, size: 30)),
              ),
            ),
            title: Text(resource.name),
            subtitle: Text(priceText),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Stock: $stockText'),
                const SizedBox(height: 4),
                Text('Prod: $productionRate / s'),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: [
              TextButton(
                onPressed:
                    () => context.read<GameState>().sellResource(
                      resource.id,
                      BigInt.one,
                    ),
                child: const Text('Vendre'),
              ),
              TextButton(
                onPressed:
                    () => context.read<GameState>().sellResource(
                      resource.id,
                      BigInt.from(10),
                    ),
                child: const Text('Vendre 10'),
              ),
              TextButton(
                onPressed:
                    () => context.read<GameState>().sellResource(
                      resource.id,
                      resource.amount,
                    ),
                child: const Text('Vendre all'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
