import 'dart:math' as math;
import 'package:flutter/material.dart';

// Parallax Background Star
class Star {
  double x;
  double y;
  final double speed;
  final double size;
  final Color color;
  final double twinkleOffset;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.twinkleOffset,
  });
}

// Cosmic Nebula Cloud
class Nebula {
  double x;
  double y;
  final double radius;
  final Color color;
  final double speed;

  Nebula({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
  });
}

// Particle Effect (Fire, Sparks, Explosions, Shockwaves)
class SpaceParticle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  final double maxLife;
  final double size;
  final Color color;
  final bool isShockwave;

  SpaceParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.maxLife,
    required this.size,
    required this.color,
    this.isShockwave = false,
  }) : life = maxLife;

  bool update(double dt) {
    x += vx * dt;
    y += vy * dt;
    life -= dt;
    return life > 0;
  }
}

// Bullet & Laser Projectiles
class Bullet {
  double x;
  double y;
  double vx;
  double vy;
  final bool isPlayer;
  final double damage;
  final double radius;
  final Color color;
  final bool isLaser;
  final bool isMissile;
  final bool isOrbital;
  double? targetX;
  double? targetY;
  double missileAngle = 0.0;

  Bullet({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.isPlayer,
    required this.damage,
    required this.radius,
    required this.color,
    this.isLaser = false,
    this.isMissile = false,
    this.isOrbital = false,
  });

  void update(double dt) {
    if (isMissile && targetX != null && targetY != null) {
      final dx = targetX! - x;
      final dy = targetY! - y;
      final desiredAngle = math.atan2(dy, dx);
      final diff = desiredAngle - missileAngle;
      final wrapped = math.atan2(math.sin(diff), math.cos(diff));
      missileAngle += wrapped * (dt * 7.5);

      const speed = 560.0;
      vx = math.cos(missileAngle) * speed;
      vy = math.sin(missileAngle) * speed;
    }

    x += vx * dt;
    y += vy * dt;
  }
}

// Power-Up Drops
enum PowerUpType { heal, shield, weapon, nuke, drone, overdrive }

class PowerUp {
  double x;
  double y;
  double vy;
  final PowerUpType type;
  double anim = 0.0;

  PowerUp({
    required this.x,
    required this.y,
    required this.type,
    this.vy = 95.0,
  });

  void update(double dt) {
    y += vy * dt;
    anim += dt * 3.8;
  }
}

// Wingman Drone Companion
class WingmanDrone {
  final bool isLeft;
  double shootTimer = 0.0;
  Offset currentPos = Offset.zero;

  WingmanDrone({required this.isLeft});
}

// 10 Boss Configurations (From Level 1 to Level 10)
class BossConfig {
  final int level;
  final String name;
  final String title;
  final double maxHealth;
  final double width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Color coreColor;
  final double shootInterval;
  final int scoreValue;
  final String difficultyTag;

  const BossConfig({
    required this.level,
    required this.name,
    required this.title,
    required this.maxHealth,
    required this.width,
    required this.height,
    required this.primaryColor,
    required this.secondaryColor,
    required this.coreColor,
    required this.shootInterval,
    required this.scoreValue,
    required this.difficultyTag,
  });

  static const List<BossConfig> allBosses = [
    // Level 1: Cyber Scout Commander
    BossConfig(
      level: 1,
      name: 'CYBER COMMANDER',
      title: 'Vanguard Scout Flagship',
      maxHealth: 1600,
      width: 140,
      height: 75,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFF0D47A1),
      coreColor: Color(0xFF00B0FF),
      shootInterval: 1.05,
      scoreValue: 3000,
      difficultyTag: 'DỄ (CẤP 1)',
    ),
    // Level 2: Crimson Phantom
    BossConfig(
      level: 2,
      name: 'CRIMSON PHANTOM',
      title: 'Stealth Warp Interceptor',
      maxHealth: 3600,
      width: 160,
      height: 80,
      primaryColor: Color(0xFFFF1744),
      secondaryColor: Color(0xFF880E4F),
      coreColor: Color(0xFFFF5252),
      shootInterval: 0.90,
      scoreValue: 5000,
      difficultyTag: 'BÌNH THƯỜNG (CẤP 2)',
    ),
    // Level 3: Emerald Juggernaut
    BossConfig(
      level: 3,
      name: 'EMERALD JUGGERNAUT',
      title: 'Heavy Siege Dreadnought',
      maxHealth: 7200,
      width: 180,
      height: 90,
      primaryColor: Color(0xFF00E676),
      secondaryColor: Color(0xFF1B5E20),
      coreColor: Color(0xFF76FF03),
      shootInterval: 0.78,
      scoreValue: 8000,
      difficultyTag: 'KHÁ (CẤP 3)',
    ),
    // Level 4: Solar Destroyer
    BossConfig(
      level: 4,
      name: 'SOLAR DESTROYER',
      title: 'Plasma Core Cruiser',
      maxHealth: 12500,
      width: 200,
      height: 95,
      primaryColor: Color(0xFFFF9100),
      secondaryColor: Color(0xFFBF360C),
      coreColor: Color(0xFFFFD600),
      shootInterval: 0.68,
      scoreValue: 12000,
      difficultyTag: 'KHÓ (CẤP 4)',
    ),
    // Level 5: Titan Dreadnought
    BossConfig(
      level: 5,
      name: 'TITAN DREADNOUGHT',
      title: 'Armored Fleet Destroyer',
      maxHealth: 20000,
      width: 220,
      height: 105,
      primaryColor: Color(0xFFE040FB),
      secondaryColor: Color(0xFF4A148C),
      coreColor: Color(0xFFEA80FC),
      shootInterval: 0.56,
      scoreValue: 18000,
      difficultyTag: 'RẤT KHÓ (CẤP 5)',
    ),
    // Level 6: Shadow Behemoth
    BossConfig(
      level: 6,
      name: 'SHADOW BEHEMOTH',
      title: 'Dark Matter Leviathan',
      maxHealth: 32000,
      width: 240,
      height: 110,
      primaryColor: Color(0xFF7C4DFF),
      secondaryColor: Color(0xFF311B92),
      coreColor: Color(0xFFB388FF),
      shootInterval: 0.46,
      scoreValue: 28000,
      difficultyTag: 'ÁC MỘNG (CẤP 6)',
    ),
    // Level 7: Celestial Annihilator
    BossConfig(
      level: 7,
      name: 'CELESTIAL ANNIHILATOR',
      title: 'Starlight Annihilator',
      maxHealth: 50000,
      width: 255,
      height: 118,
      primaryColor: Color(0xFFFFD600),
      secondaryColor: Color(0xFFFF6F00),
      coreColor: Color(0xFFFFF176),
      shootInterval: 0.36,
      scoreValue: 45000,
      difficultyTag: 'SIÊU ÁC MỘNG (CẤP 7)',
    ),
    // Level 8: Nebula Overlord (CẤP 8 MẠNH NHẤT - BẤT KHẢ CHIẾN BẠI / KHÔNG AI QUA ĐƯỢC)
    BossConfig(
      level: 8,
      name: 'NEBULA OVERLORD',
      title: 'CẤP 8 MẠNH NHẤT - BẤT KHẢ CHIẾN BẠI',
      maxHealth: 95000,
      width: 280,
      height: 130,
      primaryColor: Color(0xFFFF0055),
      secondaryColor: Color(0xFF1E002E),
      coreColor: Color(0xFFFFD700),
      shootInterval: 0.22,
      scoreValue: 100000,
      difficultyTag: 'CẤP 8 MẠNH NHẤT (KHÔNG AI QUA ĐƯỢC)',
    ),
  ];
}

// Enemy Spacecraft Types
enum EnemyType { scout, interceptor, heavyCruiser, boss }

class Enemy {
  double x;
  double y;
  double vx;
  double vy;
  final EnemyType type;
  double health;
  final double maxHealth;
  final double width;
  final double height;
  final int scoreValue;

  double shootTimer = 0.0;
  final double shootInterval;
  double moveTimer = 0.0;
  double initialX;

  // Boss specific properties
  final BossConfig? bossConfig;
  int bossPhase = 1;
  double bossSkillTimer = 0.0;
  double specialAttackTimer = 0.0;

  Enemy({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.type,
    required this.health,
    required this.maxHealth,
    required this.width,
    required this.height,
    required this.scoreValue,
    required this.shootInterval,
    this.bossConfig,
  }) : initialX = x;

  void update(double dt, double screenWidth) {
    moveTimer += dt;
    shootTimer += dt;
    bossSkillTimer += dt;
    specialAttackTimer += dt;

    switch (type) {
      case EnemyType.scout:
        // Swooping sine wave motion
        y += vy * dt;
        x = initialX + math.sin(moveTimer * 3.2) * 60.0;
        break;

      case EnemyType.interceptor:
        // Aggressive zig-zag diving
        y += vy * dt;
        x += vx * dt;
        if (x < 30 || x > screenWidth - 30) {
          vx = -vx;
        }
        break;

      case EnemyType.heavyCruiser:
        // Slow advance, stops at top third to bombard
        if (y < 160) {
          y += vy * dt;
        } else {
          x = initialX + math.sin(moveTimer * 1.6) * 70.0;
        }
        break;

      case EnemyType.boss:
        // Mega Dreadnought entrance and boss patterns
        final targetTopY = (bossConfig?.level ?? 1) >= 8 ? 120.0 : 135.0;
        if (y < targetTopY) {
          y += vy * dt;
        } else {
          // Dynamic movement depending on boss level
          final swaySpeed = 0.8 + ((bossConfig?.level ?? 1) * 0.12);
          final swayWidth = (screenWidth * 0.35).clamp(80.0, 140.0);
          x = (screenWidth / 2) + math.sin(moveTimer * swaySpeed) * swayWidth;
          y = targetTopY + math.sin(moveTimer * 1.8) * 15.0;
        }
        break;
    }
  }
}

// Floating Damage / Score Text
class FloatingText {
  double x;
  double y;
  final String text;
  final Color color;
  double life = 1.0;
  final double scale;

  FloatingText({
    required this.x,
    required this.y,
    required this.text,
    required this.color,
    this.scale = 1.0,
  });

  bool update(double dt) {
    y -= dt * 50.0;
    life -= dt * 1.3;
    return life > 0;
  }
}