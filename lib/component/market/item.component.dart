import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/pages/market_advanced.page.dart';

class MarketItem extends StatelessWidget {
  const MarketItem({super.key, required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final stockText = GameState.formatResourceAmount(resource.amount);
    final productionRate = GameState.formatResourceAmount(
      gameState.buildingManager.rateProduction(resource.id),
    );
    final sellPrice = GameState.formatResourceAmount(resource.value);
    final colorScheme = Theme.of(context).colorScheme;

    final isProducing = gameState.buildingManager.rateProduction(resource.id) > BigInt.zero;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(
          color: isProducing ? colorScheme.primary.withAlpha(26) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icon/resources/${resource.id}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => 
                        Icon(Icons.image, size: 30, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'Valeur: ',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            TextSpan(
                              text: '$sellPrice \$',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Stock',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stockText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Production',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: isProducing ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$productionRate/s',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isProducing ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  context, 
                  'Vendre 1', 
                  Icons.sell, 
                  () => context.read<GameState>().sellResource(resource.id, BigInt.one),
                  resource.amount > BigInt.zero,
                  colorScheme.primary,
                ),
                _buildActionButton(
                  context, 
                  'Vendre 10', 
                  Icons.sell, 
                  () => context.read<GameState>().sellResource(resource.id, BigInt.from(10)),
                  resource.amount >= BigInt.from(10),
                  colorScheme.primary,
                ),
                _buildActionButton(
                  context, 
                  'Vendre tout', 
                  Icons.attach_money,
                  () => context.read<GameState>().sellResource(resource.id, resource.amount),
                  resource.amount > BigInt.zero,
                  colorScheme.secondary,
                ),
                _buildActionButton(
                  context, 
                  'Avancé', 
                  Icons.insights,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MarketTradingPage(resourceId: resource.id),
                      ),
                    );
                  },
                  true,
                  colorScheme.tertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton(
    BuildContext context, 
    String label, 
    IconData icon, 
    VoidCallback onPressed,
    bool isEnabled,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
                  size: 22,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? color : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
