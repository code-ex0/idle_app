import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';

class UnlockingPage extends StatelessWidget {
  const UnlockingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Déblocage')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          // Récupérer la liste des ressources verrouillées
          final locked = gameState.resourceManager.lockedResources;
          if (locked.isEmpty) {
            return const Center(child: Text('Aucune ressource à débloquer'));
          }
          return ListView.builder(
            itemCount: locked.length,
            itemBuilder: (context, index) {
              final res = locked[index];
              return _LockedResourceTile(resource: res);
            },
          );
        },
      ),
    );
  }
}

class _LockedResourceTile extends StatelessWidget {
  const _LockedResourceTile({required this.resource});

  final Resource resource;

  @override
  Widget build(BuildContext context) {
    final gameState = context.read<GameState>();
    // Afficher le coût de déblocage (res.unlockCost)
    final costText =
        resource.unlockCost != null
            ? resource.unlockCost!.entries
                .map(
                  (e) => '${e.key}: ${GameState.formatResourceAmount(e.value)}',
                )
                .join(', ')
            : 'N/A';

    // Vérifier si on peut payer le coût
    final canUnlock =
        resource.unlockCost?.entries.every((entry) {
          final resAmount =
              gameState.resourceManager.resources[entry.key]?.amount ??
              BigInt.zero;
          return resAmount >= entry.value;
        }) ??
        false;

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(resource.name),
        subtitle: Text('Coût: $costText'),
        trailing: TextButton(
          onPressed:
              canUnlock
                  ? () => gameState.resourceManager.attemptUnlockResource(
                    resource.id,
                  )
                  : null,
          child: const Text('Débloquer'),
        ),
      ),
    );
  }
}
