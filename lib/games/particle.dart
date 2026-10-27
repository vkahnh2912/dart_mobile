import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final double size;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.size,
    required this.color,
  }) : life = maxLife;

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    return life > 0;
  }

  static List<Particle> createJumpBurst(double x, double y) {
    final random = math.Random();
    final list = <Particle>[];
    for (int i = 0; i < 7; i++) {
      final angle = (math.pi / 2.0) + (random.nextDouble() - 0.5) * 1.2;
      final speed = 50.0 + random.nextDouble() * 90.0;
      list.add(
        Particle(
          x: x - 12.0 + (random.nextDouble() - 0.5) * 6.0,
          y: y + (random.nextDouble() - 0.5) * 6.0,
          vx: -math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          maxLife: 0.35 + random.nextDouble() * 0.25,
          size: 2.5 + random.nextDouble() * 3.5,
          color: random.nextBool()
              ? const Color(0xFFFFD54F) // Gold
              : const Color(0xFFFFFFFF), // White feather
        ),
      );
    }
    return list;
  }
}
