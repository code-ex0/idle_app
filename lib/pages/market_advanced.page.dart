import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/market/chart.component.dart';
import 'package:test_1/component/market/trading_sliders.dart';
import 'package:test_1/services/game_state.service.dart';

class MarketTradingPage extends StatefulWidget {
  final String resourceId;
  const MarketTradingPage({super.key, required this.resourceId});

  @override
  State<MarketTradingPage> createState() => _MarketTradingPageState();
}

class _MarketTradingPageState extends State<MarketTradingPage> {
  double _buyPercent = 1;
  double _sellPercent = 1;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    // Supposons que le stock disponible définit le maximum possible à trader
    final resource = gameState.resourceManager.resources[widget.resourceId];
    final maxQuantity = resource != null ? resource.amount.toDouble() : 1.0;
    final maxDolard =
        gameState.resourceManager.resources['dollar']?.amount.toDouble();

    // La quantité réelle à trader est le pourcentage appliqué au maximum.
    final actualBuy = (_buyPercent / 100) * maxDolard!;
    final actualSell = (_sellPercent / 100) * maxQuantity;

    return Scaffold(
      appBar: AppBar(title: Text("Trading Market - ${widget.resourceId}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Graphique des prix
            MarketChart(resourceId: widget.resourceId),
            const SizedBox(height: 20),
            // Sliders d'achat et de vente
            TradingPercentageSliders(
              maxBuy: maxDolard,
              maxSell: maxQuantity,
              onChanged: (buy, sell) {
                setState(() {
                  _buyPercent = buy;
                  _sellPercent = sell;
                });
              },
            ),
            const SizedBox(height: 20),
            Text("Quantité à acheter: ${actualBuy.toInt()}"),
            Text("Quantité à vendre: ${actualSell.toInt()}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    gameState.buyResource(
                      widget.resourceId,
                      BigInt.from(actualBuy.toInt()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Achat de ${actualBuy.toInt()} unité(s) validé",
                        ),
                      ),
                    );
                  },
                  child: const Text("Buy Market"),
                ),
                ElevatedButton(
                  onPressed: () {
                    gameState.sellResource(
                      widget.resourceId,
                      BigInt.from(actualSell.toInt()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Vente de ${actualSell.toInt()} unité(s) validée",
                        ),
                      ),
                    );
                  },
                  child: const Text("Sell Market"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
