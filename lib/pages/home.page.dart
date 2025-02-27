import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/game_state.dart';
import 'package:test_1/pages/artisanat.page.dart';
import 'package:test_1/pages/fonderie.page.dart';
import 'package:test_1/pages/market.page.dart';
import 'package:test_1/pages/mine.page.dart';
import 'package:test_1/pages/scierie.page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ScieriePage(),
    const MinePage(),
    const MarketPage(),
    const FonderiePage(),
    const ArtisanatPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Consumer<GameState>(
            builder: (context, gameState, child) {
              final gold = gameState.resources['gold']?.amount ?? 0;
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text('Or: $gold')),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed:
                    () => context.read<GameState>().clickResource('wood'),
                style: ElevatedButton.styleFrom(
                  // radius to zero
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80,
                    vertical: 20,
                  ),
                ),
                child: const Text('Click'),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Permet d'afficher 5 onglets
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.carpenter),
            label: 'Scierie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Mine',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marché'),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department),
            label: 'Fonderie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Artisanat',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
