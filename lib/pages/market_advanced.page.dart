import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/component/market/chart.component.dart';
import 'package:test_1/component/market/transaction_history.dart';
import 'package:test_1/component/market/limit_orders.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/managers/market.manager.dart';

class MarketTradingPage extends StatefulWidget {
  final String resourceId;
  const MarketTradingPage({super.key, required this.resourceId});

  @override
  State<MarketTradingPage> createState() => _MarketTradingPageState();
}

class _MarketTradingPageState extends State<MarketTradingPage> with SingleTickerProviderStateMixin {
  double _tradePercent = 50;
  bool _isBuyMode = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;
    
    // Récupération des données de ressource
    final resource = gameState.resourceManager.resources[widget.resourceId];
    final maxQuantity = resource != null ? resource.amount.toDouble() : 1.0;
    final maxDolard = gameState.resourceManager.resources['dollar']?.amount.toDouble() ?? 0;
    
    // Prix actuel
    final currentPrice = gameState.marketManager.prices[widget.resourceId] ?? 1.0;
    
    // Calculs basés sur le pourcentage choisi
    final actualBuy = _isBuyMode ? (_tradePercent / 100) * maxDolard : 0;
    final actualSell = !_isBuyMode ? (_tradePercent / 100) * maxQuantity : 0;
    
    // Estimations
    final estimatedBuyAmount = (actualBuy / currentPrice).round();
    final estimatedSellProfit = (actualSell * currentPrice).round();
    
    final mainColor = _isBuyMode ? Colors.green : Colors.red;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.resourceId.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "\$${currentPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Entête des informations du marché
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMarketStatCard(
                  context, 
                  "24h", 
                  _getChangePercentage(widget.resourceId, gameState), 
                  _checkPriceTrend(widget.resourceId, gameState) ? Icons.trending_up : Icons.trending_down,
                  _checkPriceTrend(widget.resourceId, gameState) ? Colors.green : Colors.red
                ),
                _buildMarketStatCard(
                  context, 
                  "High", 
                  "\$${_getHighPrice(widget.resourceId, gameState).toStringAsFixed(2)}", 
                  Icons.trending_up,
                  Colors.green
                ),
                _buildMarketStatCard(
                  context, 
                  "Low", 
                  "\$${_getLowPrice(widget.resourceId, gameState).toStringAsFixed(2)}", 
                  Icons.trending_down,
                  Colors.red
                ),
              ],
            ),
          ),
          
          // Graphique et historique avec TabBar
          Expanded(
            flex: 4,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: colorScheme.primary,
                  indicatorColor: colorScheme.primary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.bar_chart),
                      text: 'Graphique',
                    ),
                    Tab(
                      icon: Icon(Icons.receipt_long),
                      text: 'Historique',
                    ),
                    Tab(
                      icon: Icon(Icons.format_list_bulleted),
                      text: 'Ordres',
                    ),
                  ],
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.withAlpha(77),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          MarketChart(resourceId: widget.resourceId),
                          TransactionHistory(resourceId: widget.resourceId),
                          LimitOrdersList(resourceId: widget.resourceId),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Panneau de trading simplifié
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Switch Buy/Sell
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBuyMode = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isBuyMode 
                                  ? Colors.green.withAlpha(51) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "ACHETER",
                              style: TextStyle(
                                color: _isBuyMode ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBuyMode = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isBuyMode 
                                  ? Colors.red.withAlpha(51) 
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "VENDRE",
                              style: TextStyle(
                                color: !_isBuyMode ? Colors.red : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Slider avec pourcentage
                Row(
                  children: [
                    Text(_isBuyMode ? "Acheter:" : "Vendre:"),
                    Expanded(
                      child: Slider(
                        value: _tradePercent,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        activeColor: mainColor,
                        inactiveColor: mainColor.withAlpha(51),
                        onChanged: (value) {
                          setState(() {
                            _tradePercent = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withAlpha(77)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "${_tradePercent.toInt()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Résumé de la transaction
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mainColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isBuyMode
                      // Interface d'achat
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Coût: ${actualBuy.toInt()} \$",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Quantité obtenue: $estimatedBuyAmount",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: actualBuy > 0 ? () {
                                final buyAmount = estimatedBuyAmount;
                                if (gameState.marketManager.buy(
                                  widget.resourceId, 
                                  BigInt.from(buyAmount), 
                                  currentPrice)
                                ) {
                                  // Effectuer l'achat avec le prix du marché actuel
                                  gameState.buyResource(
                                    widget.resourceId,
                                    BigInt.from(buyAmount),
                                  );
                                  
                                  // Enregistrer la transaction
                                  gameState.marketManager.addTransaction(
                                    widget.resourceId,
                                    MarketTransaction(
                                      timestamp: DateTime.now(),
                                      quantity: BigInt.from(buyAmount),
                                      price: currentPrice,
                                      isBuy: true,
                                    ),
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Achat effectué: $buyAmount ${widget.resourceId} à \$${currentPrice.toStringAsFixed(2)}"),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text("ACHETER"),
                            ),
                          ],
                        )
                      // Interface de vente
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Vendre: ${actualSell.toInt()} ${widget.resourceId}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Gain: $estimatedSellProfit \$",
                                  style: TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: actualSell > 0 ? () {
                                final sellAmount = actualSell.toInt();
                                if (gameState.marketManager.sell(
                                  widget.resourceId, 
                                  BigInt.from(sellAmount), 
                                  currentPrice)
                                ) {
                                  // Effectuer la vente avec le prix du marché actuel
                                  gameState.sellResource(
                                    widget.resourceId,
                                    BigInt.from(sellAmount),
                                  );
                                  
                                  // Enregistrer la transaction
                                  gameState.marketManager.addTransaction(
                                    widget.resourceId,
                                    MarketTransaction(
                                      timestamp: DateTime.now(),
                                      quantity: BigInt.from(sellAmount),
                                      price: currentPrice,
                                      isBuy: false,
                                    ),
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Vente effectuée: $sellAmount ${widget.resourceId} à \$${currentPrice.toStringAsFixed(2)}"),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              } : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text("VENDRE"),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Vérifie si la tendance des prix est à la hausse
  bool _checkPriceTrend(String resourceId, GameState gameState) {
    final priceHistory = gameState.marketManager.getPriceHistory(resourceId);
    if (priceHistory.length < 2) return true;
    
    final first = priceHistory[priceHistory.length - 2];
    final last = priceHistory.last;
    return last >= first;
  }
  
  // Calcule le pourcentage de changement sur les dernières 24h (ou moins si l'historique est plus court)
  String _getChangePercentage(String resourceId, GameState gameState) {
    final priceHistory = gameState.marketManager.getPriceHistory(resourceId);
    if (priceHistory.length < 2) return "+0.00%";
    
    final startIndex = priceHistory.length >= 24 ? priceHistory.length - 24 : 0;
    final startPrice = priceHistory[startIndex];
    final endPrice = priceHistory.last;
    
    final changePercent = ((endPrice / startPrice) - 1) * 100;
    final sign = changePercent >= 0 ? "+" : "";
    return "$sign${changePercent.toStringAsFixed(2)}%";
  }
  
  // Récupère le prix le plus élevé des dernières 24h
  double _getHighPrice(String resourceId, GameState gameState) {
    final priceHistory = gameState.marketManager.getPriceHistory(resourceId);
    if (priceHistory.isEmpty) return gameState.marketManager.prices[resourceId] ?? 1.0;
    
    final startIndex = priceHistory.length >= 24 ? priceHistory.length - 24 : 0;
    return priceHistory.sublist(startIndex).reduce((max, price) => price > max ? price : max);
  }
  
  // Récupère le prix le plus bas des dernières 24h
  double _getLowPrice(String resourceId, GameState gameState) {
    final priceHistory = gameState.marketManager.getPriceHistory(resourceId);
    if (priceHistory.isEmpty) return gameState.marketManager.prices[resourceId] ?? 1.0;
    
    final startIndex = priceHistory.length >= 24 ? priceHistory.length - 24 : 0;
    return priceHistory.sublist(startIndex).reduce((min, price) => price < min ? price : min);
  }
  
  Widget _buildMarketStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
