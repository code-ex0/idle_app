import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/building.enum.dart';

void main() {
  group('GameState Tests with BuildingGroup', () {
    late GameState gameState;

    setUp(() {
      // Création de ressources factices.
      final resources = {
        'wood': Resource(
          id: 'wood',
          name: 'Wood',
          initialAmount: 100,
          unlock: true,
          value: 1,
        ),
        'stone': Resource(
          id: 'stone',
          name: 'Stone',
          initialAmount: 10,
          unlock: true,
          value: 2,
        ),
        'gold': Resource(
          id: 'gold',
          name: 'Gold',
          initialAmount: 0,
          unlock: true,
          value: 0,
        ),
        // On peut également ajouter la ressource "dollar" ou "dolard" si nécessaire.
      };

      // Création de configurations de bâtiments factices.
      final buildingConfigs = {
        // Sawmill avec durabilité infinie.
        'sawmill': Building(
          id: 'sawmill',
          name: 'Sawmill',
          cost: {'wood': BigInt.from(50)},
          production: {'wood': BigInt.from(1)},
          durability: 0, // Infinie
          type: BuildingType.sawmill,
          infiniteDurability: true,
          amount: BigInt.zero,
          currentDurability: 0,
        ),
        // Stone Pile avec durabilité finie.
        'stonePile': Building(
          id: 'stonePile',
          name: 'Stone Pile',
          cost: {'wood': BigInt.from(50), 'stone': BigInt.from(1)},
          production: {'wood': BigInt.from(2)},
          durability: 100,
          type: BuildingType.quarry,
          infiniteDurability: false,
          amount: BigInt.zero,
          currentDurability: 0,
        ),
      };

      gameState = GameState(
        resources: resources,
        buildingConfigs: buildingConfigs,
      );
    });

    test('clickResource increments resource amount', () {
      final initialWood = gameState.resourceManager.resources['wood']!.amount;
      gameState.clickResource('wood');
      expect(
        gameState.resourceManager.resources['wood']!.amount,
        equals(initialWood + BigInt.one),
      );
    });

    test(
      'buyBuilding reduces resource amount and creates a building group entry',
      () {
        final initialWood = gameState.resourceManager.resources['wood']!.amount;
        // Sawmill coûte 50 wood.
        gameState.buyBuilding('sawmill');
        expect(
          gameState.resourceManager.resources['wood']!.amount,
          equals(initialWood - BigInt.from(50)),
        );
        expect(
          gameState.buildingManager.buildingGroups.containsKey('sawmill'),
          isTrue,
        );
        final group = gameState.buildingManager.buildingGroups['sawmill']!;
        expect(group.count, equals(BigInt.one));
        // Pour un bâtiment à durabilité infinie, listDurabilitys doit rester vide.
        expect(group.listDurabilitys, isEmpty);
      },
    );

    test(
      'tick produces resources and degrades durability for finite buildings',
      () {
        // Assurer d'avoir assez de wood et stone.
        gameState.resourceManager.resources['wood']!.amount = BigInt.from(200);
        gameState.resourceManager.resources['stone']!.amount = BigInt.from(10);
        // Acheter une Stone Pile.
        gameState.buyBuilding('stonePile');
        expect(
          gameState.buildingManager.buildingGroups.containsKey('stonePile'),
          isTrue,
        );
        final group = gameState.buildingManager.buildingGroups['stonePile']!;
        // Lors de l'achat, listDurabilitys doit contenir une valeur égale à la durabilité de base.
        expect(group.listDurabilitys, equals([group.config.durability]));
        expect(group.count, equals(BigInt.one));

        final initialWood = gameState.resourceManager.resources['wood']!.amount;
        // Appel de tick : Stone Pile produit 2 wood par tick.
        gameState.tick();
        expect(
          gameState.resourceManager.resources['wood']!.amount,
          equals(initialWood + BigInt.from(2)),
        );
        // La dégradation devrait réduire la valeur dans listDurabilitys de 1.
        expect(group.listDurabilitys, equals([group.config.durability - 1]));
        expect(group.count, equals(BigInt.one));
      },
    );
  });
}
