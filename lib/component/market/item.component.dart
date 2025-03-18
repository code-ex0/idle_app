import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/pages/market_advanced.page.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({super.key, required this.resource});

  final Resource resource;

  String get priceText {
    final sellPrice = resource.value;
    return 'Prix de vente: $sellPrice';
  }

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
        children: <Widget>[
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
              // Boutons de vente automatique
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
              // Bouton pour ouvrir le marché avancé
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              MarketTradingPage(resourceId: resource.id),
                    ),
                  );
                },
                child: const Text('Avancé'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
