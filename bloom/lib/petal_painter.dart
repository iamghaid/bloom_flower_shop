import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class Petal {
  double x;
  double y;
  double size;
  double speed;
  double drift;
  double rotation;
  double rotationSpeed;
  double opacity;
  Color color;

  Petal({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.color,
  });
}

class PetalPainter extends CustomPainter {
  final List<Petal> petals;

  PetalPainter(this.petals);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in petals) {
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);

      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      // Petal shape (ellipse)
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.55),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(PetalPainter old) => true;
}

class FallingPetals extends StatefulWidget {
  const FallingPetals({super.key});

  @override
  State<FallingPetals> createState() => _FallingPetalsState();
}

class _FallingPetalsState extends State<FallingPetals>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Petal> _petals;
  final _rand = Random();

  static const _petalColors = [
    Color(0xFFE8B4A8),
    Color(0xFFF0C8BE),
    Color(0xFFD4988A),
    Color(0xFFF5DDD6),
    Color(0xFFE9C8C0),
  ];

  @override
  void initState() {
    super.initState();
    _petals = List.generate(28, (_) => _spawnPetal(fromTop: false));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_update)..repeat();
  }

  Petal _spawnPetal({bool fromTop = true}) {
    return Petal(
      x: _rand.nextDouble(),
      y: fromTop ? -0.05 : _rand.nextDouble(),
      size: 8 + _rand.nextDouble() * 14,
      speed: 0.0008 + _rand.nextDouble() * 0.0012,
      drift: (_rand.nextDouble() - 0.5) * 0.0008,
      rotation: _rand.nextDouble() * 2 * pi,
      rotationSpeed: (_rand.nextDouble() - 0.5) * 0.04,
      opacity: 0.25 + _rand.nextDouble() * 0.45,
      color: _petalColors[_rand.nextInt(_petalColors.length)],
    );
  }

  void _update() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _petals.length; i++) {
        final p = _petals[i];
        p.y += p.speed;
        p.x += p.drift;
        p.rotation += p.rotationSpeed;
        if (p.y > 1.08) {
          _petals[i] = _spawnPetal(fromTop: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: PetalPainter(_petals),
        size: Size.infinite,
      ),
    );
  }
}
