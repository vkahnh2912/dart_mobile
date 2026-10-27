import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/entities.dart';

class SpacePainter extends CustomPainter {
  final List<Star> stars;
  final List<Nebula> nebulae;
  final List<SpaceParticle> particles;
  final List<Bullet> bullets;
  final List<PowerUp> powerUps;
  final List<Enemy> enemies;
  final List<FloatingText> floatingTexts;
  final List<WingmanDrone> drones;

  final Offset playerPos;
  final double playerHealth;
  final double maxHealth;
  final double playerShield;
  final double maxShield;
  final int weaponLevel;
  final bool isInvulnerable;
  final bool isOverdrive;

  final double animTime;
  final double screenShake;
  final double flashOpacity;

  SpacePainter({
    required this.stars,
    required this.nebulae,
    required this.particles,
    required this.bullets,
    required this.powerUps,
    required this.enemies,
    required this.floatingTexts,
    required this.drones,
    required this.playerPos,
    required this.playerHealth,
    required this.maxHealth,
    required this.playerShield,
    required this.maxShield,
    required this.weaponLevel,
    required this.isInvulnerable,
    required this.isOverdrive,
    required this.animTime,
    required this.screenShake,
    required this.flashOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // 1. Screen Shake
    if (screenShake > 0.05) {
      final sx = (math.sin(animTime * 50.0) * screenShake * 10.0);
      final sy = (math.cos(animTime * 42.0) * screenShake * 10.0);
      canvas.translate(sx, sy);
    }

    // 2. Cosmic Void Background (Deep space gradient, crisp, pitch-black void)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF020409), Color(0xFF050814), Color(0xFF020409)],
      ).createShader(Rect.fromLTWH(-40, -40, size.width + 80, size.height + 80));
    canvas.drawRect(Rect.fromLTWH(-40, -40, size.width + 80, size.height + 80), bgPaint);

    // 3. Nebulae Clouds (Subtle deep cosmic dust, dịu mắt không bị trắng màn)
    for (final neb in nebulae) {
      final nebPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            neb.color.withValues(alpha: 0.08),
            neb.color.withValues(alpha: 0.03),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(neb.x, neb.y), radius: neb.radius));
      canvas.drawCircle(Offset(neb.x, neb.y), neb.radius, nebPaint);
    }

    // 4. Parallax Starfield
    for (final star in stars) {
      final twinkle = (math.sin(animTime * 6.0 + star.twinkleOffset) * 0.35 + 0.65).clamp(0.2, 1.0);
      final starPaint = Paint()..color = star.color.withValues(alpha: twinkle);
      canvas.drawCircle(Offset(star.x, star.y), star.size, starPaint);
    }

    // 5. Draw Power-Ups
    for (final p in powerUps) {
      _drawPowerUp(canvas, p);
    }

    // 6. Draw Enemies & Bosses
    for (final enemy in enemies) {
      _drawEnemy(canvas, enemy);
    }

    // 7. Draw Bullets & Lasers
    for (final b in bullets) {
      _drawBullet(canvas, b);
    }

    // 8. Draw Wingman Drones
    for (final drone in drones) {
      _drawDrone(canvas, drone);
    }

    // 9. Draw Player Spacecraft
    if (playerHealth > 0) {
      _drawPlayer(canvas);
    }

    // 10. Draw Particle Explosions & Shockwaves
    for (final pt in particles) {
      final alpha = (pt.life / pt.maxLife).clamp(0.0, 1.0);
      if (pt.isShockwave) {
        final shockRadius = pt.size * (1.0 - alpha * 0.5);
        final shockPaint = Paint()
          ..color = pt.color.withValues(alpha: alpha * 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * alpha;
        canvas.drawCircle(Offset(pt.x, pt.y), shockRadius, shockPaint);
      } else {
        final ptPaint = Paint()..color = pt.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(pt.x, pt.y), pt.size * alpha, ptPaint);
      }
    }

    // 11. Draw Floating Popups (+Score / UPGRADE)
    for (final ft in floatingTexts) {
      final textSpan = TextSpan(
        text: ft.text,
        style: TextStyle(
          color: ft.color.withValues(alpha: ft.life.clamp(0.0, 1.0)),
          fontSize: 14 * ft.scale,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          shadows: [
            Shadow(color: ft.color.withValues(alpha: 0.8), blurRadius: 10),
            const Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(ft.x - textPainter.width / 2, ft.y));
    }

    // 12. Soft High-Tech EMP Flash (Hiệu ứng xung điện viền Cyber, không loá trắng hay đục màn hình)
    if (flashOpacity > 0.01) {
      final alpha = (flashOpacity * 0.25).clamp(0.0, 0.35);
      final borderGlow = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 + flashOpacity * 8.0;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderGlow);
    }

    canvas.restore();
  }

  // --- Render Wingman Drone ---
  void _drawDrone(Canvas canvas, WingmanDrone drone) {
    canvas.save();
    canvas.translate(drone.currentPos.dx, drone.currentPos.dy);

    // Glowing Drone Thruster
    final thrusterPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8);
    canvas.drawCircle(const Offset(0, 10), 3.0, thrusterPaint);

    // Drone Body
    final bodyPath = Path()
      ..moveTo(0, -12)
      ..lineTo(8, 2)
      ..lineTo(4, 8)
      ..lineTo(-4, 8)
      ..lineTo(-8, 2)
      ..close();

    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE0F7FA), Color(0xFF00B0FF), Color(0xFF0D47A1)],
      ).createShader(const Rect.fromLTWH(-8, -12, 16, 20));
    canvas.drawPath(bodyPath, bodyPaint);

    // Plasma Cannon Eye
    canvas.drawCircle(const Offset(0, -4), 2.5, Paint()..color = const Color(0xFFFFD600));

    canvas.restore();
  }

  // --- Render Player Fighter ---
  void _drawPlayer(Canvas canvas) {
    canvas.save();
    canvas.translate(playerPos.dx, playerPos.dy);

    // Invulnerability blink
    if (isInvulnerable) {
      final blink = (math.sin(animTime * 28.0) > 0);
      if (blink) {
        canvas.restore();
        return;
      }
    }

    // Overdrive Super Saiyan Aura
    if (isOverdrive) {
      final auraPulse = math.sin(animTime * 15.0) * 0.2 + 0.8;
      final auraPaint = Paint()
        ..color = const Color(0xFFFFD600).withValues(alpha: 0.3 * auraPulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 44.0, auraPaint);

      final auraRing = Paint()
        ..color = const Color(0xFFFF9100).withValues(alpha: 0.7 * auraPulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset.zero, 42.0, auraRing);
    }

    // 1. Dual / Quad Plasma Engine Flames
    final flameLen = 22.0 + math.sin(animTime * 32.0) * 8.0;
    final flameColors = weaponLevel >= 5
        ? [const Color(0xFFFFD600), const Color(0xFFFF3D00), Colors.transparent]
        : (weaponLevel >= 3
            ? [const Color(0xFFE040FB), const Color(0xFF7C4DFF), Colors.transparent]
            : [const Color(0xFF00E5FF), const Color(0xFF2979FF), Colors.transparent]);

    final flamePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: flameColors,
      ).createShader(Rect.fromLTWH(-18, 20, 36, flameLen));

    // Thruster Flames
    canvas.drawOval(Rect.fromCenter(center: const Offset(-11, 24), width: 8, height: flameLen), flamePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(11, 24), width: 8, height: flameLen), flamePaint);
    if (weaponLevel >= 4) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(-19, 20), width: 6, height: flameLen * 0.75), flamePaint);
      canvas.drawOval(Rect.fromCenter(center: const Offset(19, 20), width: 6, height: flameLen * 0.75), flamePaint);
    }

    // 2. Fighter Wings & Hull (Evolves with Weapon Level)
    final hullPath = Path();
    final wingSpan = weaponLevel >= 5 ? 34.0 : (weaponLevel >= 3 ? 30.0 : 26.0);

    hullPath.moveTo(0, -30); // Sharp Nose
    hullPath.lineTo(14, -8);
    hullPath.lineTo(wingSpan, 14); // Right wing tip
    hullPath.lineTo(wingSpan * 0.65, 20);
    hullPath.lineTo(12, 12);
    hullPath.lineTo(9, 24); // Right engine
    hullPath.lineTo(-9, 24); // Left engine
    hullPath.lineTo(-12, 12);
    hullPath.lineTo(-wingSpan * 0.65, 20);
    hullPath.lineTo(-wingSpan, 14); // Left wing tip
    hullPath.lineTo(-14, -8);
    hullPath.close();

    // Hull Color evolves
    final hullColors = weaponLevel >= 5
        ? [const Color(0xFFFFF9C4), const Color(0xFFFFD54F), const Color(0xFFFF8F00), const Color(0xFF37474F)]
        : (weaponLevel >= 3
            ? [const Color(0xFFE1F5FE), const Color(0xFF80DEEA), const Color(0xFF0097A7), const Color(0xFF263238)]
            : [const Color(0xFFECEFF1), const Color(0xFFB0BEC5), const Color(0xFF607D8B), const Color(0xFF263238)]);

    final hullPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: hullColors,
      ).createShader(Rect.fromLTWH(-wingSpan, -30, wingSpan * 2, 54));
    canvas.drawPath(hullPath, hullPaint);

    // Neon Cyber Wing Accents
    final neonColor = weaponLevel >= 5 ? const Color(0xFFFFD600) : (weaponLevel >= 3 ? const Color(0xFFE040FB) : const Color(0xFF00E5FF));
    final neonPaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(-wingSpan * 0.85, 12), const Offset(-10, -5), neonPaint);
    canvas.drawLine(Offset(wingSpan * 0.85, 12), const Offset(10, -5), neonPaint);

    // Glowing Cockpit Glass
    final cockpitPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFF80D8FF), Color(0xFF0091EA)],
      ).createShader(const Rect.fromLTWH(-5, -17, 10, 20));
    canvas.drawOval(const Rect.fromLTWH(-5, -17, 10, 20), cockpitPaint);

    // 3. Energy Shield Bubble
    if (playerShield > 0) {
      final shieldPulse = math.sin(animTime * 6.0) * 0.15 + 0.85;
      final shieldPaint = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.22 * shieldPulse)
        ..style = PaintingStyle.fill;
      final shieldBorder = Paint()
        ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85 * shieldPulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(Offset.zero, 36.0, shieldPaint);
      canvas.drawCircle(Offset.zero, 36.0, shieldBorder);
    }

    canvas.restore();
  }

  // --- Render Enemies & 10 Bosses ---
  void _drawEnemy(Canvas canvas, Enemy e) {
    canvas.save();
    canvas.translate(e.x, e.y);

    switch (e.type) {
      case EnemyType.scout:
        // Crimson Dart Scout
        final p = Path()
          ..moveTo(0, 16)
          ..lineTo(14, -12)
          ..lineTo(0, -6)
          ..lineTo(-14, -12)
          ..close();
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF1744), Color(0xFFB71C1C)],
          ).createShader(const Rect.fromLTWH(-14, -12, 28, 28));
        canvas.drawPath(p, paint);
        canvas.drawCircle(const Offset(0, 2), 3, Paint()..color = const Color(0xFFFFEB3B));
        break;

      case EnemyType.interceptor:
        // Violet Heavy Interceptor
        final p = Path()
          ..moveTo(0, 22)
          ..lineTo(20, -10)
          ..lineTo(8, -16)
          ..lineTo(0, -8)
          ..lineTo(-8, -16)
          ..lineTo(-20, -10)
          ..close();
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFE040FB), Color(0xFF4A148C)],
          ).createShader(const Rect.fromLTWH(-20, -16, 40, 38));
        canvas.drawPath(p, paint);
        canvas.drawRect(const Rect.fromLTWH(-16, 0, 4, 12), Paint()..color = const Color(0xFFFF5252));
        canvas.drawRect(const Rect.fromLTWH(12, 0, 4, 12), Paint()..color = const Color(0xFFFF5252));
        break;

      case EnemyType.heavyCruiser:
        // Armored Emerald Cruiser
        final p = Path()
          ..moveTo(0, 30)
          ..lineTo(28, 10)
          ..lineTo(32, -22)
          ..lineTo(-32, -22)
          ..lineTo(-28, 10)
          ..close();
        final paint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFF00E676), Color(0xFF1B5E20)],
          ).createShader(const Rect.fromLTWH(-32, -22, 64, 52));
        canvas.drawPath(p, paint);
        canvas.drawCircle(const Offset(0, 4), 8, Paint()..color = const Color(0xFF76FF03));
        break;

      case EnemyType.boss:
        _drawBoss(canvas, e);
        break;
    }

    // Health Bar for Heavy Cruiser & Boss
    if (e.type == EnemyType.heavyCruiser || e.type == EnemyType.boss) {
      final barWidth = e.type == EnemyType.boss ? 180.0 : 44.0;
      final barY = -(e.height / 2.0) - (e.type == EnemyType.boss ? 26.0 : 14.0);
      final hpRatio = (e.health / e.maxHealth).clamp(0.0, 1.0);

      // Background Frame
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth, e.type == EnemyType.boss ? 8 : 6), const Radius.circular(4)),
        Paint()..color = Colors.black87,
      );
      // Health fill gradient
      final hpColor = hpRatio > 0.45 ? const Color(0xFF00E676) : (hpRatio > 0.2 ? const Color(0xFFFFD600) : const Color(0xFFFF1744));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth * hpRatio, e.type == EnemyType.boss ? 8 : 6), const Radius.circular(4)),
        Paint()..color = hpColor,
      );
      // Bar Border
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth, e.type == EnemyType.boss ? 8 : 6), const Radius.circular(4)),
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      if (e.type == EnemyType.boss && e.bossConfig != null) {
        // Boss Title with Difficulty Tag
        final cfg = e.bossConfig!;
        final diffColor = cfg.level >= 10
            ? const Color(0xFFFF0055)
            : (cfg.level >= 8 ? const Color(0xFFFF1744) : const Color(0xFFFFD600));

        final bossSpan = TextSpan(
          children: [
            TextSpan(
              text: 'LV.${cfg.level} ${cfg.name} ',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
            ),
            TextSpan(
              text: '[${cfg.difficultyTag}]',
              style: TextStyle(color: diffColor, fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ],
        );
        final tp = TextPainter(text: bossSpan, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(-tp.width / 2, barY - 16));
      }
    }

    canvas.restore();
  }

  // --- Draw Dynamic Boss Based on BossConfig ---
  void _drawBoss(Canvas canvas, Enemy e) {
    final cfg = e.bossConfig ?? BossConfig.allBosses[0];
    final hw = e.width / 2.0;
    final hh = e.height / 2.0;

    // Boss Menacing Aura for Level 8 (Cấp 8 Bá Đạo Nhất Vũ Trụ)
    if (cfg.level >= 8) {
      final auraPulse = math.sin(animTime * 12.0) * 10.0;
      final auraPaint = Paint()
        ..color = const Color(0xFFFF0055).withValues(alpha: 0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, hw * 1.05 + auraPulse, auraPaint);

      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset.zero, hw * 1.15 + auraPulse, ringPaint);
    } else if (cfg.level >= 5) {
      final auraPulse = math.sin(animTime * 8.0) * 5.0;
      final auraPaint = Paint()
        ..color = cfg.primaryColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, hw * 0.95 + auraPulse, auraPaint);
    }

    // Boss Main Hull Silhouette
    final p = Path()
      ..moveTo(0, hh * 1.05) // Main Bow / Ramming beak
      ..lineTo(hw * 0.40, hh * 0.55)
      ..lineTo(hw * 0.90, hh * 0.25)
      ..lineTo(hw, -hh * 0.65) // Wing tip
      ..lineTo(hw * 0.55, -hh * 0.90)
      ..lineTo(hw * 0.25, -hh * 0.60)
      ..lineTo(0, -hh * 0.85) // Engine center
      ..lineTo(-hw * 0.25, -hh * 0.60)
      ..lineTo(-hw * 0.55, -hh * 0.90)
      ..lineTo(-hw, -hh * 0.65)
      ..lineTo(-hw * 0.90, hh * 0.25)
      ..lineTo(-hw * 0.40, hh * 0.55)
      ..close();

    final bossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [cfg.secondaryColor, const Color(0xFF1E272E), cfg.primaryColor],
      ).createShader(Rect.fromLTWH(-hw, -hh, e.width, e.height));
    canvas.drawPath(p, bossPaint);

    // Glowing Neon Armor Lines
    final linePaint = Paint()
      ..color = cfg.coreColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawLine(Offset(-hw * 0.75, 0), Offset(-hw * 0.20, hh * 0.35), linePaint);
    canvas.drawLine(Offset(hw * 0.75, 0), Offset(hw * 0.20, hh * 0.35), linePaint);

    // Reactor Core (Pulses with Cosmic Energy)
    final pulse = math.sin(animTime * 8.0) * 4.0;
    final coreRadius = (16.0 + (cfg.level * 1.5) + pulse).clamp(12.0, 32.0);
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, cfg.coreColor, Colors.transparent],
      ).createShader(Rect.fromCircle(center: const Offset(0, 8), radius: coreRadius));
    canvas.drawCircle(const Offset(0, 8), coreRadius, corePaint);

    // Heavy Wing Cannons
    final cannonPaint = Paint()..color = const Color(0xFFFFD600);
    canvas.drawRect(Rect.fromLTWH(-hw * 0.75, hh * 0.1, 7, 22), cannonPaint);
    canvas.drawRect(Rect.fromLTWH(hw * 0.75 - 7, hh * 0.1, 7, 22), cannonPaint);

    if (cfg.level >= 5) {
      canvas.drawRect(Rect.fromLTWH(-hw * 0.35, hh * 0.3, 6, 20), Paint()..color = cfg.primaryColor);
      canvas.drawRect(Rect.fromLTWH(hw * 0.35 - 6, hh * 0.3, 6, 20), Paint()..color = cfg.primaryColor);
    }
  }

  // --- Render Bullets ---
  void _drawBullet(Canvas canvas, Bullet b) {
    if (b.isLaser) {
      // Plasma Laser Beam
      final laserPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFF00E5FF), Color(0xFF00B0FF)],
        ).createShader(Rect.fromLTWH(b.x - 7, b.y - 32, 14, 44));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(b.x - 6, b.y - 28, 12, 40), const Radius.circular(6)),
        laserPaint,
      );
    } else if (b.isMissile) {
      // Homing Missile
      canvas.save();
      canvas.translate(b.x, b.y);
      canvas.rotate(b.missileAngle);

      final missilePath = Path()
        ..moveTo(12, 0)
        ..lineTo(-8, 5)
        ..lineTo(-5, 0)
        ..lineTo(-8, -5)
        ..close();
      canvas.drawPath(missilePath, Paint()..color = const Color(0xFFFF9100));

      // Missile flame
      canvas.drawCircle(const Offset(-8, 0), 3.5, Paint()..color = const Color(0xFFFF1744));
      canvas.restore();
    } else {
      // Standard Plasma Orb
      final bulletPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, b.color, Colors.transparent],
        ).createShader(Rect.fromCircle(center: Offset(b.x, b.y), radius: b.radius * 1.8));

      canvas.drawCircle(Offset(b.x, b.y), b.radius * 1.5, bulletPaint);
      canvas.drawCircle(Offset(b.x, b.y), b.radius * 0.65, Paint()..color = Colors.white);
    }
  }

  // --- Render Power-Up Orbs ---
  void _drawPowerUp(Canvas canvas, PowerUp p) {
    canvas.save();
    canvas.translate(p.x, p.y);

    Color pColor;
    IconData pIcon;
    switch (p.type) {
      case PowerUpType.heal:
        pColor = const Color(0xFF00E676);
        pIcon = Icons.favorite;
        break;
      case PowerUpType.shield:
        pColor = const Color(0xFF00E5FF);
        pIcon = Icons.shield;
        break;
      case PowerUpType.weapon:
        pColor = const Color(0xFFFFD600);
        pIcon = Icons.bolt;
        break;
      case PowerUpType.nuke:
        pColor = const Color(0xFFFF1744);
        pIcon = Icons.local_fire_department;
        break;
      case PowerUpType.drone:
        pColor = const Color(0xFFE040FB);
        pIcon = Icons.support;
        break;
      case PowerUpType.overdrive:
        pColor = const Color(0xFFFF9100);
        pIcon = Icons.flash_on;
        break;
    }

    // Outer Pulse Ring
    final pulse = math.sin(p.anim) * 3.0;
    final haloPaint = Paint()
      ..color = pColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 18 + pulse, haloPaint);

    final borderPaint = Paint()
      ..color = pColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, 15, borderPaint);

    // Inner Core
    canvas.drawCircle(Offset.zero, 12, Paint()..color = const Color(0xFF10192D));

    // Icon Inside
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(pIcon.codePoint),
        style: TextStyle(
          fontFamily: pIcon.fontFamily,
          package: pIcon.fontPackage,
          fontSize: 16,
          color: pColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => true;
}