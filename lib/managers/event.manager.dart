import 'dart:async';
import 'package:test_1/services/game_state.service.dart';

class EventManager {
  final List<GameEvent> _activeEvents = [];
  final List<GameEvent> _eventHistory = [];
  final Map<String, Timer> _eventTimers = {};

  List<GameEvent> get activeEvents => List.unmodifiable(_activeEvents);
  List<GameEvent> get eventHistory => List.unmodifiable(_eventHistory);

  void addEvent(GameEvent event) {
    _activeEvents.add(event);
    _eventHistory.add(event);

    // Créer un timer pour supprimer l'événement après sa durée
    final timer = Timer(event.duration, () {
      _removeEvent(event);
    });

    _eventTimers[event.id] = timer;
  }

  void _removeEvent(GameEvent event) {
    _activeEvents.remove(event);
    _eventTimers.remove(event.id)?.cancel();
  }

  void clearEvents() {
    _activeEvents.clear();
    for (final timer in _eventTimers.values) {
      timer.cancel();
    }
    _eventTimers.clear();
  }

  Map<String, dynamic> toJson() => {
    'activeEvents': _activeEvents.map((e) => _eventToJson(e)).toList(),
    'eventHistory': _eventHistory.map((e) => _eventToJson(e)).toList(),
  };

  void fromJson(Map<String, dynamic> json) {
    clearEvents();
    
    final activeEventsJson = json['activeEvents'] as List<dynamic>;
    final eventHistoryJson = json['eventHistory'] as List<dynamic>;

    for (var eventJson in activeEventsJson) {
      final event = _eventFromJson(eventJson);
      if (event != null) {
        addEvent(event);
      }
    }

    for (var eventJson in eventHistoryJson) {
      final event = _eventFromJson(eventJson);
      if (event != null) {
        _eventHistory.add(event);
      }
    }
  }

  Map<String, dynamic> _eventToJson(GameEvent event) => {
    'id': event.id,
    'name': event.name,
    'description': event.description,
    'type': event.type.toString().split('.').last,
    'multiplier': event.multiplier,
    'duration': event.duration.inMilliseconds,
  };

  GameEvent? _eventFromJson(Map<String, dynamic> json) {
    try {
      return GameEvent(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        type: EventType.values.firstWhere(
          (e) => e.toString() == 'EventType.${json['type']}',
        ),
        multiplier: json['multiplier'] as double,
        duration: Duration(milliseconds: json['duration'] as int),
      );
    } catch (e) {
      return null;
    }
  }
} 