import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/building.enum.dart';
import 'package:test_1/interfaces/building_group.interface.dart';
import 'package:test_1/managers/resource.manager.dart';
import 'package:test_1/managers/building.manager.dart';
import 'package:test_1/managers/achievement.manager.dart';
import 'package:test_1/managers/market.manager.dart';
import 'package:test_1/managers/event.manager.dart';

void main() {
  group('GameState Tests with BuildingGroup', () {
    late GameState gameState;
    late ResourceManager resourceManager;
    late BuildingManager buildingManager;

    setUp(() {
      // Création de ressources factices.
      final resources = {
        'wood': Resource(
          id: 'wood',
          name: 'Wood',
          initialAmount: BigInt.from(100),
          icon: 'wood_icon',
          value: BigInt.from(1),
          isUnlocked: true,
        ),
        'stone': Resource(
          id: 'stone',
          name: 'Stone',
          initialAmount: BigInt.from(10),
          icon: 'stone_icon',
          value: BigInt.from(2),
          isUnlocked: true,
        ),
        'dollar': Resource(
          id: 'dollar',
          name: 'Dollar',
          initialAmount: BigInt.from(1000),
          icon: 'dollar_icon',
          value: BigInt.from(1),
          isUnlocked: true,
        ),
      };

      resourceManager = ResourceManager(resources: resources);
      buildingManager = BuildingManager();

      // Modification manuelle des bâtiments pour les tests
      buildingManager.buildings['sawmill'] = Building(
        id: 'sawmill',
        name: 'Sawmill',
        cost: {'wood': BigInt.from(50)},
        production: {'wood': BigInt.from(1)},
        durability: BigInt.from(100),
        type: BuildingType.sawmill,
        infiniteDurability: true,
        amount: BigInt.zero,
      );

      buildingManager.buildings['stonePile'] = Building(
        id: 'stonePile',
        name: 'Stone Pile',
        cost: {'wood': BigInt.from(50), 'stone': BigInt.from(1)},
        production: {'wood': BigInt.from(2)},
        durability: BigInt.from(100),
        type: BuildingType.quarry,
        infiniteDurability: false,
        amount: BigInt.zero,
      );

      // Initialiser les groupes de bâtiments
      for (var building in buildingManager.buildings.values) {
        buildingManager.buildingGroups[building.id] = BuildingGroup(config: building);
      }

      gameState = GameState(
        resourceManager: resourceManager,
        buildingManager: buildingManager,
        achievementManager: AchievementManager(),
        marketManager: MarketManager(resourceIds: resources.keys.toList()),
        eventManager: EventManager(),
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
        
        // Vérifier que le building a bien été ajouté au groupe
        expect(group.count, equals(BigInt.one));

        final initialWood = gameState.resourceManager.resources['wood']!.amount;
        
        // Appel de tick : Stone Pile produit 2 wood par tick.
        gameState.tick();
        
        expect(
          gameState.resourceManager.resources['wood']!.amount,
          equals(initialWood + BigInt.from(2)),
        );
        
        // La dégradation devrait réduire la durabilité
        expect(group.count, equals(BigInt.one));
      },
    );
  });
}
