import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bird.dart';
import 'pipe.dart';
import 'particle.dart';

class GamePainter extends CustomPainter {
  final Bird bird;
  final List<Pipe> pipes;
  final List<Particle> particles;
  final double groundOffset;
  final double cloudOffset;
  final bool isNight;
  final double flashOpacity;

  static const double virtualWidth = 360.0;
  static const double virtualHeight = 640.0;
  static const double groundHeight = 112.0;
  static const double groundY = virtualHeight - groundHeight;

  GamePainter({
    required this.bird,
    required this.pipes,
    required this.particles,
    required this.groundOffset,
    required this.cloudOffset,
    required this.isNight,
    required this.flashOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Uniform scaling to maintain 9:16 aspect ratio
    final scale = math.min(size.width / virtualWidth, size.height / virtualHeight);
    final dx = (size.width - virtualWidth * scale) / 2.0;
    final dy = (size.height - virtualHeight * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    // Clip to virtual play area
    canvas.clipRect(const Rect.fromLTWH(0, 0, virtualWidth, virtualHeight));

    // 1. Draw Sky Background
    _drawSky(canvas);

    // 2. Draw Distant Parallax Hills & City
    _drawBackdrop(canvas);

    // 3. Draw Clouds
    _drawClouds(canvas);

    // 4. Draw Pipes
    _drawPipes(canvas);

    // 5. Draw Particles
    _drawParticles(canvas);

    // 6. Draw Bird
    _drawBird(canvas);

    // 7. Draw Ground
    _drawGround(canvas);

    // 8. Draw Impact Flash if any
    if (flashOpacity > 0.0) {
      final flashPaint = Paint()..color = Colors.white.withValues(alpha: flashOpacity.clamp(0.0, 1.0));
      canvas.drawRect(const Rect.fromLTWH(0, 0, virtualWidth, virtualHeight), flashPaint);
    }

    canvas.restore();
  }

  void _drawSky(Canvas canvas) {
    final rect = const Rect.fromLTWH(0, 0, virtualWidth, virtualHeight);
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? [const Color(0xFF0D1B2A), const Color(0xFF1B263B), const Color(0xFF415A77)]
            : [const Color(0xFF4EC0CA), const Color(0xFF86E3CE), const Color(0xFFD0F4DE)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    if (isNight) {
      // Draw Stars
      final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
      final stars = [
        const Offset(40, 60), const Offset(90, 40), const Offset(150, 90),
        const Offset(220, 50), const Offset(280, 80), const Offset(320, 45),
        const Offset(65, 140), const Offset(190, 160), const Offset(260, 130),
      ];
      for (final star in stars) {
        canvas.drawCircle(star, 1.5, starPaint);
      }
      // Moon
      final moonPaint = Paint()..color = const Color(0xFFFFF7C2);
      canvas.drawCircle(const Offset(300, 70), 18, moonPaint);
      final craterPaint = Paint()..color = const Color(0xFFEADB9A);
      canvas.drawCircle(const Offset(305, 68), 3.5, craterPaint);
      canvas.drawCircle(const Offset(296, 76), 2.5, craterPaint);
    }
  }

  void _drawBackdrop(Canvas canvas) {
    final hillPaint = Paint()
      ..color = isNight ? const Color(0xFF18314F) : const Color(0xFF75C882);

    // Distant soft rounded hills
    final path = Path();
    path.moveTo(0, groundY);
    path.quadraticBezierTo(70, groundY - 70, 160, groundY);
    path.quadraticBezierTo(250, groundY - 60, 360, groundY);
    path.close();
    canvas.drawPath(path, hillPaint);

    // Tree silouhettes or city buildings
    final bldgPaint = Paint()
      ..color = isNight ? const Color(0xFF112233) : const Color(0xFF5BAA69);
    final buildings = [
      Rect.fromLTWH(20, groundY - 50, 35, 50),
      Rect.fromLTWH(60, groundY - 35, 25, 35),
      Rect.fromLTWH(180, groundY - 45, 40, 45),
      Rect.fromLTWH(230, groundY - 30, 28, 30),
      Rect.fromLTWH(300, groundY - 40, 32, 40),
    ];
    for (final b in buildings) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(3)), bldgPaint);
    }
  }

  void _drawClouds(Canvas canvas) {
    final cloudPaint = Paint()
      ..color = Colors.white.withValues(alpha: isNight ? 0.25 : 0.75);

    final positions = [
      Offset(40 - (cloudOffset % 480), 90),
      Offset(240 - (cloudOffset % 480), 140),
      Offset(440 - (cloudOffset % 480), 75),
    ];

    for (final pos in positions) {
      _drawSingleCloud(canvas, pos.dx, pos.dy, cloudPaint);
      _drawSingleCloud(canvas, pos.dx + 480, pos.dy, cloudPaint);
    }
  }

  void _drawSingleCloud(Canvas canvas, double x, double y, Paint paint) {
    canvas.drawCircle(Offset(x, y), 18, paint);
    canvas.drawCircle(Offset(x + 18, y - 6), 24, paint);
    canvas.drawCircle(Offset(x + 40, y), 18, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x - 4, y + 2, 52, 16), const Radius.circular(8)),
      paint,
    );
  }

  void _drawPipes(Canvas canvas) {
    for (final pipe in pipes) {
      // 1. Top pipe
      _drawSinglePipe(canvas, pipe.x, 0, Pipe.width, pipe.topHeight, isTop: true);

      // 2. Bottom pipe
      final bottomY = pipe.topHeight + Pipe.gap;
      final bottomH = groundY - bottomY;
      _drawSinglePipe(canvas, pipe.x, bottomY, Pipe.width, bottomH, isTop: false);
    }
  }

  void _drawSinglePipe(Canvas canvas, double x, double y, double w, double h, {required bool isTop}) {
    if (h <= 0) return;

    final borderPaint = Paint()
      ..color = const Color(0xFF2C5E1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final bodyFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF539423),
          Color(0xFF76C636),
          Color(0xFF8CE342),
          Color(0xFF67B02A),
          Color(0xFF3F771A),
        ],
        stops: [0.0, 0.22, 0.45, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(x, y, w, h));

    // Cap dimensions
    const capHeight = 24.0;
    const capExt = 4.0;
    final capX = x - capExt;
    final capW = w + capExt * 2;
    final capY = isTop ? (y + h - capHeight) : y;

    // Body rect
    final bodyRect = isTop
        ? Rect.fromLTWH(x, y, w, math.max(0.0, h - capHeight))
        : Rect.fromLTWH(x, y + capHeight, w, math.max(0.0, h - capHeight));

    // Draw main body
    canvas.drawRect(bodyRect, bodyFill);
    canvas.drawRect(bodyRect, borderPaint);

    // Draw Cap
    final capRect = Rect.fromLTWH(capX, capY, capW, capHeight);
    final capFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF539423),
          Color(0xFF76C636),
          Color(0xFF8CE342),
          Color(0xFF67B02A),
          Color(0xFF3F771A),
        ],
        stops: [0.0, 0.22, 0.45, 0.75, 1.0],
      ).createShader(capRect);

    final rCap = RRect.fromRectAndRadius(capRect, const Radius.circular(3.0));
    canvas.drawRRect(rCap, capFill);
    canvas.drawRRect(rCap, borderPaint);

    // Pipe Lip highlight shine
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(x + 10, isTop ? y : y + capHeight),
      Offset(x + 10, isTop ? y + h - capHeight : y + h),
      highlightPaint,
    );
  }

  void _drawBird(Canvas canvas) {
    canvas.save();
    canvas.translate(bird.x, bird.y);
    canvas.rotate(bird.rotation);

    // 1. Shadow beneath bird
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.18);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 16), width: 28, height: 8),
      shadowPaint,
    );

    // 2. Main Bird Body
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: Bird.radiusX * 2, height: Bird.radiusY * 2);
    final bodyPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.3),
        radius: 0.85,
        colors: [
          Color(0xFFFFF176),
          Color(0xFFFBC02D),
          Color(0xFFF57F17),
        ],
      ).createShader(bodyRect);

    final borderPaint = Paint()
      ..color = const Color(0xFF4A3408)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    canvas.drawOval(bodyRect, bodyPaint);
    canvas.drawOval(bodyRect, borderPaint);

    // 3. Belly (Soft white/cream patch)
    final bellyPaint = Paint()..color = const Color(0xFFFFFDE7);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-5, 4), width: 14, height: 12),
      bellyPaint,
    );

    // 4. Rosy Cheek
    final cheekPaint = Paint()..color = const Color(0xFFFF8A80).withValues(alpha: 0.7);
    canvas.drawCircle(const Offset(4, 3), 4.5, cheekPaint);

    // 5. Beak (Upper & Lower)
    final beakPath = Path();
    beakPath.moveTo(9, -2);
    beakPath.lineTo(21, 2);
    beakPath.lineTo(9, 7);
    beakPath.close();

    final beakPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF9100), Color(0xFFFF6D00), Color(0xFFDD2C00)],
      ).createShader(const Rect.fromLTWH(9, -2, 12, 9));
    canvas.drawPath(beakPath, beakPaint);
    canvas.drawPath(beakPath, borderPaint);

    // Mouth line
    canvas.drawLine(const Offset(9, 2.5), const Offset(19, 2.5), borderPaint);

    // 6. Big Eye
    final eyeCenter = const Offset(6, -5);
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(eyeCenter, 6.0, eyePaint);
    canvas.drawCircle(eyeCenter, 6.0, borderPaint);

    // Pupil
    final pupilPaint = Paint()..color = const Color(0xFF1E1E1E);
    canvas.drawCircle(const Offset(7.5, -5), 3.0, pupilPaint);

    // Catchlight highlight
    final catchPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(6.5, -6.5), 1.3, catchPaint);

    // 7. Wing
    _drawWing(canvas, borderPaint);

    canvas.restore();
  }

  void _drawWing(Canvas canvas, Paint borderPaint) {
    final wingPath = Path();
    double wingAngle = 0.0;
    Offset wingAnchor = const Offset(-7, 1);

    if (bird.wingState == 0) {
      wingAngle = -0.4; // Up
    } else if (bird.wingState == 2) {
      wingAngle = 0.35; // Down
    }

    canvas.save();
    canvas.translate(wingAnchor.dx, wingAnchor.dy);
    canvas.rotate(wingAngle);

    final wingRect = const Rect.fromLTWH(-9, -5, 18, 11);
    wingPath.addOval(wingRect);

    final wingPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF9C4), Color(0xFFFBC02D), Color(0xFFE65100)],
      ).createShader(wingRect);

    canvas.drawPath(wingPath, wingPaint);
    canvas.drawPath(wingPath, borderPaint);
    canvas.restore();
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final pPaint = Paint()
        ..color = p.color.withValues(alpha: (p.life / p.maxLife).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);
    }
  }

  void _drawGround(Canvas canvas) {
    final rect = const Rect.fromLTWH(0, groundY, virtualWidth, groundHeight);

    // 1. Earth Base
    final earthPaint = Paint()..color = const Color(0xFFDED895);
    canvas.drawRect(rect, earthPaint);

    // 2. Angled striping
    final stripePaint = Paint()
      ..color = const Color(0xFFD2B468)
      ..strokeWidth = 3.5;

    final normOffset = groundOffset % 24.0;
    for (double x = -24.0 - normOffset; x < virtualWidth + 30.0; x += 16.0) {
      canvas.drawLine(
        Offset(x, groundY + 12),
        Offset(x + 12, groundY + groundHeight),
        stripePaint,
      );
    }

    // 3. Top Lush Grass Border
    final grassBorder = const Rect.fromLTWH(0, groundY, virtualWidth, 12);
    final grassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF73BF2E), Color(0xFF5BAA20)],
      ).createShader(grassBorder);
    canvas.drawRect(grassBorder, grassPaint);

    // 4. Ground top edge stroke
    final edgePaint = Paint()
      ..color = const Color(0xFF33691E)
      ..strokeWidth = 2.5;
    canvas.drawLine(const Offset(0, groundY), const Offset(virtualWidth, groundY), edgePaint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
