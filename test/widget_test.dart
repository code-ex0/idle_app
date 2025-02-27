// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/interfaces/resource.interface.dart';
import 'package:test_1/interfaces/building.interface.dart';
import 'package:test_1/interfaces/building.enum.dart';

void main() {
  group('GameState Tests', () {
    late GameState gameState;

    setUp(() {
      // Create dummy resources.
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
          initialAmount: 10, // ou une valeur suffisante
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

      // Create dummy building configurations.
      final buildingConfigs = {
        // Sawmill with infinite durability
        'sawmill': Building(
          id: 'sawmill',
          name: 'Sawmill',
          cost: {'wood': 50},
          production: {'wood': 1},
          durability: 0, // infinite durability
          type: BuildingType.sawmill,
          infiniteDurability: true,
          amount: 0,
          currentDurability: 0,
        ),
        // Stone Pile with finite durability (for tick production testing)
        'stonePile': Building(
          id: 'stonePile',
          name: 'Stone Pile',
          cost: {'wood': 50, 'stone': 1},
          production: {'wood': 2},
          durability: 100,
          type: BuildingType.quarry,
          infiniteDurability: false,
          amount: 0,
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
      expect(gameState.resources['wood']!.amount, equals(initialWood + 1));
    });

    test(
      'buyBuilding reduces resource amount and creates a building instance',
      () {
        final initialWood = gameState.resources['wood']!.amount;
        // Sawmill costs 50 wood.
        gameState.buyBuilding('sawmill');
        expect(gameState.resources['wood']!.amount, equals(initialWood - 50));
        expect(gameState.buildingInstances.length, equals(1));
        final purchased = gameState.buildingInstances.first;
        expect(purchased.id, equals('sawmill'));
        // For infinite durability building, currentDurability should equal durability (which is 0 here)
        expect(purchased.currentDurability, equals(0));
      },
    );

    test(
      'tick produces resources and degrades durability for finite buildings',
      () {
        // Create a new Stone Pile instance by buying it.
        // First, ensure we have enough wood and stone.
        gameState.resources['wood']!.amount = 200;
        // We'll assume stone is not required to buy here for test simplicity.
        gameState.buyBuilding('stonePile');
        // Our Stone Pile instance should now be in buildingInstances.
        expect(gameState.buildingInstances.length, equals(1));
        final stonePile = gameState.buildingInstances.first;
        // When a finite building is bought, currentDurability is set to its durability.
        expect(
          stonePile.currentDurability,
          equals(stonePile.durability.toDouble()),
        );

        final initialWood = gameState.resources['wood']!.amount;
        // Call tick: For a Stone Pile, degradationPerTick is 1 per building.
        gameState.tick();
        // Production: Stone Pile produces 2 wood per tick.
        expect(gameState.resources['wood']!.amount, equals(initialWood + 2));
        // Durability should be reduced by 1.
        expect(
          stonePile.currentDurability,
          equals(stonePile.durability.toDouble() - 1),
        );
      },
    );
  });
}
