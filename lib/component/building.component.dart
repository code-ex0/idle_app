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

    String durabilityText = '';
    double durabilityProgress = 1.0;
    if (!group.config.infiniteDurability && group.count > BigInt.zero) {
      durabilityText =
          'Durabilité: ${group.lowestDurability} / ${group.config.durability}';
      durabilityProgress = group.lowestDurability / group.config.durability;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dans un carré fixe.
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.grey[300],
              child: Image.asset(
                'assets/icon/${group.config.id}.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.image, size: 40)),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne avec icône, nom et quantité.
                  Row(
                    children: [
                      const Icon(Icons.home),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          group.config.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text('Quantité: $quantity'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Affichage du coût.
                  Text('Prix: $costText'),
                  const SizedBox(height: 4),
                  // Affichage de la durabilité si applicable.
                  if (!group.config.infiniteDurability &&
                      group.count > BigInt.zero)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          durabilityText,
                          style: const TextStyle(fontSize: 12),
                        ),
                        LinearProgressIndicator(value: durabilityProgress),
                      ],
                    ),
                  const SizedBox(height: 4),
                  // Ligne avec le message "Manque" et les boutons d'achat.
                  Row(
                    children: [
                      Expanded(
                        child:
                            (!affordable && missingText.isNotEmpty)
                                ? Text(
                                  'Manque: $missingText',
                                  style: const TextStyle(color: Colors.red),
                                )
                                : const SizedBox(),
                      ),
                      TextButton(
                        onPressed:
                            affordable
                                ? () => context.read<GameState>().buyBuilding(
                                  group.config.id,
                                )
                                : null,
                        child: const Text('Construire'),
                      ),
                      TextButton(
                        onPressed:
                            affordable
                                ? () => context
                                    .read<GameState>()
                                    .buyBuildingMax(group.config.id)
                                : null,
                        child: Text('Acheter Max ($maxBuy)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
