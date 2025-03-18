import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/market/chart.component.dart';
import 'package:test_1/services/game_state.service.dart';

class MarketTradingPage extends StatefulWidget {
  final String resourceId;
  const MarketTradingPage({super.key, required this.resourceId});

  @override
  State<MarketTradingPage> createState() => _MarketTradingPageState();
}

class _MarketTradingPageState extends State<MarketTradingPage> {
  double _quantity = 1.0;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    // Récupérer le prix actuel pour la ressource via le MarketManager.
    final currentPrice =
        gameState.marketManager.prices[widget.resourceId] ?? 1.0;
    // Définir un maximum pour la quantité à trader.
    const double maxQuantity = 100.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Trading Market')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Affichage du graphique de trading
              MarketChart(resourceId: widget.resourceId),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Affichage du prix actuel
                      Text(
                        'Prix actuel: ${currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Slider pour choisir la quantité
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Quantité:'),
                          Text(_quantity.toInt().toString()),
                        ],
                      ),
                      Slider(
                        value: _quantity,
                        min: 1,
                        max: maxQuantity,
                        divisions: maxQuantity.toInt() - 1,
                        label: _quantity.toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _quantity = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Boutons pour exécuter une transaction sur le marché
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Simulation d'un achat sur le marché
                              gameState.buyResource(
                                widget.resourceId,
                                BigInt.from(_quantity),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Achat de ${_quantity.toInt()} unité(s) validé',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Buy Market'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Simulation d'une vente sur le marché
                              gameState.sellResource(
                                widget.resourceId,
                                BigInt.from(_quantity),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Vente de ${_quantity.toInt()} unité(s) validée',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Sell Market'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
