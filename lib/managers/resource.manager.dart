// lib/managers/resource_manager.dart
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ResourceManager extends ChangeNotifier {
  final Map<String, Resource> resources = {};

  ResourceManager() {
    // Le constructeur ne crée plus de données par défaut
    // Les données doivent être chargées via initializeResources
  }

  void addResource(String resourceId, BigInt amount) {
    resources[resourceId]?.amount += amount;
  }

  void removeResource(String resourceId, BigInt amount) {
    final currentAmount = resources[resourceId]?.amount ?? BigInt.zero;
    if (currentAmount >= amount) {
      resources[resourceId]?.amount -= amount;
    }
  }

  void initializeResources(Map<String, Resource> initialResources) {
    resources.clear();
    resources.addAll(initialResources);
    notifyListeners();
  }

  void clickResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource != null && resource.isUnlocked) {
      // Ajouter la valeur de la ressource à la ressource elle-même
      resource.amount += BigInt.one;
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
      dollar.amount += resource.value * quantity;
    }
  }

  void unlockResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource != null) {
      resource.isUnlocked = true;
      notifyListeners();
    }
  }

  void attemptUnlockResource(String resourceId) {
    final resource = resources[resourceId];
    if (resource == null) return;
    if (resource.isUnlocked) return; // déjà débloquée ?
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
    resource.isUnlocked = true;
  }

  List<Resource> get unlockedResources =>
      resources.values
          .where((res) => res.isUnlocked && res.id != 'dollar')
          .toList();

  List<Resource> get lockedResources =>
      resources.values
          .where((res) => !res.isUnlocked && res.unlockCost != null)
          .toList();

  Map<String, dynamic> toJson() {
    return resources.map(
      (key, value) => MapEntry(key, {
        'amount': value.amount.toString(),
        'value': value.value.toString(),
        'isUnlocked': value.isUnlocked,
      }),
    );
  }

  void fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        final resource = resources[key];
        if (resource != null) {
          resource.amount = BigInt.parse(value['amount'].toString());
          resource.value = BigInt.parse(value['value'].toString());
          resource.isUnlocked = value['isUnlocked'] ?? false;
        }
      }
    });
    notifyListeners();
  }
}
