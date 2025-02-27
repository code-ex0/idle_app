import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/building.interface.dart';

class BuildingComponent extends StatelessWidget {
  const BuildingComponent({required Key key, required this.building})
    : super(key: key);

  final Building building;

  String get costText =>
      building.cost.entries.map((e) => '${e.key}: ${e.value}').join(', ');

  bool _canAfford(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return building.cost.entries.every((entry) {
      final resource = gameState.resources[entry.key];
      return resource != null && resource.amount >= entry.value;
    });
  }

  String _missingResourcesText(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    return building.cost.entries
        .where((entry) {
          final resource = gameState.resources[entry.key];
          return resource == null || resource.amount < entry.value;
        })
        .map((entry) {
          final resource = gameState.resources[entry.key];
          final diff =
              (resource == null) ? entry.value : entry.value - resource.amount;
          return '${entry.key}: ${diff.toString()}';
        })
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final affordable = _canAfford(context);
    final missingText = _missingResourcesText(context);
    final maxBuy = GameState.formatResourceAmount(
      gameState.calculateMaxBuy(building.id),
    );
    final group = gameState.buildingGroups[building.id];
    final quantity =
        group != null ? GameState.formatResourceAmount(group.count) : '0';

    String durabilityText = '';
    double durabilityProgress = 1.0;
    if (!building.infiniteDurability &&
        group != null &&
        group.count > BigInt.zero) {
      durabilityText =
          'Durabilité: ${group.lowestDurability} / ${building.durability}';
      durabilityProgress = group.lowestDurability / building.durability;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dans un carré fixe
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.grey[300],
              child: Image.asset(
                'assets/icon/${building.id}.png',
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
                  // Ligne avec icône, nom et quantité
                  Row(
                    children: [
                      const Icon(Icons.home),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          building.name,
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
                  // Affichage du coût
                  Text('Prix: $costText'),
                  const SizedBox(height: 4),
                  // Affichage de la durabilité si applicable
                  if (!building.infiniteDurability &&
                      group != null &&
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
                  // Ligne avec message "Manque" et boutons alignés
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
                                  building.id,
                                )
                                : null,
                        child: const Text('Construire'),
                      ),
                      TextButton(
                        onPressed:
                            affordable
                                ? () => context
                                    .read<GameState>()
                                    .buyBuildingMax(building.id)
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
