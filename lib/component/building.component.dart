import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/building.interface.dart';

class BuildingComponent extends StatelessWidget {
  const BuildingComponent({
    required Key key,
    required this.building,
    required this.buildingInstance,
  }) : super(key: key);

  final Building building;
  final List<Building> buildingInstance;

  String get costText {
    return building.cost.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  bool canAfford(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    for (var entry in building.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final current = gameState.resources[resourceId]?.amount ?? 0;
      if (current < cost) return false;
    }
    return true;
  }

  String missingResourcesText(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    List<String> missing = [];
    for (var entry in building.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final current = gameState.resources[resourceId]?.amount ?? 0;
      if (current < cost) {
        missing.add('$resourceId: ${cost - current}');
      }
    }
    return missing.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final affordable = canAfford(context);
    final missingText = missingResourcesText(context);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              color: Colors.grey[300],
              child: Image.asset(
                'assets/icon/${building.id}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image, size: 40));
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Text('Quantité: ${buildingInstance.length}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Prix
                  Text('Prix: $costText'),

                  if (!building.infiniteDurability &&
                      buildingInstance.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            buildingInstance.map((instance) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Durabilité: ${instance.currentDurability.toInt()} / ${instance.durability}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    LinearProgressIndicator(
                                      value:
                                          instance.currentDurability /
                                          instance.durability,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            !affordable && missingText.isNotEmpty
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
                        child: Text(
                          'Acheter Max (${context.read<GameState>().calculatMaxBuy(building.id)})',
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
    );
  }
}
