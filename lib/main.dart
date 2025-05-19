import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/pages/home.page.dart';
import 'package:test_1/services/save_manager.service.dart';
import 'app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resource Clicker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  final GameState gameState;

  AppLifecycleObserver(this.gameState);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      gameState.saveGame(force: true);
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger le GameState (qui gère déjà le chargement de la sauvegarde)
  final gameState = await GameState.loadGameState();

  // Vérifier si une sauvegarde existe et la charger
  final hasSave = await SaveManager.hasSave();
  if (hasSave) {
    debugPrint('Sauvegarde trouvée, chargement...');
    await gameState.loadGame();
  } else {
    debugPrint('Aucune sauvegarde trouvée, démarrage avec données initiales');
  }

  // Ajouter l'observateur du cycle de vie
  final observer = AppLifecycleObserver(gameState);
  WidgetsBinding.instance.addObserver(observer);

  runApp(ChangeNotifierProvider.value(value: gameState, child: const MyApp()));
}
