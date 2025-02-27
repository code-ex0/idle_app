import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/resource.interface.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({super.key, required this.resource});

  final Resource resource;

  String get priceText {
    final sellPrice = (resource.value / 2).round();
    return 'Prix de vente: $sellPrice';
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final stockText = GameState.formatResourceAmount(resource.amount);
    final productionRate = GameState.formatResourceAmount(
      gameState.rateProduction(resource.id),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[300],
              ),
              child: Image.asset(
                'assets/icon/${resource.id}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image, size: 30));
                },
              ),
            ),
            title: Text(resource.name),
            subtitle: Text(priceText),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text('Stock: $stockText'),
                const SizedBox(height: 4),
                Text('Prod: ${productionRate.toString()} / s'),
              ],
            ),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  context.read<GameState>().sellResource(
                    resource.id,
                    BigInt.one,
                  );
                },
                child: const Text('Vendre'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
