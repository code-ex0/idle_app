import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_1/services/game_state.service.dart';
import 'dart:math' as math;

class ClickerPage extends StatefulWidget {
  const ClickerPage({super.key});

  @override
  State<ClickerPage> createState() => _ClickerPageState();
}

class _ClickerPageState extends State<ClickerPage> with SingleTickerProviderStateMixin {
  OverlayEntry? _floatingTextEntry;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _clickCount = 0;
  bool _isBoosted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } 
    });

    // Démarrer l'animation de pulsation douce
    _pulseController.forward();
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _pulseController.forward();
      }
    });
  }

  @override
  void dispose() {
    _floatingTextEntry?.remove();
    _pulseController.dispose();
    super.dispose();
  }

  void _showFloatingText(Offset position, String value) {
    if (_floatingTextEntry != null) {
      _floatingTextEntry!.remove();
      _floatingTextEntry = null;
    }
    
    // Define animation variables
    final animationDuration = const Duration(milliseconds: 1500);
    
    _floatingTextEntry = OverlayEntry(
      builder: (context) {
        return FloatingText(
          position: position,
          value: value,
          color: _isBoosted ? Colors.orange : Theme.of(context).colorScheme.primary,
          onComplete: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _floatingTextEntry?.remove();
              _floatingTextEntry = null;
            });
          },
        );
      }
    );
    
    Overlay.of(context).insert(_floatingTextEntry!);
    
    // Auto-remove after animation completes
    Future.delayed(animationDuration, () {
      if (_floatingTextEntry != null) {
        _floatingTextEntry!.remove();
        _floatingTextEntry = null;
      }
    });
  }

  // Fonction pour calculer la valeur du clic
  String _getClickValue() {
    // Augmenter la valeur après plusieurs clics consécutifs
    _clickCount++;
    
    // Après 10 clics rapides, activer le mode boost
    if (_clickCount >= 10) {
      _isBoosted = true;
      _clickCount = 0;
      return '+5';
    }
    
    // Après 5 clics, donner un bonus
    if (_clickCount >= 5) {
      return '+2';
    }
    
    // Par défaut
    return '+1';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Stack(
      children: [
        // Fond avec particules animées (effet de bulles montantes)
        const ParticleBackground(),
        
        // Contenu principal
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Statistiques de clic
              Container(
                margin: const EdgeInsets.only(bottom: 40),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<GameState>(
                  builder: (context, gameState, child) {
                    // Obtenir les stats de clics (vous devrez peut-être ajouter cette fonctionnalité à votre GameState)
                    final dollarAmount = gameState.resourceManager.resources['dollar']?.amount ?? BigInt.zero;
                    
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.ads_click_rounded,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Total : ${GameState.formatResourceAmount(dollarAmount)}",
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              
              // Effet de lueur autour du bouton
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isBoosted ? Colors.orange : colorScheme.primary).withAlpha(77),
                            spreadRadius: 10,
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                child: Consumer<GameState>(
                  builder: (context, gameState, child) {
                    return GestureDetector(
                      onTap: () {
                        // Commencer par déterminer la valeur du clic
                        String clickValue = _getClickValue();
                        int clickAmount = int.parse(clickValue.substring(1));
                        
                        // Déclencher une animation de pulsation
                        _pulseController.forward(from: 0.0);
                        
                        // Ajouter la ressource
                        gameState.clickResource('dollar', amount: clickAmount);
                        
                        // Calculer la position pour le texte flottant
                        final renderBox = context.findRenderObject() as RenderBox;
                        final position = renderBox.localToGlobal(
                          renderBox.size.center(Offset.zero),
                          ancestor: Overlay.of(context).context.findRenderObject(),
                        );
                        
                        // Afficher le texte flottant
                        _showFloatingText(position, clickValue);
                        
                        // Réinitialiser le mode boost après un certain temps
                        if (_isBoosted) {
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() {
                                _isBoosted = false;
                              });
                            }
                          });
                        }
                      },
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isBoosted 
                                ? [Colors.orange.shade400, Colors.orange.shade700]
                                : [colorScheme.primary, colorScheme.primary.withRed(colorScheme.primary.r.toInt() + 30)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isBoosted ? Colors.orange : colorScheme.primary).withAlpha(102),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isBoosted ? Icons.bolt_rounded : Icons.touch_app_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isBoosted ? "BOOST!" : "CLIQUEZ!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
              
              // Texte d'instruction
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Cliquez pour gagner des ressources !",
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Astuce : Cliquez rapidement pour des bonus !",
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
            color: widget.color.withAlpha(64),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de fond avec des particules animées
class ParticleBackground extends StatefulWidget {
  const ParticleBackground({super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Générer moins de particules
    particles = List.generate(12, (index) => Particle.random());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Stack(
      children: [
        // Ajouter un fond de couleur
        Container(
          width: double.infinity,
          height: double.infinity,
          // Utiliser un gradient subtil pour un meilleur effet visuel
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.surface,
                colorScheme.surface.withAlpha(245), // Très légère variation
              ],
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Mettre à jour la position des particules
            for (var particle in particles) {
              particle.update();
            }
            
            return CustomPaint(
              painter: ParticlePainter(
                particles: particles, 
                color: colorScheme.primary,
                animation: _controller.value,
              ),
              child: Container(),
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });

  factory Particle.random() {
    return Particle(
      x: math.Random().nextDouble(),
      y: math.Random().nextDouble(),
      size: math.Random().nextDouble() * 10 + 3,
      speed: math.Random().nextDouble() * 0.005 + 0.001,
      opacity: math.Random().nextDouble() * 0.3 + 0.05,
    );
  }

  void update() {
    y -= speed;
    if (y < 0) {
      y = 1.0;
      x = math.Random().nextDouble();
      size = math.Random().nextDouble() * 10 + 3;
      opacity = math.Random().nextDouble() * 0.3 + 0.05;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final Color color;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = color.withAlpha((particle.opacity * (0.5 + 0.5 * math.sin(animation * 2 * math.pi)) * 255).toInt())
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 