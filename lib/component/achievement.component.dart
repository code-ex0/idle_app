import 'package:flutter/material.dart';
import 'package:test_1/interfaces/achievement.interface.dart';
import 'package:test_1/managers/achievement.manager.dart';

class AchievementComponent extends StatelessWidget {
  final Achievement achievement;
  final bool showProgress;

  const AchievementComponent({
    super.key,
    required this.achievement,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(
          achievement.icon,
          color: achievement.isUnlocked ? Colors.green : Colors.grey,
        ),
        title: Text(
          achievement.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: achievement.isUnlocked ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: achievement.isUnlocked ? Colors.black54 : Colors.grey,
              ),
            ),
            if (showProgress && !achievement.isUnlocked)
              _buildProgressIndicator(context),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              color: achievement.isUnlocked ? Colors.amber : Colors.grey,
            ),
            Text(
              '${achievement.points}',
              style: TextStyle(
                color: achievement.isUnlocked ? Colors.amber : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    // This would be implemented based on the achievement type and current progress
    return const LinearProgressIndicator(
      value: 0.5, // This should be calculated based on actual progress
      backgroundColor: Colors.grey,
      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
    );
  }
}

class AchievementList extends StatelessWidget {
  final AchievementManager achievementManager;

  const AchievementList({
    super.key,
    required this.achievementManager,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Débloqués'),
              Tab(text: 'En cours'),
              Tab(text: 'Secrets'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAchievementList(
                  achievementManager.getUnlockedAchievements(),
                  showProgress: false,
                ),
                _buildAchievementList(
                  achievementManager.getLockedAchievements(),
                  showProgress: true,
                ),
                _buildAchievementList(
                  achievementManager.getSecretAchievements(),
                  showProgress: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementList(List<Achievement> achievements, {required bool showProgress}) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('Aucun achievement'),
      );
    }

    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AchievementComponent(
          achievement: achievements[index],
          showProgress: showProgress,
        );
      },
    );
  }
} 