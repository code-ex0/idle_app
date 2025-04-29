import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/pages/home.page.dart';
import 'package:test_1/services/save_manager.service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resource Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E9D42),
          primary: const Color(0xFF3E9D42),
          secondary: const Color(0xFFFF8F00),
          tertiary: const Color(0xFF0277BD),
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF2D3142),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF2D3142),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shadowColor: Colors.black.withAlpha(26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF3E9D42).withAlpha(51),
          shadowColor: Colors.black.withAlpha(13),
          surfaceTintColor: Colors.white,
          elevation: 3,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3E9D42),
              );
            }
            return const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFF6B7280),
            );
          }),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF66BB6A),
          secondary: const Color(0xFFFFB74D),
          tertiary: const Color(0xFF4FC3F7),
          surface: const Color(0xFF2D3142),
          onSurface: const Color(0xFFE9EDF0),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFF1A1C2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D3142),
          foregroundColor: Color(0xFFE9EDF0),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE9EDF0),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE9EDF0),
          ),
          displayMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE9EDF0),
          ),
          displaySmall: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE9EDF0),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE9EDF0),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Color(0xFFE9EDF0),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Color(0xFFE9EDF0),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 3,
          shadowColor: Colors.black.withAlpha(77),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF66BB6A).withAlpha(51),
          shadowColor: Colors.black.withAlpha(51),
          surfaceTintColor: const Color(0xFF2D3142),
          elevation: 3,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF66BB6A),
              );
            }
            return const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Color(0xFFAFB4C2),
            );
          }),
        ),
      ),
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
