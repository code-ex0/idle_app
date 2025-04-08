import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/pages/%E2%80%AFunlock.page.dart';
import 'package:test_1/services/game_state.service.dart';
import 'package:test_1/pages/artisanat.page.dart';
import 'package:test_1/pages/fonderie.page.dart';
import 'package:test_1/pages/market.page.dart';
import 'package:test_1/pages/mine.page.dart';
import 'package:test_1/pages/scierie.page.dart';
import 'package:test_1/pages/achievements.page.dart';
import 'package:test_1/pages/clicker.page.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  // This field is used for future extensibility
  // ignore: unused_field
  int? _selectedSubIndex;
  late AnimationController _animationController;
  OverlayEntry? _currentOverlayEntry;

  // Regroupement des pages en catégories
  static final List<Widget> _pages = <Widget>[
    const ScieriePage(),     // Production
    const MinePage(),        // Production
    const MarketPage(),      // Commerce
    const FonderiePage(),    // Transformation
    const ArtisanatPage(),   // Transformation
    const UnlockingPage(),   // Progression
    const ClickerPage(),     // Page de clicker
  ];

  // Nouvelle liste simplifiée des pages avec structure
  static final List<Map<String, dynamic>> _menuCategories = [
    {
      'icon': Icons.precision_manufacturing_outlined,
      'label': 'Production',
      'pages': [0, 1], // Indices des pages Scierie et Mine
    },
    {
      'icon': Icons.store_outlined,
      'label': 'Commerce',
      'pages': [2], // Indice de la page Marché
    },
    // Élément central (sera remplacé par le bouton de clic)
    {
      'icon': Icons.touch_app_rounded,
      'label': 'Clicker',
      'pages': [6], // Indice de la nouvelle page Clicker
    },
    {
      'icon': Icons.recycling_outlined,
      'label': 'Transform',
      'pages': [3, 4], // Indices des pages Fonderie et Artisanat
    },
    {
      'icon': Icons.lock_open_outlined,
      'label': 'Progrès',
      'pages': [5], // Indice de la page Déblocage
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _currentOverlayEntry?.remove();
    super.dispose();
  }

  void _onCategoryTapped(int categoryIndex, int pageIndex) {
    setState(() {
      _selectedIndex = _menuCategories[categoryIndex]['pages'][pageIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final currencyAmount =
        gameState.resourceManager.resources['dollar']?.amount ??
        BigInt.zero;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Vérifier si nous sommes dans une catégorie de production
    final currentCategoryIndex = _getCategoryFromPageIndex(_selectedIndex);
    final isProductionCategory = currentCategoryIndex == 0;

    // Vérifier si nous sommes sur la page de clic
    final isClickerPage = _selectedIndex == 6;

    // Use this variable somewhere or remove it
    Widget mainContent = isClickerPage 
        ? const ClickerPage() 
        : _pages[_selectedIndex];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: colorScheme.surface.withAlpha(178),
            ),
          ),
        ),
        title: Text(
          'Idle Dolard Game',
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<GameState>(
            builder: (context, gameState, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.secondary.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_money_rounded, 
                      size: 22,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      GameState.formatResourceAmount(currencyAmount),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: colorScheme.tertiary,
                  size: 22,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                      AchievementsPage(
                        achievementManager: context.read<GameState>().achievementManager,
                      ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.surface.withBlue(colorScheme.surface.b.toInt() + 5),
            ],
          ),
        ),
        child: mainContent,
      ),
      bottomNavigationBar: SafeArea(
        top: false, // We only care about bottom padding here.
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sous-menu production (affiché uniquement quand la catégorie Production est sélectionnée)
          if (isProductionCategory)
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < _menuCategories[0]['pages'].length; i++)
                      _buildProductionMenuItem(i),
                  ],
                ),
              ),
            ),
          // Menu principal par catégories
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20), // 0.08 * 255 = ~20
                  blurRadius: 8,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                selectedIndex: _getCategoryFromPageIndex(_selectedIndex),
                onDestinationSelected: (index) {
                  // Pour le bouton du milieu (Clicker)
                  if (index == 2) {
                    setState(() {
                      _selectedIndex = 6; // Indice de la page Clicker
                    });
                  } else {
                    // Pour les autres boutons, sélectionner la première page de la catégorie
                    setState(() {
                      _selectedIndex = _menuCategories[index]['pages'][0];
                    });
                  }
                },
                destinations: [
                  for (int i = 0; i < _menuCategories.length; i++)
                    i == 2 
                      ? NavigationDestination(
                          icon: _buildFloatingActionButton(colorScheme),
                          label: _menuCategories[i]['label'] as String,
                          selectedIcon: _buildFloatingActionButton(colorScheme, selected: true),
                        )
                      : NavigationDestination(
                          icon: Icon(
                            _menuCategories[i]['icon'] as IconData,
                            color: colorScheme.onSurface.withAlpha(178),
                            size: 24,
                          ),
                          label: _menuCategories[i]['label'] as String,
                          selectedIcon: Icon(
                            _menuCategories[i]['icon'] as IconData,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  // Construire le bouton flottant pour le menu
  Widget _buildFloatingActionButton(ColorScheme colorScheme, {bool selected = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            selected ? colorScheme.primary : colorScheme.primary.withAlpha(178),
            selected ? colorScheme.primary.withRed(colorScheme.primary.r.toInt() + 30) : colorScheme.primary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(77),
            blurRadius: selected ? 10 : 6,
            spreadRadius: selected ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.touch_app_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }

  // Construire un élément de sous-menu pour la production (simplifié)
  Widget _buildProductionMenuItem(int pageIndex) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pageId = _menuCategories[0]['pages'][pageIndex];
    final isSelected = _selectedIndex == pageId;
    
    String pageName = _getPageName(pageId);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategoryTapped(0, pageIndex),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary.withAlpha(26) : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            child: Center(
              child: Text(
                pageName,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface.withAlpha(178),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Obtenir le nom correspondant à une page
  String _getPageName(int pageIndex) {
    switch (pageIndex) {
      case 0: return 'Scierie';
      case 1: return 'Mine';
      case 2: return 'Marché';
      case 3: return 'Fonderie';
      case 4: return 'Artisanat';
      case 5: return 'Déblocage';
      case 6: return 'Clicker';
      default: return 'Page';
    }
  }

  // Trouver la catégorie correspondant à un index de page
  int _getCategoryFromPageIndex(int pageIndex) {
    for (int i = 0; i < _menuCategories.length; i++) {
      if ((_menuCategories[i]['pages'] as List<int>).contains(pageIndex)) {
        return i;
      }
    }
    return 0; // Par défaut, retourner la première catégorie
  }
}

// Widget pour les textes flottants qui apparaissent lors du clic
class FloatingText extends StatefulWidget {
  final Offset position;
  final String value;
  final Color color;
  final VoidCallback onComplete;

  const FloatingText({
    super.key,
    required this.position,
    required this.value,
    required this.color,
    required this.onComplete,
  });

  @override
  State<FloatingText> createState() => _FloatingTextState();
}

class _FloatingTextState extends State<FloatingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _position;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _scale = Tween<double>(begin: 0.5, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Combinaison des animations d'opacité
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_controller);

    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -100),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuad),
      ),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 30,
      top: widget.position.dy - 40,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: _position.value,
              child: Transform.scale(
                scale: _scale.value,
                child: child,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.color.withAlpha(38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withAlpha(77),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha(51),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            widget.value,
            style: TextStyle(
              color: widget.color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
