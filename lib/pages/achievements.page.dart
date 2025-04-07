import 'package:flutter/material.dart';
import 'package:test_1/component/achievement.component.dart';
import 'package:test_1/managers/achievement.manager.dart';

class AchievementsPage extends StatelessWidget {
  final AchievementManager achievementManager;

  const AchievementsPage({
    super.key,
    required this.achievementManager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${achievementManager.totalPoints}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AchievementList(achievementManager: achievementManager),
    );
  }
} 