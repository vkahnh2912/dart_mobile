import 'dart:math' as math;
import 'dart:ui' as ui;
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
  final ui.Image? monsterSprite;

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
    this.monsterSprite,
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

    // 2. Deep Pitch-Black Cosmic Void (Chuẩn nền đen sâu thẳm như Hình 2, tuyệt đối không bao giờ bị trắng/xám màn hình)
    final bgRect = Rect.fromLTWH(-120, -120, size.width + 240, size.height + 240);
    canvas.drawRect(bgRect, Paint()..color = const Color(0xFF03030A));

    // 3. Concentric Dark Cosmic Planets / Nebulae (Giống Hình 2)
    for (final neb in nebulae) {
      final center = Offset(neb.x, neb.y);
      canvas.drawCircle(
        center,
        neb.radius,
        Paint()..color = neb.color.withValues(alpha: 0.14),
      );
      canvas.drawCircle(
        center,
        neb.radius * 0.80,
        Paint()..color = neb.color.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        center,
        neb.radius * 0.58,
        Paint()..color = neb.color.withValues(alpha: 0.14),
      );
    }

    // 4. Parallax Starfield (Hạt sao lung linh trắng, tím, xanh cyan, vàng như Hình 2)
    for (final star in stars) {
      final twinkle = (math.sin(animTime * 6.0 + star.twinkleOffset) * 0.35 + 0.65).clamp(0.25, 1.0);
      final pos = Offset(star.x, star.y);
      if (star.size > 2.0) {
        canvas.drawCircle(
          pos,
          star.size * 2.1,
          Paint()..color = star.color.withValues(alpha: twinkle * 0.28),
        );
      }
      canvas.drawCircle(
        pos,
        star.size,
        Paint()..color = star.color.withValues(alpha: twinkle),
      );
    }

    // 5. Draw Power-Ups
    for (final p in powerUps) {
      _drawPowerUp(canvas, p);
    }

    // 6. Draw Enemies & Bosses
    for (final enemy in enemies) {
      _drawEnemy(canvas, enemy);
    }

    // 7. Draw Bullets & Crystal Shards
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

    // 10. Draw Particle Explosions, Crystal Shards & Starbursts (Chuẩn Hình 3: Die Animation & Explosion Effect)
    for (final pt in particles) {
      final alpha = (pt.life / pt.maxLife).clamp(0.0, 1.0);
      if (pt.isStarburst) {
        _drawExplosionStarburst(canvas, Offset(pt.x, pt.y), pt.size * (1.15 - alpha * 0.35), alpha, pt.color);
      } else if (pt.isShockwave) {
        final shockRadius = pt.size * (1.0 - alpha * 0.55);
        final shockPaint = Paint()
          ..color = pt.color.withValues(alpha: alpha * 0.80)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5 * alpha
          ..strokeCap = StrokeCap.round;
        // Vòng xung kích năng lượng tím phân mảnh như Hình 3
        for (int a = 0; a < 8; a++) {
          final startAngle = a * (math.pi / 4.0) + (1.0 - alpha) * 1.2;
          canvas.drawArc(
            Rect.fromCircle(center: Offset(pt.x, pt.y), radius: shockRadius),
            startAngle,
            math.pi / 6.0,
            false,
            shockPaint,
          );
        }
      } else if (pt.isCrystalShard) {
        canvas.save();
        canvas.translate(pt.x, pt.y);
        canvas.rotate(pt.rotation);
        final s = pt.size * (0.4 + alpha * 0.6);
        final shardPath = Path()
          ..moveTo(0, -s * 1.3)
          ..lineTo(s * 0.75, -s * 0.1)
          ..lineTo(s * 0.3, s * 1.1)
          ..lineTo(-s * 0.65, s * 0.5)
          ..close();
        canvas.drawPath(shardPath, Paint()..color = pt.color.withValues(alpha: alpha));
        canvas.drawPath(
          shardPath,
          Paint()
            ..color = const Color(0xFFEA80FC).withValues(alpha: alpha * 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0,
        );
        canvas.restore();
      } else {
        // Hạt tia lửa & sao 4 cánh tím/hồng (Explosion sparkles Hình 3)
        final ptPaint = Paint()..color = pt.color.withValues(alpha: alpha);
        canvas.drawCircle(Offset(pt.x, pt.y), pt.size * alpha, ptPaint);
        if (pt.size > 3.2) {
          final sparkLen = pt.size * 1.8 * alpha;
          final sparkPaint = Paint()
            ..color = Colors.white.withValues(alpha: alpha * 0.85)
            ..strokeWidth = 1.2;
          canvas.drawLine(Offset(pt.x - sparkLen, pt.y), Offset(pt.x + sparkLen, pt.y), sparkPaint);
          canvas.drawLine(Offset(pt.x, pt.y - sparkLen), Offset(pt.x, pt.y + sparkLen), sparkPaint);
        }
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

    canvas.restore();
  }

  // --- Hiệu ứng nổ lõi Sao Băng Tím Hồng (Explosion Effect trong Hình 3) ---
  void _drawExplosionStarburst(Canvas canvas, Offset center, double radius, double alpha, Color baseColor) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Hào quang tím hồng lan tỏa
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: alpha),
          const Color(0xFFFF4081).withValues(alpha: alpha * 0.85),
          baseColor.withValues(alpha: alpha * 0.55),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius * 1.35));
    canvas.drawCircle(Offset.zero, radius * 1.35, glowPaint);

    // Ngôi sao nổ 12 cánh sắc nhọn (Starburst)
    final starPath = Path();
    const int spikes = 12;
    for (int i = 0; i < spikes * 2; i++) {
      final r = (i.isEven) ? radius : radius * 0.36;
      final angle = (i * math.pi / spikes) + (1.0 - alpha) * 0.5;
      final px = math.cos(angle) * r;
      final py = math.sin(angle) * r;
      if (i == 0) {
        starPath.moveTo(px, py);
      } else {
        starPath.lineTo(px, py);
      }
    }
    starPath.close();

    canvas.drawPath(
      starPath,
      Paint()..color = const Color(0xFFFF80AB).withValues(alpha: alpha * 0.9),
    );
    canvas.scale(0.62, 0.62);
    canvas.drawPath(
      starPath,
      Paint()..color = Colors.white.withValues(alpha: alpha),
    );

    canvas.restore();
  }

  // --- Render Wingman Drone ---
  void _drawDrone(Canvas canvas, WingmanDrone drone) {
    canvas.save();
    canvas.translate(drone.currentPos.dx, drone.currentPos.dy);

    final thrusterPaint = Paint()..color = const Color(0xFF00E5FF).withValues(alpha: 0.8);
    canvas.drawCircle(const Offset(0, 10), 3.0, thrusterPaint);

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

    canvas.drawCircle(const Offset(0, -4), 2.5, Paint()..color = const Color(0xFFFFD600));

    canvas.restore();
  }

  // --- Render Player Fighter ---
  void _drawPlayer(Canvas canvas) {
    canvas.save();
    canvas.translate(playerPos.dx, playerPos.dy);

    if (isInvulnerable) {
      final blink = (math.sin(animTime * 28.0) > 0);
      if (blink) {
        canvas.restore();
        return;
      }
    }

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

    canvas.drawOval(Rect.fromCenter(center: const Offset(-11, 24), width: 8, height: flameLen), flamePaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(11, 24), width: 8, height: flameLen), flamePaint);
    if (weaponLevel >= 4) {
      canvas.drawOval(Rect.fromCenter(center: const Offset(-19, 20), width: 6, height: flameLen * 0.75), flamePaint);
      canvas.drawOval(Rect.fromCenter(center: const Offset(19, 20), width: 6, height: flameLen * 0.75), flamePaint);
    }

    final hullPath = Path();
    final wingSpan = weaponLevel >= 5 ? 34.0 : (weaponLevel >= 3 ? 30.0 : 26.0);

    hullPath.moveTo(0, -30);
    hullPath.lineTo(14, -8);
    hullPath.lineTo(wingSpan, 14);
    hullPath.lineTo(wingSpan * 0.65, 20);
    hullPath.lineTo(12, 12);
    hullPath.lineTo(9, 24);
    hullPath.lineTo(-9, 24);
    hullPath.lineTo(-12, 12);
    hullPath.lineTo(-wingSpan * 0.65, 20);
    hullPath.lineTo(-wingSpan, 14);
    hullPath.lineTo(-14, -8);
    hullPath.close();

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

    final neonColor = weaponLevel >= 5 ? const Color(0xFFFFD600) : (weaponLevel >= 3 ? const Color(0xFFE040FB) : const Color(0xFF00E5FF));
    final neonPaint = Paint()
      ..color = neonColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(-wingSpan * 0.85, 12), const Offset(-10, -5), neonPaint);
    canvas.drawLine(Offset(wingSpan * 0.85, 12), const Offset(10, -5), neonPaint);

    final cockpitPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFFFFF), Color(0xFF80D8FF), Color(0xFF0091EA)],
      ).createShader(const Rect.fromLTWH(-5, -17, 10, 20));
    canvas.drawOval(const Rect.fromLTWH(-5, -17, 10, 20), cockpitPaint);

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

  // --- Render Enemies & Bosses (Giao diện Quái Tinh Thể Độc Nhãn Tím chuẩn Hình 2 & Hình 3) ---
  void _drawEnemy(Canvas canvas, Enemy e) {
    canvas.save();
    canvas.translate(e.x, e.y);

    if (e.type == EnemyType.boss) {
      _drawBoss(canvas, e);
    } else {
      // Quy mô của từng cấp quái tinh thể (Scout -> Interceptor -> Heavy Cruiser)
      final double scale = e.type == EnemyType.heavyCruiser
          ? 1.32
          : (e.type == EnemyType.interceptor ? 1.05 : 0.88);
      _drawCrystalCyclopsMonster(canvas, e, scale);
    }

    // Thanh máu đỏ bo góc phía trên đầu quái (Giống hệt Hình 2)
    if (e.type == EnemyType.boss) {
      final barWidth = 180.0;
      final barY = -(e.height / 2.0) - 26.0;
      final hpRatio = (e.health / e.maxHealth).clamp(0.0, 1.0);

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth, 8), const Radius.circular(4)),
        Paint()..color = Colors.black87,
      );
      final hpColor = hpRatio > 0.45 ? const Color(0xFFFF1744) : (hpRatio > 0.2 ? const Color(0xFFFF9100) : const Color(0xFFFF0055));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth * hpRatio, 8), const Radius.circular(4)),
        Paint()..color = hpColor,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-barWidth / 2, barY, barWidth, 8), const Radius.circular(4)),
        Paint()
          ..color = const Color(0xFFFF5252).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      if (e.bossConfig != null) {
        final cfg = e.bossConfig!;
        final diffColor = cfg.level >= 8 ? const Color(0xFFFF1744) : const Color(0xFFFFD600);
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
    } else {
      // Thanh máu đỏ viền mảnh phía trên đầu Quái Tinh Thể (Chuẩn Hình 2)
      final double scale = e.type == EnemyType.heavyCruiser
          ? 1.32
          : (e.type == EnemyType.interceptor ? 1.05 : 0.88);
      final barWidth = 44.0 * scale;
      final barHeight = 5.2;
      final barY = -36.0 * scale;
      final hpRatio = (e.health / e.maxHealth).clamp(0.0, 1.0);

      final bgRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(bgRRect, Paint()..color = const Color(0xFF1A081F).withValues(alpha: 0.9));

      final fillRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-barWidth / 2, barY, barWidth * hpRatio, barHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(
        fillRRect,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF1744), Color(0xFFFF5252)],
          ).createShader(Rect.fromLTWH(-barWidth / 2, barY, barWidth, barHeight)),
      );

      canvas.drawRRect(
        bgRRect,
        Paint()
          ..color = const Color(0xFFFF1744).withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );
    }

    canvas.restore();
  }

  // ===========================================================================
  // QUÁI VẬT TINH THỂ ĐỘC NHÃN TÍM (CRYSTAL CYCLOPS MONSTER - CHUẨN HÌNH 2 & 3)
  // Bao gồm:
  // - Vòng khóa mục tiêu đỏ phân đoạn (Hình 2)
  // - Idle Animation (Nhấp nháy mắt độc nhãn & tinh thể)
  // - Move Animation (Bay kèm vệt năng lượng & sao lấp lánh tím hồng)
  // - Shoot Animation (4 tinh thể đỏ phía dưới phát sáng khi bắn đạn kim cương)
  // - Hit Animation (Chớp sáng sao 8 cánh hồng trắng + vết nứt tinh thể khi trúng đạn)
  // ===========================================================================
  void _drawCrystalCyclopsMonster(Canvas canvas, Enemy e, double scale) {
    canvas.save();

    // Hiệu ứng nhấp nhô nhẹ khi bay (Idle & Move Animation)
    final hoverY = math.sin(animTime * 7.5 + e.initialX * 0.05) * 2.5;
    canvas.translate(0, hoverY);
    canvas.scale(scale, scale);

    const double s = 30.0; // Base unit radius

    // 1. Vòng năng lượng đỏ phân đoạn bao quanh quái (Giống hệt Hình 2)
    final ringRadius = s * 1.15;
    final auraGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF1744).withValues(alpha: 0.16),
          const Color(0xFF7C4DFF).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: ringRadius * 1.25));
    canvas.drawCircle(Offset.zero, ringRadius * 1.25, auraGlow);

    final arcPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final rot = animTime * 0.8;
    for (int i = 0; i < 4; i++) {
      final startA = rot + i * (math.pi / 2.0) + 0.22;
      canvas.drawArc(
        Rect.fromCircle(center: const Offset(0, 2), radius: ringRadius),
        startA,
        math.pi / 2.0 - 0.44,
        false,
        arcPaint,
      );
    }

    // 2. Move Animation (Bay): Đuôi năng lượng tím hồng & hạt sao 4 cánh lấp lánh dưới 4 tinh thể đỏ
    final shootFlare = e.shootAnimTimer > 0 ? (1.0 + e.shootAnimTimer * 1.6) : 1.0;
    final shardOffsets = <Offset>[
      Offset(-s * 0.54, s * 0.58 + math.sin(animTime * 9.0) * 3.0),
      Offset(-s * 0.19, s * 0.72 + math.cos(animTime * 9.0 + 1.2) * 3.5),
      Offset(s * 0.19, s * 0.72 + math.sin(animTime * 9.0 + 2.4) * 3.5),
      Offset(s * 0.54, s * 0.58 + math.cos(animTime * 9.0 + 3.6) * 3.0),
    ];

    for (int i = 0; i < shardOffsets.length; i++) {
      final so = shardOffsets[i];
      final tilt = (i - 1.5) * 0.18;

      // Vệt lửa năng lượng tím hồng phía dưới mỗi tinh thể (Move Animation Hình 3)
      final trailLen = 14.0 + math.sin(animTime * 18.0 + i * 1.7) * 5.0;
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF4081).withValues(alpha: 0.65),
            const Color(0xFFAA00FF).withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(so.dx - 4, so.dy, 8, trailLen));
      canvas.drawOval(Rect.fromCenter(center: Offset(so.dx, so.dy + trailLen * 0.45), width: 6, height: trailLen), trailPaint);

      // Hạt sao 4 cánh nhỏ lấp lánh phía dưới (Move Animation Hình 3)
      final sparkY = so.dy + 10.0 + ((animTime * 28.0 + i * 7.0) % 14.0);
      final sparkAlpha = (1.0 - ((sparkY - so.dy - 10.0) / 14.0)).clamp(0.0, 1.0);
      _drawTinyFourPointStar(canvas, Offset(so.dx, sparkY), 2.8 * sparkAlpha, const Color(0xFFEA80FC).withValues(alpha: sparkAlpha));

      if (monsterSprite == null) {
        // Vẽ từng viên Tinh Thể Kim Cương Đỏ lơ lửng phía dưới khi chưa dùng ảnh sprite
        _drawRedCrystalShard(canvas, so, 5.2 * shootFlare, 10.5 * shootFlare, tilt);
      }
    }

    // Nếu có ảnh sprite từ SQLite (assets/images/purple_demon.png hoặc ảnh tự chọn), vẽ trực tiếp ảnh đó!
    if (monsterSprite != null) {
      final img = monsterSprite!;
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromCenter(center: const Offset(0, 2), width: s * 2.15, height: s * 1.95);
      canvas.drawImageRect(
        img,
        srcRect,
        dstRect,
        Paint()..filterQuality = FilterQuality.medium,
      );

      if (e.hitFlashTimer > 0) {
        final hitAlpha = (e.hitFlashTimer / 0.18).clamp(0.0, 1.0);
        _drawExplosionStarburst(canvas, const Offset(s * 0.06, s * 0.02), s * 0.52, hitAlpha, const Color(0xFFFF1744));
      }
      canvas.restore();
      return;
    }

    // 2 chân tinh thể đỏ gắn sát dưới hai bên cánh
    _drawRedCrystalShard(canvas, const Offset(-s * 0.44, s * 0.24), 4.8, 9.5, 0.12);
    _drawRedCrystalShard(canvas, const Offset(s * 0.44, s * 0.24), 4.8, 9.5, -0.12);

    // 3. Đôi Cánh Tinh Thể Tím & Hồng Phát Sáng Hai Bên (Left & Right Faceted Crystal Wings)
    // Cánh trái (Left Wing)
    final leftWingPath = Path()
      ..moveTo(-s * 0.22, -s * 0.28)
      ..lineTo(-s * 0.48, -s * 0.44) // Đỉnh vai tinh thể trái
      ..lineTo(-s * 0.92, -s * 0.02) // Mũi cánh nhọn bên trái
      ..lineTo(-s * 0.56, s * 0.14)
      ..lineTo(-s * 0.20, s * 0.12)
      ..close();
    canvas.drawPath(
      leftWingPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9575CD), Color(0xFF5E35B1), Color(0xFF311B92)],
        ).createShader(const Rect.fromLTWH(-s, -s * 0.5, s * 0.8, s * 0.7)),
    );

    // Mặt cắt tinh thể hồng rực trên cánh trái (Pink glowing crystal facet - Hình 2 & 3)
    final leftPinkFacet = Path()
      ..moveTo(-s * 0.48, -s * 0.36)
      ..lineTo(-s * 0.86, -s * 0.03)
      ..lineTo(-s * 0.54, s * 0.08)
      ..lineTo(-s * 0.40, -s * 0.14)
      ..close();
    canvas.drawPath(
      leftPinkFacet,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF1744), Color(0xFFAA00FF)],
        ).createShader(const Rect.fromLTWH(-s * 0.9, -s * 0.4, s * 0.5, s * 0.5)),
    );
    // Lõi trắng hồng lấp lánh trên cánh trái
    final leftHighlight = Path()
      ..moveTo(-s * 0.54, -s * 0.24)
      ..lineTo(-s * 0.76, -s * 0.04)
      ..lineTo(-s * 0.54, 0.0)
      ..close();
    canvas.drawPath(leftHighlight, Paint()..color = Colors.white.withValues(alpha: 0.75));

    // Cánh phải (Right Wing)
    final rightWingPath = Path()
      ..moveTo(s * 0.22, -s * 0.28)
      ..lineTo(s * 0.48, -s * 0.44) // Đỉnh vai tinh thể phải
      ..lineTo(s * 0.92, -s * 0.02) // Mũi cánh nhọn bên phải
      ..lineTo(s * 0.56, s * 0.14)
      ..lineTo(s * 0.20, s * 0.12)
      ..close();
    canvas.drawPath(
      rightWingPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF7E57C2), Color(0xFF4527A0), Color(0xFF1A093B)],
        ).createShader(const Rect.fromLTWH(s * 0.2, -s * 0.5, s * 0.8, s * 0.7)),
    );

    // Mặt cắt tinh thể hồng rực trên cánh phải
    final rightPinkFacet = Path()
      ..moveTo(s * 0.48, -s * 0.36)
      ..lineTo(s * 0.86, -s * 0.03)
      ..lineTo(s * 0.54, s * 0.08)
      ..lineTo(s * 0.40, -s * 0.14)
      ..close();
    canvas.drawPath(
      rightPinkFacet,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF1744), Color(0xFFAA00FF)],
        ).createShader(const Rect.fromLTWH(s * 0.4, -s * 0.4, s * 0.5, s * 0.5)),
    );
    final rightHighlight = Path()
      ..moveTo(s * 0.54, -s * 0.24)
      ..lineTo(s * 0.76, -s * 0.04)
      ..lineTo(s * 0.54, 0.0)
      ..close();
    canvas.drawPath(rightHighlight, Paint()..color = Colors.white.withValues(alpha: 0.75));

    // Đốm năng lượng xanh cyan nhỏ trên khớp cánh (Chi tiết chuẩn trong Hình 3)
    canvas.drawCircle(const Offset(-s * 0.36, -s * 0.08), 1.8, Paint()..color = const Color(0xFF00E5FF));
    canvas.drawCircle(const Offset(s * 0.36, -s * 0.08), 1.8, Paint()..color = const Color(0xFF00E5FF));

    // 4. Thân Chính Tinh Thể Kim Cương Tím Đa Diện (Central Faceted Amethyst Spire)
    // Nửa mặt cắt trái trên (Sáng hơn)
    final topLeftFacet = Path()
      ..moveTo(0, -s * 0.74) // Đỉnh chóp nhọn cao nhất
      ..lineTo(-s * 0.36, -s * 0.12)
      ..lineTo(0, -s * 0.05)
      ..close();
    canvas.drawPath(
      topLeftFacet,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB388FF), Color(0xFF7C4DFF), Color(0xFF5E35B1)],
        ).createShader(const Rect.fromLTWH(-s * 0.4, -s * 0.75, s * 0.4, s * 0.7)),
    );

    // Nửa mặt cắt phải trên (Đậm hơn tạo khối 3D)
    final topRightFacet = Path()
      ..moveTo(0, -s * 0.74)
      ..lineTo(s * 0.36, -s * 0.12)
      ..lineTo(0, -s * 0.05)
      ..close();
    canvas.drawPath(
      topRightFacet,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9575CD), Color(0xFF512DA8), Color(0xFF311B92)],
        ).createShader(const Rect.fromLTWH(0, -s * 0.75, s * 0.4, s * 0.7)),
    );

    // Phần hàm dưới tinh thể (Lower Jaw Facet)
    final lowerJawPath = Path()
      ..moveTo(-s * 0.36, -s * 0.12)
      ..lineTo(0, -s * 0.05)
      ..lineTo(s * 0.36, -s * 0.12)
      ..lineTo(s * 0.22, s * 0.22)
      ..lineTo(0, s * 0.46) // Mũi cằm nhọn
      ..lineTo(-s * 0.22, s * 0.22)
      ..close();
    canvas.drawPath(
      lowerJawPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5E35B1), Color(0xFF4527A0), Color(0xFF240B4C)],
        ).createShader(const Rect.fromLTWH(-s * 0.4, -s * 0.15, s * 0.8, s * 0.65)),
    );

    // Viền cạnh tinh thể sắc nét (Faceted Gem Edges)
    final edgePaint = Paint()
      ..color = const Color(0xFFD1C4E9).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawLine(const Offset(0, -s * 0.74), const Offset(0, -s * 0.16), edgePaint);
    canvas.drawLine(const Offset(0, -s * 0.74), const Offset(-s * 0.36, -s * 0.12), edgePaint);
    canvas.drawLine(const Offset(0, -s * 0.74), const Offset(s * 0.36, -s * 0.12), edgePaint);

    // 5. Miệng Quái Tinh Thể Đỏ & 2 Răng Nanh Trắng Nhọn (Mouth, Fangs & Chin Gem - Hình 2 & 3)
    final chinGemPath = Path()
      ..moveTo(0, s * 0.16)
      ..lineTo(s * 0.12, s * 0.28)
      ..lineTo(0, s * 0.45)
      ..lineTo(-s * 0.12, s * 0.28)
      ..close();
    canvas.drawPath(
      chinGemPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF80AB), Color(0xFFFF1744), Color(0xFFB71C1C)],
        ).createShader(const Rect.fromLTWH(-s * 0.15, s * 0.15, s * 0.3, s * 0.3)),
    );

    // Hai chiếc răng nanh trắng nhỏ sắc nhọn (2 white fangs - Hình 2 & 3)
    final leftFang = Path()
      ..moveTo(-s * 0.11, s * 0.14)
      ..lineTo(-s * 0.04, s * 0.17)
      ..lineTo(-s * 0.08, s * 0.25)
      ..close();
    final rightFang = Path()
      ..moveTo(s * 0.11, s * 0.14)
      ..lineTo(s * 0.04, s * 0.17)
      ..lineTo(s * 0.08, s * 0.25)
      ..close();
    canvas.drawPath(leftFang, Paint()..color = Colors.white);
    canvas.drawPath(rightFang, Paint()..color = Colors.white);

    // 6. Con Mắt Độc Nhãn Đỏ Rực Ở Giữa (Central Glowing Red Cyclops Eye - Idle Nhấp nháy)
    final socketPath = Path()
      ..moveTo(0, -s * 0.20)
      ..lineTo(s * 0.22, -s * 0.02)
      ..lineTo(0, s * 0.14)
      ..lineTo(-s * 0.22, -s * 0.02)
      ..close();
    canvas.drawPath(socketPath, Paint()..color = const Color(0xFF16002C));

    final eyePulse = (math.sin(animTime * 9.0 + e.initialX) * 0.15 + 0.90).clamp(0.75, 1.1);
    const eyeCenter = Offset(0, -s * 0.02);

    // Hào quang đỏ quanh mắt
    canvas.drawCircle(
      eyeCenter,
      s * 0.21 * eyePulse,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFF1744).withValues(alpha: 0.95),
            const Color(0xFFD50000).withValues(alpha: 0.55),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: eyeCenter, radius: s * 0.22)),
    );

    // Tròng mắt đỏ hồng
    canvas.drawCircle(eyeCenter, s * 0.125, Paint()..color = const Color(0xFFFF1744));
    canvas.drawCircle(eyeCenter, s * 0.085, Paint()..color = const Color(0xFF880E4F));
    // Con ngươi trắng phát sáng chính giữa
    canvas.drawCircle(eyeCenter, s * 0.048 * eyePulse, Paint()..color = Colors.white);

    // 7. Hit Animation (Trúng đạn - Chuẩn Hình 3: Vết nứt tinh thể + Chớp sao hồng trắng)
    if (e.hitFlashTimer > 0) {
      final hitAlpha = (e.hitFlashTimer / 0.18).clamp(0.0, 1.0);

      // Vết nứt tinh thể tím sáng
      final crackPaint = Paint()
        ..color = const Color(0xFFFF80AB).withValues(alpha: hitAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(const Offset(0, -s * 0.02), const Offset(-s * 0.28, -s * 0.35), crackPaint);
      canvas.drawLine(const Offset(0, -s * 0.02), const Offset(s * 0.32, -s * 0.22), crackPaint);
      canvas.drawLine(const Offset(0, -s * 0.02), const Offset(s * 0.18, s * 0.28), crackPaint);

      // Ngôi sao chớp sáng hồng-trắng ngay trên thân quái (Hit Animation Hình 3)
      _drawExplosionStarburst(canvas, const Offset(s * 0.06, s * 0.02), s * 0.52, hitAlpha, const Color(0xFFFF1744));
    }

    canvas.restore();
  }

  // --- Vẽ viên Tinh Thể Kim Cương Đỏ Hồng (Dùng cho 4 tinh thể dưới bụng quái & đạn bắn) ---
  void _drawRedCrystalShard(Canvas canvas, Offset pos, double halfW, double halfH, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    if (angle != 0) canvas.rotate(angle);

    // Quầng sáng đỏ hồng bên ngoài
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF1744).withValues(alpha: 0.75),
          const Color(0xFFF50057).withValues(alpha: 0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: halfH * 1.35));
    canvas.drawCircle(Offset.zero, halfH * 1.35, glowPaint);

    // Hình thoi kim cương đỏ hồng bên ngoài
    final outerDiamond = Path()
      ..moveTo(0, -halfH)
      ..lineTo(halfW, 0)
      ..lineTo(0, halfH)
      ..lineTo(-halfW, 0)
      ..close();
    canvas.drawPath(
      outerDiamond,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFFFF80AB), Color(0xFFFF1744), Color(0xFFD50000)],
        ).createShader(Rect.fromLTWH(-halfW, -halfH, halfW * 2, halfH * 2)),
    );

    // Lõi hình thoi trắng sáng rực bên trong (Chuẩn Bullet Hình 2 & Hình 3)
    final innerDiamond = Path()
      ..moveTo(0, -halfH * 0.58)
      ..lineTo(halfW * 0.52, 0)
      ..lineTo(0, halfH * 0.58)
      ..lineTo(-halfW * 0.52, 0)
      ..close();
    canvas.drawPath(innerDiamond, Paint()..color = Colors.white);

    canvas.restore();
  }

  // --- Vẽ ngôi sao 4 cánh nhỏ lấp lánh (Sparkle) ---
  void _drawTinyFourPointStar(Canvas canvas, Offset center, double size, Color color) {
    if (size <= 0.2) return;
    final path = Path()
      ..moveTo(center.dx, center.dy - size * 1.5)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size * 1.5, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size * 1.5)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size * 1.5, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size * 1.5)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  // --- Draw Dynamic Boss Based on BossConfig (Đại Chúa Tể Tinh Thể Độc Nhãn) ---
  void _drawBoss(Canvas canvas, Enemy e) {
    final cfg = e.bossConfig ?? BossConfig.allBosses[0];
    // Vẽ Boss theo phong cách Chúa Tể Quái Tinh Thể Độc Nhãn khổng lồ
    final scale = (e.width / 64.0).clamp(2.0, 4.2);
    _drawCrystalCyclopsMonster(canvas, e, scale);

    if (cfg.level >= 8) {
      final auraPulse = math.sin(animTime * 12.0) * 8.0;
      final ringPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(Offset.zero, (e.width / 2.0) * 0.85 + auraPulse, ringPaint);
    }
  }

  // --- Render Bullets (Đạn quái hình Tinh Thể Kim Cương Đỏ Trắng chuẩn Hình 2 & Hình 3) ---
  void _drawBullet(Canvas canvas, Bullet b) {
    if (b.isLaser) {
      final laserPaint = Paint()
        ..shader = LinearGradient(
          colors: b.isPlayer
              ? const [Color(0xFFE0F7FA), Color(0xFF00E5FF), Color(0xFF00B0FF)]
              : const [Color(0xFFFFFFFF), Color(0xFFFF1744), Color(0xFFD50000)],
        ).createShader(Rect.fromLTWH(b.x - 7, b.y - 32, 14, 44));
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(b.x - 6, b.y - 28, 12, 40), const Radius.circular(6)),
        laserPaint,
      );
    } else if (b.isMissile) {
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
      canvas.drawCircle(const Offset(-8, 0), 3.5, Paint()..color = const Color(0xFFFF1744));
      canvas.restore();
    } else if (!b.isPlayer) {
      // Đạn của Quái: Hình Tinh Thể Kim Cương Đỏ-Hồng lõi Trắng (Bullet trong Hình 2 & Hình 3)
      final angle = math.atan2(b.vy, b.vx) - math.pi / 2.0;
      _drawRedCrystalShard(canvas, Offset(b.x, b.y), b.radius * 1.15, b.radius * 2.35, angle);
    } else {
      // Đạn của Người chơi: Cầu Plasma Xanh Cyan sáng sắc nét (Giống Hình 2)
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

    final pulse = math.sin(p.anim) * 3.0;
    final haloPaint = Paint()
      ..color = pColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 18 + pulse, haloPaint);

    final borderPaint = Paint()
      ..color = pColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, 15, borderPaint);

    canvas.drawCircle(Offset.zero, 12, Paint()..color = const Color(0xFF10192D));

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
