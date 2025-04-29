import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_1/services/game_state.service.dart';

class SaveManager {
  static const String _saveKey = 'game_save';
  static const String _lastSaveTimeKey = 'last_save_time';

  /// Convertit une Map contenant des BigInt en Map de chaînes de caractères
  static Map<String, dynamic> _convertBigIntMap(Map<String, dynamic> map) {
    return map.map((key, value) {
      if (value is BigInt) {
        return MapEntry(key, value.toString());
      } else if (value is Map<String, dynamic>) {
        return MapEntry(key, _convertBigIntMap(value));
      } else if (value is List) {
        return MapEntry(
          key,
          value.map((item) {
            if (item is BigInt) {
              return item.toString();
            } else if (item is Map<String, dynamic>) {
              return _convertBigIntMap(item);
            }
            return item;
          }).toList(),
        );
      }
      return MapEntry(key, value);
    });
  }

  /// Sauvegarde l'état actuel du jeu
  static Future<void> saveGame(
    GameState gameState, {
    bool force = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Si force est false, vérifier si une sauvegarde existe déjà
      if (!force && await hasSave()) {
        throw Exception(
          'Une sauvegarde existe déjà. Utilisez force=true pour écraser.',
        );
      }

      // Convertir toutes les données en format JSON sérialisable
      final saveData = {
        'resources': _convertBigIntMap(gameState.resourceManager.toJson()),
        'buildings': _convertBigIntMap(gameState.buildingManager.toJson()),
        'achievements': _convertBigIntMap(
          gameState.achievementManager.toJson(),
        ),
        'market': _convertBigIntMap(gameState.marketManager.toJson()),
        'events': _convertBigIntMap(gameState.eventManager.toJson()),
        'statistics': gameState.statistics.map(
          (category, values) => MapEntry(
            category,
            values.map((key, value) => MapEntry(key, value.toString())),
          ),
        ),
        'timestamp': DateTime.now().toIso8601String(),
        'isGameWon': gameState.isGameWon,
      };

      await prefs.setString(_saveKey, jsonEncode(saveData));
      await prefs.setString(_lastSaveTimeKey, DateTime.now().toIso8601String());

      debugPrint('Jeu sauvegardé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde: $e');
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  /// Charge la dernière sauvegarde
  static Future<Map<String, dynamic>?> loadGame() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saveData = prefs.getString(_saveKey);

      if (saveData == null) {
        debugPrint('Aucune sauvegarde trouvée');
        return null;
      }

      final json = jsonDecode(saveData);
      debugPrint('Sauvegarde chargée avec succès');
      return json;
    } catch (e) {
      debugPrint('Erreur lors du chargement de la sauvegarde: $e');
      return null;
    }
  }

  /// Vérifie si une sauvegarde existe
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  /// Supprime la sauvegarde actuelle
  static Future<void> deleteSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_saveKey);
      await prefs.remove(_lastSaveTimeKey);
      debugPrint('Sauvegarde supprimée avec succès');
    } catch (e) {
      debugPrint('Erreur lors de la suppression de la sauvegarde: $e');
      throw Exception('Erreur lors de la suppression de la sauvegarde: $e');
    }
  }

  /// Récupère la date de la dernière sauvegarde
  static Future<DateTime?> getLastSaveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSaveTime = prefs.getString(_lastSaveTimeKey);
      return lastSaveTime != null ? DateTime.parse(lastSaveTime) : null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la date de sauvegarde: $e');
      return null;
    }
  }
}
