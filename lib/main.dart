import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/pages/home.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GameState gameState = await GameState.loadGameState();
  runApp(
    ChangeNotifierProvider(create: (_) => gameState, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Clicker',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}
