// lib/managers/resource_manager.dart
import 'package:test_1/interfaces/resource.interface.dart';

class ResourceManager {
  final Map<String, Resource> resources;

  ResourceManager({required this.resources}) {
    // Initialiser chaque ressource à partir de son initialAmount.
    for (var res in resources.values) {
      res.amount = BigInt.from(res.initialAmount);
    }
  }

  void clickResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.unlock) {
      resource.amount += BigInt.from(resource.value);
    }
  }

  void sellResource(String resourceId, BigInt quantity) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.amount < quantity) return;
    resource.amount -= quantity;
    // On crédite la ressource "dollar" (monnaie) directement.
    final dollar = resources['dollar'];
    if (dollar != null) {
      dollar.amount += BigInt.from(resource.value) * quantity;
    }
  }

  void unlockResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource != null && !resource.unlock) {
      resources[resourceId] = Resource(
        id: resource.id,
        name: resource.name,
        initialAmount: resource.initialAmount,
        unlock: true,
        value: resource.value,
      );
    }
  }

  void attemptUnlockResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.unlock) return; // déjà débloquée ?
    if (resource.unlockCost == null) return; // pas de coût ?

    // Vérifier si on peut payer le coût
    final canPay = resource.unlockCost!.entries.every((entry) {
      final have = resources[entry.key]?.amount ?? BigInt.zero;
      return have >= entry.value;
    });
    if (!canPay) return;

    // Déduire le coût
    for (var entry in resource.unlockCost!.entries) {
      final cost = entry.value;
      resources[entry.key]!.amount -= cost;
    }

    // Marquer la ressource comme débloquée
    resource.unlock = true;
  }

  List<Resource> get unlockedResources =>
      resources.values
          .where((res) => res.unlock && res.id != 'dollar')
          .toList();

  List<Resource> get lockedResources =>
      resources.values
          .where((res) => !res.unlock && res.unlockCost != null)
          .toList();
}
