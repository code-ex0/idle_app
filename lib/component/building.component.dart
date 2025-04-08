import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/interfaces/building_group.interface.dart';
import 'package:test_1/services/game_state.service.dart';

class BuildingComponent extends StatelessWidget {
  const BuildingComponent({super.key, required this.group});
  final BuildingGroup group;

  String get costText =>
      group.config.cost.entries.map((e) => '${e.key}: ${e.value}').join(', ');

  bool _canAfford(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return group.config.cost.entries.every((entry) {
      final resource = gameState.resourceManager.resources[entry.key];
      return resource != null && resource.amount >= entry.value;
    });
  }

  String _missingResourcesText(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return group.config.cost.entries
        .where((entry) {
          final resource = gameState.resourceManager.resources[entry.key];
          return resource == null || resource.amount < entry.value;
        })
        .map((entry) {
          final resource = gameState.resourceManager.resources[entry.key];
          final diff =
              (resource == null) ? entry.value : entry.value - resource.amount;
          return '${entry.key}: ${diff.toString()}';
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final affordable = _canAfford(context);
    final missingText = _missingResourcesText(context);
    final maxBuy = GameState.formatResourceAmount(
      context.read<GameState>().buildingManager.calculateMaxBuy(
        group.config.id,
        context.read<GameState>().resourceManager,
      ),
    );
    final quantity = GameState.formatResourceAmount(group.count);
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = group.count > BigInt.zero;

    String durabilityText = '';
    double durabilityProgress = 1.0;
    if (!group.config.infiniteDurability && isActive) {
      durabilityText =
          '${group.lowestDurability} / ${group.config.durability}';
      durabilityProgress = group.lowestDurability / group.config.durability;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive ? colorScheme.primary.withAlpha(77) : Colors.transparent,
          width: isActive ? 1.5 : 0,
        ),
      ),
      child: Column(
        children: [
          // En-tête avec image et nom du bâtiment
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(77),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
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
                    borderRadius: BorderRadius.circular(8),
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
                    'assets/icon/${group.config.id}.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.house, size: 30, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.config.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Quantité: ',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            quantity,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isActive ? colorScheme.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Informations principales
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Production
                Row(
                  children: [
                    Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Production: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        group.config.production.entries.map((e) => '${e.key}: ${e.value}').join(', '),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Coût
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Coût: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        costText,
                        style: TextStyle(
                          color: affordable ? colorScheme.onSurface : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Durabilité si applicable
                if (!group.config.infiniteDurability && isActive) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.health_and_safety_outlined,
                        size: 18,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Durabilité: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        durabilityText,
                        style: TextStyle(
                          color: durabilityProgress > 0.5 ? Colors.green : 
                                 durabilityProgress > 0.2 ? Colors.orange : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: durabilityProgress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        durabilityProgress > 0.5 ? Colors.green : 
                        durabilityProgress > 0.2 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                ],
                
                // Message de ressources manquantes
                if (!affordable && missingText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Manque: $missingText',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Boutons d'action
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(51),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: affordable
                        ? () => context.read<GameState>().buyBuilding(group.config.id)
                        : null,
                    icon: const Icon(Icons.build),
                    label: const Text('Construire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: affordable
                        ? () => context
                            .read<GameState>()
                            .buyBuildingMax(group.config.id)
                        : null,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text('Max ($maxBuy)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
