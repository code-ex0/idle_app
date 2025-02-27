import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/building.interface.dart';

class BuildingComponent extends StatelessWidget {
  const BuildingComponent({required Key key, required this.building})
    : super(key: key);

  final Building building;

  String get costText {
    return building.cost.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }

  bool canAfford(BuildContext context) {
    final gameState = Provider.of<GameState>(context, listen: false);
    for (var entry in building.cost.entries) {
      final resourceId = entry.key;
      final cost = entry.value;
      final current = gameState.resources[resourceId]?.amount ?? BigInt.zero;
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
      final current = gameState.resources[resourceId]?.amount ?? BigInt.zero;
      if (current < cost) {
        missing.add('$resourceId: ${(cost - current).toString()}');
      }
    }
    return missing.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final affordable = canAfford(context);
    final missingText = missingResourcesText(context);
    final maxBuy = GameState.formatResourceAmount(
      context.read<GameState>().calculateMaxBuy(building.id),
    );
    final currentBuilding =
        context.read<GameState>().buildingGroups[building.id];
    final quantity = GameState.formatResourceAmount(currentBuilding!.count);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // Utilisation d'un Row pour disposer l'image à gauche et le contenu à droite.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image dans un carré de 80x80.
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
                  // Ligne avec l'icône, le nom et la quantité.
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
                  // Affichage du coût.
                  Text('Prix: $costText'),
                  // Affichage des barres de durabilité si le bâtiment n'a pas une durabilité infinie.
                  if (!building.infiniteDurability &&
                      currentBuilding.count > BigInt.zero)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Column(
                        children: [
                          Text(
                            'Durabilité: ${currentBuilding.lowestDurability} / ${building.durability}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          LinearProgressIndicator(
                            value:
                                currentBuilding.lowestDurability /
                                building.durability,
                          ),
                        ],
                      ),
                    ),
                  // Ligne avec le message "Manque" et les boutons alignés.
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
                        child: Text('Acheter Max (${maxBuy.toString()})'),
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
