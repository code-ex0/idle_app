import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/game_state.dart';
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
      final initialWood = gameState.resources['wood']!.amount;
      gameState.clickResource('wood');
      expect(
        gameState.resources['wood']!.amount,
        equals(initialWood + BigInt.one),
      );
    });

    test(
      'buyBuilding reduces resource amount and creates a building group entry',
      () {
        final initialWood = gameState.resources['wood']!.amount;
        // Sawmill coûte 50 wood.
        gameState.buyBuilding('sawmill');
        expect(
          gameState.resources['wood']!.amount,
          equals(initialWood - BigInt.from(50)),
        );
        expect(gameState.buildingGroups.containsKey('sawmill'), isTrue);
        final group = gameState.buildingGroups['sawmill']!;
        expect(group.count, equals(BigInt.one));
        // Pour un bâtiment à durabilité infinie, aggregatedDurability n'est pas utilisé (ou reste à 0).
        if (!group.config.infiniteDurability) {
          expect(group.listDurabilitys, equals(group.config.durability));
        }
      },
    );

    test(
      'tick produces resources and degrades durability for finite buildings',
      () {
        // Assurer d'avoir assez de wood et stone.
        gameState.resources['wood']!.amount = BigInt.from(200);
        gameState.resources['stone']!.amount = BigInt.from(10);
        // Acheter une Stone Pile.
        gameState.buyBuilding('stonePile');
        expect(gameState.buildingGroups.containsKey('stonePile'), isTrue);
        final group = gameState.buildingGroups['stonePile']!;
        // Lors de l'achat, aggregatedDurability doit être égal à la durabilité de base.
        expect(group.listDurabilitys, [equals(group.config.durability)]);

        final initialWood = gameState.resources['wood']!.amount;
        // Appel de tick : une Stone Pile produit 2 wood par tick.
        gameState.tick();
        expect(
          gameState.resources['wood']!.amount,
          equals(initialWood + BigInt.from(2)),
        );
        // La dégradation devrait réduire aggregatedDurability de 1 * count (ici, count == 1).
        expect(group.listDurabilitys, [equals(group.config.durability - 1)]);
      },
    );
  });
}
