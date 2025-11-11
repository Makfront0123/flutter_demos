import 'dart:math' as math;
import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animation_01/bloc_painter.dart';
import 'package:flutter_animation_01/particle_model.dart';

class AnimateMenuScreen extends StatefulWidget {
  const AnimateMenuScreen({super.key});

  @override
  State<AnimateMenuScreen> createState() => _AnimateMenuScreenState();
}

class _AnimateMenuScreenState extends State<AnimateMenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _menuController;
  late final Animation<double> _menuAnimation;
  late final AnimationController _particleController;

  bool isOpen = false;

  final List<IconData> icons = [
    Icons.favorite,
    Icons.camera_alt,
    Icons.music_note,
    Icons.settings,
  ];

  late List<Particle> particles;
  final int particleCount = 6;
  final double maxWidth = 500;
  final double maxHeight = 700;
  final math.Random rnd = math.Random();

  @override
  void initState() {
    super.initState();

    particles = List.generate(particleCount, (i) {
      return Particle(
        Offset(rnd.nextDouble() * maxWidth, rnd.nextDouble() * maxHeight),
        Offset((rnd.nextDouble() - 0.5) * 2.0, (rnd.nextDouble() - 0.5) * 2.0),
        [
          Colors.pinkAccent,
          Colors.cyanAccent,
          Colors.amberAccent,
          Colors.lightBlueAccent,
          Colors.limeAccent,
        ][rnd.nextInt(5)].withOpacity(0.8),
        60 + rnd.nextDouble() * 150,
      );
    });

    _particleController =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(_updateParticles)
          ..repeat();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
  }

  void _updateParticles() {
    if (!isOpen) return;
    final t = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (final p in particles) {
      p.position = p.position + p.velocity;

      final dx = math.sin(t + p.hashCode * 0.0003) * 1.4;
      final dy = math.cos(t + p.hashCode * 0.0005) * 1.4;
      p.position = p.position.translate(dx, dy);

      if (p.position.dx < 0 || p.position.dx > maxWidth) {
        p.velocity = Offset(-p.velocity.dx, p.velocity.dy);
      }
      if (p.position.dy < 0 || p.position.dy > maxHeight) {
        p.velocity = Offset(p.velocity.dx, -p.velocity.dy);
      }

      p.velocity = Offset(
        p.velocity.dx + (rnd.nextDouble() - 0.5) * 0.3,
        p.velocity.dy + (rnd.nextDouble() - 0.5) * 0.3,
      );
    }

    if (mounted) setState(() {});
  }

  void _toggleMenu() async {
    HapticFeedback.selectionClick();
    setState(() => isOpen = !isOpen);

    if (isOpen) {
      for (final p in particles) {
        p.velocity = Offset(
          (rnd.nextDouble() - 0.5) * 10,
          (rnd.nextDouble() - 0.5) * 10,
        );
      }
      await _menuController.forward();
    } else {
      await _menuController.reverse();
    }
  }

  Widget _buildOption(IconData icon, double angle, int index) {
    const double radius = 110;
    return AnimatedBuilder(
      animation: _menuAnimation,
      builder: (context, child) {
        final offsetX = radius * math.cos(angle) * _menuAnimation.value;
        final offsetY = radius * math.sin(angle) * _menuAnimation.value;

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.scale(
            scale: 0.6 + 0.4 * _menuAnimation.value,
            child: FloatingActionButton(
              heroTag: "icon_$index",
              backgroundColor: Colors.purpleAccent.withOpacity(.95),
              onPressed: () => HapticFeedback.mediumImpact(),
              mini: true,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final blurRadius = isOpen ? 60.0 : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.purpleAccent.withOpacity(0.2),
                  Colors.black.withOpacity(0.95),
                ],
                radius: isOpen ? 1.5 : 0.3,
              ),
            ),
          ).blurred(blur: blurRadius),

          if (isOpen)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.15 +
                        math.sin(
                              DateTime.now().millisecondsSinceEpoch * 0.001,
                            ) *
                            0.05,
                  ),
                ),
              ),
            ),

          if (isOpen)
            CustomPaint(
              size: const Size(400, 700),
              painter: BlobPainter(particles, isOpen),
            ),

          _buildOption(icons[0], 0, 0),
          _buildOption(icons[1], math.pi / 3, 1),
          _buildOption(icons[2], -math.pi / 3, 2),
          _buildOption(icons[3], math.pi, 3),

          FloatingActionButton(
            backgroundColor: Colors.pinkAccent,
            onPressed: _toggleMenu,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _menuAnimation,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _particleController.removeListener(_updateParticles);
    _particleController.dispose();
    _menuController.dispose();
    super.dispose();
  }
}
