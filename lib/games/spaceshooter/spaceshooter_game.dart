import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'models/entities.dart';
import 'renderer/space_painter.dart';

class SpaceShooterGame extends StatefulWidget {
  final VoidCallback? onExitToMenu;
  const SpaceShooterGame({super.key, this.onExitToMenu});

  @override
  State<SpaceShooterGame> createState() => _SpaceShooterGameState();
}

class _SpaceShooterGameState extends State<SpaceShooterGame>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  double _animTime = 0.0;

  // Repaint Notifier for Zero-Lag 60-120fps iOS-like Rendering
  final ValueNotifier<int> _frameNotifier = ValueNotifier<int>(0);

  // Screen Bounds
  Size _screenSize = const Size(400, 800);

  // Player State
  Offset _playerPos = const Offset(200, 650);
  Offset _targetPlayerPos = const Offset(200, 650);
  bool _isDragging = false;
  double _playerHealth = 100.0;
  final double _maxHealth = 100.0;
  double _playerShield = 100.0;
  final double _maxShield = 100.0;
  int _weaponLevel = 1;
  int _bombCount = 3;
  double _invulnerableTimer = 0.0;
  double _shootTimer = 0.0;

  // Skills & Powerups
  double _overdriveTimer = 0.0;
  final List<WingmanDrone> _drones = [];

  // Entities
  final List<Star> _stars = [];
  final List<Nebula> _nebulae = [];
  final List<SpaceParticle> _particles = [];
  final List<Bullet> _bullets = [];
  final List<PowerUp> _powerUps = [];
  final List<Enemy> _enemies = [];
  final List<FloatingText> _floatingTexts = [];

  // 10-Stage Level System
  int _stage = 1;
  int _subWave = 1;
  double _spawnTimer = 0.0;
  int _enemiesSpawnedInSubWave = 0;
  bool _isBossApproaching = false;
  bool _isBossActive = false;
  bool _isStageClear = false;
  bool _isGameVictory = false;
  bool _isGameOver = false;

  int _score = 0;

  // VFX
  double _screenShake = 0.0;
  double _flashOpacity = 0.0;
  double _bossWarningTimer = 0.0;

  @override
  void initState() {
    super.initState();
    _initCosmos();
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  void _initCosmos() {
    final rand = math.Random(888);
    _stars.clear();
    for (int i = 0; i < 95; i++) {
      _stars.add(Star(
        x: rand.nextDouble() * 500,
        y: rand.nextDouble() * 1000,
        speed: 35.0 + rand.nextDouble() * 140.0,
        size: 0.8 + rand.nextDouble() * 2.2,
        color: i % 4 == 0
            ? const Color(0xFF80D8FF)
            : (i % 6 == 0 ? const Color(0xFFFFD54F) : Colors.white),
        twinkleOffset: rand.nextDouble() * math.pi * 2,
      ));
    }

    // Không dùng màu Cyan sáng làm đục màn hình, dùng sắc tím vũ trụ và xanh thẫm
    _nebulae.clear();
    _nebulae.add(Nebula(x: 100, y: 150, radius: 160, color: const Color(0xFF38006B), speed: 16.0));
    _nebulae.add(Nebula(x: 300, y: 550, radius: 180, color: const Color(0xFF0D1E4A), speed: 22.0));
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frameNotifier.dispose();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      _stage = 1;
      _subWave = 1;
      _spawnTimer = 0.0;
      _enemiesSpawnedInSubWave = 0;
      _isBossApproaching = false;
      _isBossActive = false;
      _isStageClear = false;
      _isGameVictory = false;
      _isGameOver = false;

      _score = 0;
      _playerHealth = _maxHealth;
      _playerShield = _maxShield;
      _playerPos = Offset(_screenSize.width / 2, _screenSize.height * 0.80);
      _targetPlayerPos = _playerPos;
      _weaponLevel = 1;
      _bombCount = 3;
      _invulnerableTimer = 2.0;
      _overdriveTimer = 0.0;
      _flashOpacity = 0.0;
      _screenShake = 0.0;
      _lastElapsed = Duration.zero;

      _drones.clear();
      _bullets.clear();
      _enemies.clear();
      _powerUps.clear();
      _particles.clear();
      _floatingTexts.clear();
    });
  }

  void _startNextStage() {
    setState(() {
      if (_stage < 8) {
        _stage++;
        _subWave = 1;
        _spawnTimer = 0.0;
        _enemiesSpawnedInSubWave = 0;
        _isBossApproaching = false;
        _isBossActive = false;
        _isStageClear = false;

        // Triệt tiêu hoàn toàn màn trắng/sáng mờ khi sang bàn
        _flashOpacity = 0.0;
        _screenShake = 0.0;
        _lastElapsed = Duration.zero;

        // Reset súng về lại Cấp 1 ở đầu mỗi bàn theo yêu cầu của anh Khánh đẹp trai nhất vũ trụ
        _weaponLevel = 1;
        _drones.clear();
        _overdriveTimer = 0.0;

        _playerHealth = (_playerHealth + 40).clamp(0.0, _maxHealth);
        _playerShield = _maxShield;
        _invulnerableTimer = 2.5;

        _bullets.clear();
        _enemies.clear();
        _powerUps.clear();
        _particles.clear();
        _floatingTexts.clear();

        _addFloatingText(_screenSize.width / 2, 310, '*** BÀN $_stage/8: XUẤT KÍCH! ***', const Color(0xFF00E5FF), scale: 1.4);
        _addFloatingText(_screenSize.width / 2, 350, '⚡ SÚNG RESET CẤP 1 - TIÊU DIỆT QUÁI ĐỂ NÂNG CẤP!', const Color(0xFFFFD600), scale: 1.05);
        HapticFeedback.heavyImpact();
      }
    });
  }

  // --- High-Performance 60-120fps Game Loop ---
  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    final double clampedDt = dt.clamp(0.001, 0.04);

    _animTime += clampedDt;

    if (_isGameOver || _isStageClear || _isGameVictory) {
      _frameNotifier.value++;
      return;
    }

    // 1. Ultra-Smooth iOS-like 1:1 Touch Lerp (Zero Input Delay)
    if (_isDragging) {
      _playerPos = Offset(
        _playerPos.dx + (_targetPlayerPos.dx - _playerPos.dx) * 0.88,
        _playerPos.dy + (_targetPlayerPos.dy - _playerPos.dy) * 0.88,
      );
    }

    // 2. Parallax Starfield & Nebulae
    for (final star in _stars) {
      star.y += star.speed * clampedDt;
      if (star.y > _screenSize.height) {
        star.y = 0;
        star.x = math.Random().nextDouble() * _screenSize.width;
      }
    }
    for (final neb in _nebulae) {
      neb.y += neb.speed * clampedDt;
      if (neb.y - neb.radius > _screenSize.height) {
        neb.y = -neb.radius;
        neb.x = math.Random().nextDouble() * _screenSize.width;
      }
    }

    // 3. Timers & Timed Overdrive/Shield
    if (_invulnerableTimer > 0) _invulnerableTimer -= clampedDt;
    if (_screenShake > 0) _screenShake = (_screenShake - clampedDt * 4.0).clamp(0.0, 1.0);
    if (_flashOpacity > 0) _flashOpacity = (_flashOpacity - clampedDt * 5.5).clamp(0.0, 1.0);
    if (_overdriveTimer > 0) _overdriveTimer -= clampedDt;

    // Passive Shield Regen
    if (_playerShield < _maxShield && _playerHealth > 0) {
      _playerShield = (_playerShield + clampedDt * 4.0).clamp(0.0, _maxShield);
    }

    // 4. Update Wingman Drones Position
    for (final drone in _drones) {
      final targetDx = _playerPos.dx + (drone.isLeft ? -38.0 : 38.0);
      final targetDy = _playerPos.dy + 10.0;
      drone.currentPos = Offset(
        drone.currentPos.dx + (targetDx - drone.currentPos.dx) * 0.35,
        drone.currentPos.dy + (targetDy - drone.currentPos.dy) * 0.35,
      );

      // Drone auto-firing
      drone.shootTimer += clampedDt;
      if (drone.shootTimer >= 0.16 && _playerHealth > 0) {
        drone.shootTimer = 0.0;
        _bullets.add(Bullet(
          x: drone.currentPos.dx,
          y: drone.currentPos.dy - 12,
          vx: 0,
          vy: -920,
          isPlayer: true,
          damage: 16 + _stage * 2,
          radius: 3.5,
          color: const Color(0xFFE040FB),
        ));
      }
    }

    // 5. Player Auto-Firing
    _shootTimer += clampedDt;
    final isFastFire = _overdriveTimer > 0;
    final baseRate = _weaponLevel >= 5 ? 0.10 : (_weaponLevel >= 3 ? 0.13 : 0.17);
    final fireInterval = isFastFire ? (baseRate * 0.45) : baseRate;

    if (_shootTimer >= fireInterval && _playerHealth > 0) {
      _shootTimer = 0.0;
      _firePlayerWeapons();
    }

    // 6. Update Bullets
    for (int i = _bullets.length - 1; i >= 0; i--) {
      final b = _bullets[i];
      b.update(clampedDt);

      if (b.y < -50 || b.y > _screenSize.height + 50 || b.x < -40 || b.x > _screenSize.width + 40) {
        _bullets.removeAt(i);
        continue;
      }

      // Player Bullet hitting Enemy
      if (b.isPlayer) {
        for (int j = _enemies.length - 1; j >= 0; j--) {
          final e = _enemies[j];
          final hitDist = b.radius + (e.width / 2.0);
          final dx = (b.x - e.x).abs();
          final dy = (b.y - e.y).abs();

          if (dx < hitDist && dy < e.height / 2.0 + b.radius) {
            e.health -= b.damage;
            _createImpactSparks(b.x, b.y, const Color(0xFF80D8FF));

            if (!b.isLaser) {
              _bullets.removeAt(i);
            }

            if (e.health <= 0) {
              _destroyEnemy(e, j);
            }
            break;
          }
        }
      } else {
        // Enemy Bullet hitting Player
        if (_playerHealth > 0 && _invulnerableTimer <= 0 && _overdriveTimer <= 0) {
          final dist = Offset(b.x - _playerPos.dx, b.y - _playerPos.dy).distance;
          if (dist < 26.0) {
            _bullets.removeAt(i);
            _damagePlayer(b.damage);
          }
        }
      }
    }

    // 7. Update Enemies & AI Shooting
    for (int i = _enemies.length - 1; i >= 0; i--) {
      final e = _enemies[i];
      e.update(clampedDt, _screenSize.width);

      // Enemy shooting patterns
      if (e.shootTimer >= e.shootInterval && e.y > 15 && e.y < _screenSize.height - 80) {
        e.shootTimer = 0.0;
        _enemyFire(e);
      }

      // Offscreen culling for non-bosses
      if (e.type != EnemyType.boss && e.y > _screenSize.height + 40) {
        _enemies.removeAt(i);
        continue;
      }

      // Enemy ramming Player
      if (_playerHealth > 0 && _invulnerableTimer <= 0 && _overdriveTimer <= 0) {
        final dist = Offset(e.x - _playerPos.dx, e.y - _playerPos.dy).distance;
        if (dist < (e.width / 2.0 + 22.0)) {
          _damagePlayer(30.0);
          if (e.type != EnemyType.boss) {
            _destroyEnemy(e, i);
          }
        }
      }
    }

    // 8. Update Power-Ups
    for (int i = _powerUps.length - 1; i >= 0; i--) {
      final p = _powerUps[i];
      p.update(clampedDt);

      if (p.y > _screenSize.height + 30) {
        _powerUps.removeAt(i);
        continue;
      }

      final dist = Offset(p.x - _playerPos.dx, p.y - _playerPos.dy).distance;
      if (dist < 38.0) {
        _collectPowerUp(p);
        _powerUps.removeAt(i);
      }
    }

    // 9. Update Particles & Floating Text
    _particles.removeWhere((pt) => !pt.update(clampedDt));
    _floatingTexts.removeWhere((ft) => !ft.update(clampedDt));

    // 10. 10-Stage Progression & Boss Spawning Logic
    _updateStageProgression(clampedDt);

    // Repaint game canvas without triggering widget rebuild
    _frameNotifier.value++;
  }

  // --- Stage & Wave Progression ---
  void _updateStageProgression(double dt) {
    if (_isBossActive) {
      final bossAlive = _enemies.any((e) => e.type == EnemyType.boss);
      if (!bossAlive) {
        // Boss Defeated!
        _isBossActive = false;
        _flashOpacity = 0.0;
        HapticFeedback.heavyImpact();

        if (_stage >= 8) {
          // Beat Level 8 -> Game Victory!
          _isGameVictory = true;
          _addFloatingText(_screenSize.width / 2, 280, '*** CHIẾN THẦN VŨ TRỤ: ANH KHÁNH ĐẸP TRAI! ***', const Color(0xFFFFD700), scale: 1.5);
          setState(() {});
        } else {
          // Stage Cleared!
          _isStageClear = true;
          _addFloatingText(_screenSize.width / 2, 280, '=== STAGE $_stage HOÀN THÀNH! ===', const Color(0xFF00E676), scale: 1.4);
          setState(() {});
        }
      }
      return;
    }

    if (_isBossApproaching) {
      _bossWarningTimer += dt;
      if (_bossWarningTimer >= 3.2) {
        _isBossApproaching = false;
        _spawnStageBoss();
      }
      return;
    }

    _spawnTimer += dt;

    // Quái hiện nhiều lên, dồn dập và đông đảo (3 đợt lính mỗi stage)
    final spawnRate = (_stage >= 6 ? 0.38 : (_stage >= 3 ? 0.48 : 0.58));
    final maxEnemies = (_stage >= 6 ? 16 : (_stage >= 3 ? 14 : 12));

    if (_spawnTimer >= spawnRate && _enemies.length < maxEnemies && _enemiesSpawnedInSubWave < (12 + _stage * 3)) {
      _spawnTimer = 0.0;
      _spawnMinionSwarm();
    }

    // When current sub-wave is cleared
    if (_enemiesSpawnedInSubWave >= (12 + _stage * 3) && _enemies.isEmpty) {
      if (_subWave < 3) {
        _subWave++;
        _enemiesSpawnedInSubWave = 0;
        _addFloatingText(_screenSize.width / 2, 250, 'WAVE $_subWave/3', const Color(0xFFE040FB));
      } else {
        // Ready for BOSS!
        _isBossApproaching = true;
        _bossWarningTimer = 0.0;
        HapticFeedback.heavyImpact();
        _screenShake = 1.0;
        if (_stage == 8) {
          _addFloatingText(_screenSize.width / 2, 210, '⚠️ CẢNH BÁO: TRÙM CẤP 8 XUẤT HIỆN! ⚠️', const Color(0xFFFF0055), scale: 1.35);
          _addFloatingText(_screenSize.width / 2, 250, '☠️ MẠNH NHẤT VŨ TRỤ - KHÔNG AI QUA ĐƯỢC! ☠️', const Color(0xFFFFD700), scale: 1.15);
        } else {
          _addFloatingText(_screenSize.width / 2, 250, '[!] CẢNH BÁO: TRÙM CẤP $_stage XUẤT HIỆN! [!]', const Color(0xFFFF1744), scale: 1.3);
        }
      }
    }
  }

  // --- Spawn Minion Swarms & Formations (Quái xuất hiện nhiều, theo đàn) ---
  void _spawnMinionSwarm() {
    final rand = math.Random();
    final pattern = rand.nextDouble();
    final centerX = 50.0 + rand.nextDouble() * (_screenSize.width - 100.0);

    if (pattern < 0.35) {
      // Đội hình 1: Phi cơ Scout hình chữ V (3 chiếc lao xuống dồn dập)
      for (int i = -1; i <= 1; i++) {
        _enemiesSpawnedInSubWave++;
        _enemies.add(Enemy(
          x: (centerX + i * 36.0).clamp(25.0, _screenSize.width - 25.0),
          y: -25.0 - (i.abs() * 25.0),
          vx: 0,
          vy: 135 + _stage * 12.0,
          type: EnemyType.scout,
          health: 40 + _stage * 22.0,
          maxHealth: 40 + _stage * 22.0,
          width: 28,
          height: 28,
          scoreValue: 90 + _stage * 30,
          shootInterval: (1.5 - _stage * 0.08).clamp(0.65, 1.5),
        ));
      }
    } else if (pattern < 0.65) {
      // Đội hình 2: Cặp Tiêm kích Interceptor đảo cánh cắt chéo nhau
      _enemiesSpawnedInSubWave += 2;
      _enemies.add(Enemy(
        x: (centerX - 40.0).clamp(30.0, _screenSize.width - 30.0),
        y: -35.0,
        vx: 80.0 + _stage * 8.0,
        vy: 115 + _stage * 10.0,
        type: EnemyType.interceptor,
        health: 80 + _stage * 35.0,
        maxHealth: 80 + _stage * 35.0,
        width: 40,
        height: 38,
        scoreValue: 160 + _stage * 50,
        shootInterval: (1.3 - _stage * 0.08).clamp(0.55, 1.3),
      ));
      _enemies.add(Enemy(
        x: (centerX + 40.0).clamp(30.0, _screenSize.width - 30.0),
        y: -35.0,
        vx: -80.0 - _stage * 8.0,
        vy: 115 + _stage * 10.0,
        type: EnemyType.interceptor,
        health: 80 + _stage * 35.0,
        maxHealth: 80 + _stage * 35.0,
        width: 40,
        height: 38,
        scoreValue: 160 + _stage * 50,
        shootInterval: (1.3 - _stage * 0.08).clamp(0.55, 1.3),
      ));
    } else if (pattern < 0.85 && _stage >= 3) {
      // Đội hình 3: Thiết giáp Hạng nặng Heavy Cruiser có Scout hộ tống
      _enemiesSpawnedInSubWave += 2;
      _enemies.add(Enemy(
        x: centerX.clamp(45.0, _screenSize.width - 45.0),
        y: -50.0,
        vx: 0,
        vy: 50 + _stage * 4.0,
        type: EnemyType.heavyCruiser,
        health: 300 + _stage * 110.0,
        maxHealth: 300 + _stage * 110.0,
        width: 64,
        height: 52,
        scoreValue: 400 + _stage * 100,
        shootInterval: (1.7 - _stage * 0.1).clamp(0.75, 1.7),
      ));
      _enemies.add(Enemy(
        x: (centerX - 50.0).clamp(25.0, _screenSize.width - 25.0),
        y: -25.0,
        vx: 0,
        vy: 130 + _stage * 10.0,
        type: EnemyType.scout,
        health: 40 + _stage * 20.0,
        maxHealth: 40 + _stage * 20.0,
        width: 28,
        height: 28,
        scoreValue: 90 + _stage * 30,
        shootInterval: 1.4,
      ));
    } else {
      // Đội hình 4: Cặp phi cơ trinh sát song sát
      _enemiesSpawnedInSubWave += 2;
      _enemies.add(Enemy(
        x: (centerX - 35.0).clamp(25.0, _screenSize.width - 25.0),
        y: -30.0,
        vx: 0,
        vy: 140 + _stage * 10.0,
        type: EnemyType.scout,
        health: 40 + _stage * 20.0,
        maxHealth: 40 + _stage * 20.0,
        width: 28,
        height: 28,
        scoreValue: 90 + _stage * 30,
        shootInterval: 1.4,
      ));
      _enemies.add(Enemy(
        x: (centerX + 35.0).clamp(25.0, _screenSize.width - 25.0),
        y: -30.0,
        vx: 0,
        vy: 140 + _stage * 10.0,
        type: EnemyType.scout,
        health: 40 + _stage * 20.0,
        maxHealth: 40 + _stage * 20.0,
        width: 28,
        height: 28,
        scoreValue: 90 + _stage * 30,
        shootInterval: 1.4,
      ));
    }
  }

  // --- Spawn Boss for Current Stage (Levels 1 to 8) ---
  void _spawnStageBoss() {
    _isBossActive = true;
    _enemies.clear(); // Clear minions for epic 1v1 duel

    final bossIdx = (_stage - 1).clamp(0, BossConfig.allBosses.length - 1);
    final cfg = BossConfig.allBosses[bossIdx];

    _enemies.add(Enemy(
      x: _screenSize.width / 2,
      y: -cfg.height - 20,
      vx: 0,
      vy: 42.0,
      type: EnemyType.boss,
      health: cfg.maxHealth,
      maxHealth: cfg.maxHealth,
      width: cfg.width,
      height: cfg.height,
      scoreValue: cfg.scoreValue,
      shootInterval: cfg.shootInterval,
      bossConfig: cfg,
    ));

    _addFloatingText(_screenSize.width / 2, 220, '*** ${cfg.name} ***', cfg.primaryColor, scale: 1.3);
    if (_stage == 8) {
      _addFloatingText(_screenSize.width / 2, 260, '☠️ CẤP 8 MẠNH NHẤT - BẤT KHẢ THI! ☠️', const Color(0xFFFFD700), scale: 1.15);
    }
    HapticFeedback.heavyImpact();
  }

  // --- Player Weapon Shooting Patterns (Levels 1 to 6) ---
  void _firePlayerWeapons() {
    final px = _playerPos.dx;
    final py = _playerPos.dy - 24;

    switch (_weaponLevel) {
      case 1:
        // Level 1: Twin Plasma Bolts
        _bullets.add(Bullet(x: px - 9, y: py, vx: 0, vy: -850, isPlayer: true, damage: 22, radius: 4.8, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px + 9, y: py, vx: 0, vy: -850, isPlayer: true, damage: 22, radius: 4.8, color: const Color(0xFF00E5FF)));
        break;

      case 2:
        // Level 2: 3-Way Spread Blaster
        _bullets.add(Bullet(x: px, y: py - 4, vx: 0, vy: -920, isPlayer: true, damage: 30, radius: 5.5, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px - 12, y: py, vx: -120, vy: -880, isPlayer: true, damage: 25, radius: 5.0, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px + 12, y: py, vx: 120, vy: -880, isPlayer: true, damage: 25, radius: 5.0, color: const Color(0xFF00E5FF)));
        break;

      case 3:
        // Level 3: 4-Way Heavy Energy Blaster
        _bullets.add(Bullet(x: px - 7, y: py - 4, vx: -40, vy: -950, isPlayer: true, damage: 35, radius: 5.8, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px + 7, y: py - 4, vx: 40, vy: -950, isPlayer: true, damage: 35, radius: 5.8, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px - 18, y: py, vx: -160, vy: -880, isPlayer: true, damage: 28, radius: 5.2, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px + 18, y: py, vx: 160, vy: -880, isPlayer: true, damage: 28, radius: 5.2, color: const Color(0xFFFFD600)));
        break;

      case 4:
        // Level 4: 5-Way Fan Spread + Dual Plasma Lasers
        _bullets.add(Bullet(x: px - 8, y: py - 10, vx: 0, vy: -1050, isPlayer: true, damage: 55, radius: 6.5, color: const Color(0xFF00E5FF), isLaser: true));
        _bullets.add(Bullet(x: px + 8, y: py - 10, vx: 0, vy: -1050, isPlayer: true, damage: 55, radius: 6.5, color: const Color(0xFF00E5FF), isLaser: true));
        _bullets.add(Bullet(x: px - 20, y: py, vx: -160, vy: -880, isPlayer: true, damage: 32, radius: 5.5, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px + 20, y: py, vx: 160, vy: -880, isPlayer: true, damage: 32, radius: 5.5, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px - 28, y: py + 4, vx: -260, vy: -820, isPlayer: true, damage: 28, radius: 5.0, color: const Color(0xFFFF5252)));
        _bullets.add(Bullet(x: px + 28, y: py + 4, vx: 260, vy: -820, isPlayer: true, damage: 28, radius: 5.0, color: const Color(0xFFFF5252)));
        break;

      case 5:
        // Level 5: 6-Way Spread + Dual Homing Missiles
        _bullets.add(Bullet(x: px - 8, y: py - 10, vx: 0, vy: -1100, isPlayer: true, damage: 65, radius: 7.0, color: const Color(0xFF00E5FF), isLaser: true));
        _bullets.add(Bullet(x: px + 8, y: py - 10, vx: 0, vy: -1100, isPlayer: true, damage: 65, radius: 7.0, color: const Color(0xFF00E5FF), isLaser: true));
        _bullets.add(Bullet(x: px - 20, y: py, vx: -150, vy: -920, isPlayer: true, damage: 38, radius: 5.5, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px + 20, y: py, vx: 150, vy: -920, isPlayer: true, damage: 38, radius: 5.5, color: const Color(0xFFFFD600)));
        _bullets.add(Bullet(x: px - 30, y: py + 4, vx: -280, vy: -850, isPlayer: true, damage: 34, radius: 5.2, color: const Color(0xFFFF1744)));
        _bullets.add(Bullet(x: px + 30, y: py + 4, vx: 280, vy: -850, isPlayer: true, damage: 34, radius: 5.2, color: const Color(0xFFFF1744)));

        // Dual Homing Missiles tracking Boss or nearest enemy
        Enemy? targetEnemy;
        for (final e in _enemies) {
          if (e.type == EnemyType.boss) {
            targetEnemy = e;
            break;
          }
        }
        targetEnemy ??= (_enemies.isNotEmpty ? _enemies.first : null);
        final tx = targetEnemy?.x ?? px;
        final ty = targetEnemy?.y ?? -100;

        _bullets.add(Bullet(x: px - 22, y: py + 8, vx: -100, vy: -380, isPlayer: true, damage: 75, radius: 6.5, color: const Color(0xFFFF9100), isMissile: true)..targetX = tx..targetY = ty);
        _bullets.add(Bullet(x: px + 22, y: py + 8, vx: 100, vy: -380, isPlayer: true, damage: 75, radius: 6.5, color: const Color(0xFFFF9100), isMissile: true)..targetX = tx..targetY = ty);
        break;

      default: // Level 6 (GOD TIER / OVERDRIVE)
        // 8-Way Hyper Rainbow Laser + Quad Homing Missiles
        _bullets.add(Bullet(x: px - 10, y: py - 12, vx: 0, vy: -1200, isPlayer: true, damage: 90, radius: 7.5, color: const Color(0xFFFFD600), isLaser: true));
        _bullets.add(Bullet(x: px + 10, y: py - 12, vx: 0, vy: -1200, isPlayer: true, damage: 90, radius: 7.5, color: const Color(0xFFFFD600), isLaser: true));
        _bullets.add(Bullet(x: px - 18, y: py - 6, vx: -80, vy: -1000, isPlayer: true, damage: 50, radius: 6.0, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px + 18, y: py - 6, vx: 80, vy: -1000, isPlayer: true, damage: 50, radius: 6.0, color: const Color(0xFF00E5FF)));
        _bullets.add(Bullet(x: px - 28, y: py, vx: -200, vy: -920, isPlayer: true, damage: 45, radius: 5.5, color: const Color(0xFFE040FB)));
        _bullets.add(Bullet(x: px + 28, y: py, vx: 200, vy: -920, isPlayer: true, damage: 45, radius: 5.5, color: const Color(0xFFE040FB)));
        _bullets.add(Bullet(x: px - 38, y: py + 6, vx: -320, vy: -850, isPlayer: true, damage: 40, radius: 5.2, color: const Color(0xFFFF1744)));
        _bullets.add(Bullet(x: px + 38, y: py + 6, vx: 320, vy: -850, isPlayer: true, damage: 40, radius: 5.2, color: const Color(0xFFFF1744)));

        // Quad Homing Missiles
        Enemy? bossTarget;
        for (final e in _enemies) {
          if (e.type == EnemyType.boss) {
            bossTarget = e;
            break;
          }
        }
        bossTarget ??= (_enemies.isNotEmpty ? _enemies.first : null);
        final tx = bossTarget?.x ?? px;
        final ty = bossTarget?.y ?? -100;

        _bullets.add(Bullet(x: px - 24, y: py + 8, vx: -120, vy: -420, isPlayer: true, damage: 85, radius: 6.5, color: const Color(0xFFFF9100), isMissile: true)..targetX = tx..targetY = ty);
        _bullets.add(Bullet(x: px + 24, y: py + 8, vx: 120, vy: -420, isPlayer: true, damage: 85, radius: 6.5, color: const Color(0xFFFF9100), isMissile: true)..targetX = tx..targetY = ty);
        _bullets.add(Bullet(x: px - 36, y: py + 12, vx: -220, vy: -380, isPlayer: true, damage: 85, radius: 6.5, color: const Color(0xFFFF1744), isMissile: true)..targetX = tx..targetY = ty);
        _bullets.add(Bullet(x: px + 36, y: py + 12, vx: 220, vy: -380, isPlayer: true, damage: 85, radius: 6.5, color: const Color(0xFFFF1744), isMissile: true)..targetX = tx..targetY = ty);
        break;
    }
  }

  // --- Boss & Enemy Danmaku Shooting Patterns ---
  void _enemyFire(Enemy e) {
    if (e.type != EnemyType.boss) {
      switch (e.type) {
        case EnemyType.scout:
          _bullets.add(Bullet(x: e.x, y: e.y + 12, vx: 0, vy: 280, isPlayer: false, damage: 12, radius: 4.0, color: const Color(0xFFFF1744)));
          break;
        case EnemyType.interceptor:
          _bullets.add(Bullet(x: e.x - 12, y: e.y + 10, vx: -50, vy: 310, isPlayer: false, damage: 16, radius: 4.5, color: const Color(0xFFE040FB)));
          _bullets.add(Bullet(x: e.x + 12, y: e.y + 10, vx: 50, vy: 310, isPlayer: false, damage: 16, radius: 4.5, color: const Color(0xFFE040FB)));
          break;
        case EnemyType.heavyCruiser:
          for (int i = -1; i <= 1; i++) {
            _bullets.add(Bullet(x: e.x, y: e.y + 20, vx: i * 90.0, vy: 290, isPlayer: false, damage: 20, radius: 5.5, color: const Color(0xFF76FF03)));
          }
          break;
        default:
          break;
      }
      return;
    }

    // --- 8 Boss Danmaku Bullet Hell Patterns (Mạnh dần qua từng level, Cấp 8 mạnh nhất không ai qua được) ---
    final lvl = e.bossConfig?.level ?? 1;
    final isEnraged = (e.health < e.maxHealth * 0.5);

    if (lvl == 1) {
      // LEVEL 1: CYBER SCOUT COMMANDER
      // 3-Way Spread Laser
      for (int i = -1; i <= 1; i++) {
        _bullets.add(Bullet(
          x: e.x + i * 20,
          y: e.y + 28,
          vx: i * 80.0,
          vy: 280,
          isPlayer: false,
          damage: 14,
          radius: 5.0,
          color: const Color(0xFF00E5FF),
        ));
      }
    } else if (lvl == 2) {
      // LEVEL 2: CRIMSON PHANTOM
      // 5-Way Fan Spread + Fast Pulse
      for (int i = -2; i <= 2; i++) {
        _bullets.add(Bullet(
          x: e.x + i * 16,
          y: e.y + 30,
          vx: i * 75.0,
          vy: 310,
          isPlayer: false,
          damage: 18,
          radius: 5.2,
          color: const Color(0xFFFF1744),
        ));
      }
    } else if (lvl == 3) {
      // LEVEL 3: EMERALD JUGGERNAUT
      // 7-Way Heavy Spread + Aimed Cannon Blast
      for (int i = -3; i <= 3; i++) {
        _bullets.add(Bullet(
          x: e.x + i * 15,
          y: e.y + 32,
          vx: i * 65.0,
          vy: 300,
          isPlayer: false,
          damage: 20,
          radius: 5.2,
          color: const Color(0xFF00E676),
        ));
      }
      final dx = _playerPos.dx - e.x;
      final dy = _playerPos.dy - e.y;
      final ang = math.atan2(dy, dx);
      _bullets.add(Bullet(
        x: e.x,
        y: e.y + 35,
        vx: math.cos(ang) * 380,
        vy: math.sin(ang) * 380,
        isPlayer: false,
        damage: 26,
        radius: 6.8,
        color: const Color(0xFF76FF03),
      ));
    } else if (lvl == 4) {
      // LEVEL 4: SOLAR DESTROYER
      // 8-Way Rotating Solar Burst + Dual High-Speed Lasers
      final baseA = e.moveTimer * 3.0;
      for (int i = 0; i < 8; i++) {
        final a = baseA + (i * math.pi / 4.0);
        _bullets.add(Bullet(
          x: e.x,
          y: e.y + 30,
          vx: math.cos(a) * 280,
          vy: math.sin(a) * 280 + 100,
          isPlayer: false,
          damage: 24,
          radius: 5.5,
          color: const Color(0xFFFF9100),
        ));
      }
      _bullets.add(Bullet(x: e.x - 28, y: e.y + 30, vx: -30, vy: 420, isPlayer: false, damage: 28, radius: 6.0, color: const Color(0xFFFFD600), isLaser: true));
      _bullets.add(Bullet(x: e.x + 28, y: e.y + 30, vx: 30, vy: 420, isPlayer: false, damage: 28, radius: 6.0, color: const Color(0xFFFFD600), isLaser: true));
    } else if (lvl == 5) {
      // LEVEL 5: TITAN DREADNOUGHT
      // 10-Way Expanding Radial Ring + Twin Homing Missiles
      final baseA = e.moveTimer * 3.5;
      for (int i = 0; i < 10; i++) {
        final a = baseA + (i * math.pi / 5.0);
        _bullets.add(Bullet(
          x: e.x,
          y: e.y + 35,
          vx: math.cos(a) * 300,
          vy: math.sin(a) * 300 + 110,
          isPlayer: false,
          damage: 28,
          radius: 5.8,
          color: const Color(0xFFE040FB),
        ));
      }
      _bullets.add(Bullet(x: e.x - 35, y: e.y + 20, vx: -120, vy: 260, isPlayer: false, damage: 32, radius: 6.5, color: const Color(0xFFFF1744), isMissile: true)..targetX = _playerPos.dx..targetY = _playerPos.dy);
      _bullets.add(Bullet(x: e.x + 35, y: e.y + 20, vx: 120, vy: 260, isPlayer: false, damage: 32, radius: 6.5, color: const Color(0xFFFF1744), isMissile: true)..targetX = _playerPos.dx..targetY = _playerPos.dy);
    } else if (lvl == 6) {
      // LEVEL 6: SHADOW BEHEMOTH
      // Double-Helix Spiral Danmaku (12 bullets per burst) + Quad Laser Grid
      final spiral1 = e.moveTimer * 5.0;
      final spiral2 = -e.moveTimer * 5.0;
      for (int i = 0; i < 6; i++) {
        final a1 = spiral1 + (i * math.pi / 3.0);
        final a2 = spiral2 + (i * math.pi / 3.0);
        _bullets.add(Bullet(x: e.x, y: e.y + 30, vx: math.cos(a1) * 310, vy: math.sin(a1) * 310 + 120, isPlayer: false, damage: 30, radius: 5.8, color: const Color(0xFF7C4DFF)));
        _bullets.add(Bullet(x: e.x, y: e.y + 30, vx: math.cos(a2) * 310, vy: math.sin(a2) * 310 + 120, isPlayer: false, damage: 30, radius: 5.8, color: const Color(0xFFB388FF)));
      }
      for (int i = -1; i <= 1; i += 2) {
        _bullets.add(Bullet(x: e.x + i * 45, y: e.y + 25, vx: i * 80.0, vy: 440, isPlayer: false, damage: 34, radius: 6.5, color: const Color(0xFFFF5252), isLaser: true));
      }
    } else if (lvl == 7) {
      // LEVEL 7: CELESTIAL ANNIHILATOR
      // 16-Way Celestial Starburst Ring + Triple Direct Snipers
      final baseA = e.moveTimer * 5.5;
      for (int i = 0; i < 16; i++) {
        final a = baseA + (i * math.pi / 8.0);
        _bullets.add(Bullet(x: e.x, y: e.y + 35, vx: math.cos(a) * 330, vy: math.sin(a) * 330 + 130, isPlayer: false, damage: 34, radius: 6.0, color: const Color(0xFFFFD600)));
      }
      final dx = _playerPos.dx - e.x;
      final dy = _playerPos.dy - e.y;
      final ang = math.atan2(dy, dx);
      for (int i = -1; i <= 1; i++) {
        final spread = ang + i * 0.12;
        _bullets.add(Bullet(x: e.x + i * 20, y: e.y + 40, vx: math.cos(spread) * 440, vy: math.sin(spread) * 440, isPlayer: false, damage: 38, radius: 7.0, color: const Color(0xFFFF1744)));
      }
    } else {
      // =========================================================================
      // LEVEL 8: NEBULA OVERLORD - CẤP 8 MẠNH NHẤT KHÔNG AI QUA ĐƯỢC!
      // (GOD-TIER UNBEATABLE BULLET HELL DANMAKU APOCALYPSE)
      // =========================================================================
      // 1. Vòng xoáy đạn Ma trận 20 tia xoay liên tục
      final baseA = e.moveTimer * 7.0;
      final count = isEnraged ? 24 : 20;
      for (int i = 0; i < count; i++) {
        final a = baseA + (i * math.pi * 2.0 / count);
        final speed = isEnraged ? 360.0 : 330.0;
        _bullets.add(Bullet(
          x: e.x,
          y: e.y + 45,
          vx: math.cos(a) * speed,
          vy: math.sin(a) * speed + 130,
          isPlayer: false,
          damage: 42,
          radius: 6.8,
          color: i % 2 == 0 ? const Color(0xFFFF0055) : const Color(0xFFFFD700),
        ));
      }

      // 2. Tứ Pháo Laze siêu tốc quét dọc bản đồ
      for (int i = -2; i <= 2; i++) {
        if (i == 0) continue;
        _bullets.add(Bullet(
          x: e.x + i * 36,
          y: e.y + 40,
          vx: i * 40.0,
          vy: 460,
          isPlayer: false,
          damage: 46,
          radius: 7.2,
          color: const Color(0xFFFF1744),
          isLaser: true,
        ));
      }

      // 3. Cặp Tên lửa Hắc ám tự tìm mục tiêu
      _bullets.add(Bullet(
        x: e.x - 55,
        y: e.y + 25,
        vx: -160,
        vy: 300,
        isPlayer: false,
        damage: 45,
        radius: 7.5,
        color: const Color(0xFFD500F9),
        isMissile: true,
      )..targetX = _playerPos.dx..targetY = _playerPos.dy);

      _bullets.add(Bullet(
        x: e.x + 55,
        y: e.y + 25,
        vx: 160,
        vy: 300,
        isPlayer: false,
        damage: 45,
        radius: 7.5,
        color: const Color(0xFFD500F9),
        isMissile: true,
      )..targetX = _playerPos.dx..targetY = _playerPos.dy);

      // 4. Pha Cuồng Nộ (< 50% HP): MƯA ĐẠN KÍN MÀN HÌNH - BẤT KHẢ THI
      if (isEnraged) {
        final oppA = -e.moveTimer * 8.5;
        for (int i = 0; i < 16; i++) {
          final a = oppA + (i * math.pi * 2.0 / 16.0);
          _bullets.add(Bullet(
            x: e.x,
            y: e.y + 50,
            vx: math.cos(a) * 380,
            vy: math.sin(a) * 380 + 150,
            isPlayer: false,
            damage: 50,
            radius: 7.5,
            color: const Color(0xFFFF3D00),
          ));
        }
        final dx = _playerPos.dx - e.x;
        final dy = _playerPos.dy - e.y;
        final ang = math.atan2(dy, dx);
        _bullets.add(Bullet(
          x: e.x,
          y: e.y + 40,
          vx: math.cos(ang) * 520,
          vy: math.sin(ang) * 520,
          isPlayer: false,
          damage: 55,
          radius: 8.0,
          color: const Color(0xFFFF0055),
        ));
      }
    }
  }

  // --- Enemy Destruction & Rewards ---
  void _destroyEnemy(Enemy e, int index) {
    _enemies.removeAt(index);
    _score += e.scoreValue;
    _addFloatingText(e.x, e.y, '+${e.scoreValue}', const Color(0xFFFFD600));

    // Explosions
    final isBoss = e.type == EnemyType.boss;
    _createExplosion(e.x, e.y, isBoss ? 65 : 20);
    if (isBoss) {
      _screenShake = 0.85;
      _flashOpacity = 0.0; // Triệt tiêu flash để tránh đục màn hình
    }

    // Power-Up Drops (Tăng tỷ lệ rơi đồ để người chơi nhanh chóng nâng cấp lại súng)
    final rand = math.Random();
    final dropChance = isBoss ? 1.0 : (e.type == EnemyType.heavyCruiser ? 0.85 : 0.40);

    if (rand.nextDouble() < dropChance) {
      final pType = PowerUpType.values[rand.nextInt(PowerUpType.values.length)];
      _powerUps.add(PowerUp(x: e.x, y: e.y, type: pType));
    }
  }

  // --- Collect Power-Ups ---
  void _collectPowerUp(PowerUp p) {
    HapticFeedback.mediumImpact();

    switch (p.type) {
      case PowerUpType.heal:
        _playerHealth = (_playerHealth + 35).clamp(0.0, _maxHealth);
        _addFloatingText(p.x, p.y, '+35 HP RESTORED!', const Color(0xFF00E676));
        break;

      case PowerUpType.shield:
        _playerShield = _maxShield;
        _addFloatingText(p.x, p.y, 'SHIELD RECHARGED 100%!', const Color(0xFF00E5FF));
        break;

      case PowerUpType.weapon:
        if (_weaponLevel < 6) {
          _weaponLevel++;
          _addFloatingText(p.x, p.y, 'SÚNG CẤP $_weaponLevel! (UPGRADED)', const Color(0xFFFFD600), scale: 1.25);
        } else {
          _score += 2000;
          _addFloatingText(p.x, p.y, '+2000 MAX WEAPON BONUS!', const Color(0xFFFFD600));
        }
        break;

      case PowerUpType.nuke:
        _bombCount = (_bombCount + 1).clamp(0, 5);
        _addFloatingText(p.x, p.y, '+1 EMP NUKE BOMB!', const Color(0xFFFF1744));
        break;

      case PowerUpType.drone:
        if (_drones.length < 2) {
          _drones.add(WingmanDrone(isLeft: _drones.isEmpty));
          _addFloatingText(p.x, p.y, '+1 DRONE VỆ TINH HỖ TRỢ!', const Color(0xFFE040FB), scale: 1.2);
        } else {
          _score += 1500;
          _addFloatingText(p.x, p.y, '+1500 DRONE BONUS!', const Color(0xFFE040FB));
        }
        break;

      case PowerUpType.overdrive:
        _overdriveTimer = 6.0; // 6s invulnerable super fire rate
        _addFloatingText(p.x, p.y, '*** OVERDRIVE GOD MODE (6s)! ***', const Color(0xFFFF9100), scale: 1.3);
        _screenShake = 0.5;
        break;
    }
  }

  // --- Player Damage ---
  void _damagePlayer(double dmg) {
    HapticFeedback.heavyImpact();
    _screenShake = 0.85;

    if (_playerShield > 0) {
      _playerShield -= dmg;
      if (_playerShield < 0) {
        _playerHealth += _playerShield;
        _playerShield = 0;
      }
    } else {
      _playerHealth -= dmg;
    }

    if (_playerHealth <= 0) {
      _playerHealth = 0;
      _isGameOver = true;
      _createExplosion(_playerPos.dx, _playerPos.dy, 45);
      setState(() {});
    }
  }

  // --- Skill 1: EMP Nuke Blast ---
  void _detonateBomb() {
    if (_bombCount <= 0 || _isGameOver) return;
    _bombCount--;
    _screenShake = 0.9;
    _flashOpacity = 0.40; // Soft cyber glow, khong bi choi trang
    HapticFeedback.heavyImpact();

    // Clear all enemy bullets
    _bullets.removeWhere((b) => !b.isPlayer);

    // Massive damage to all enemies
    for (int i = _enemies.length - 1; i >= 0; i--) {
      final e = _enemies[i];
      e.health -= (600 + _stage * 150.0);
      _createImpactSparks(e.x, e.y, const Color(0xFFFF1744));
      if (e.health <= 0) {
        _destroyEnemy(e, i);
      }
    }

    _particles.add(SpaceParticle(
      x: _screenSize.width / 2,
      y: _screenSize.height / 2,
      vx: 0,
      vy: 0,
      maxLife: 0.75,
      size: 500,
      color: const Color(0xFF00E5FF),
      isShockwave: true,
    ));

    _addFloatingText(_screenSize.width / 2, 400, '*** EMP SUPERNOVA BLAST! ***', const Color(0xFF00E5FF), scale: 1.3);
    setState(() {});
  }

  // --- VFX Helpers ---
  void _createExplosion(double x, double y, int count) {
    final rand = math.Random();
    _particles.add(SpaceParticle(
      x: x,
      y: y,
      vx: 0,
      vy: 0,
      maxLife: 0.5,
      size: 90,
      color: const Color(0xFFFF9100),
      isShockwave: true,
    ));

    for (int i = 0; i < count; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 70.0 + rand.nextDouble() * 240.0;
      _particles.add(SpaceParticle(
        x: x,
        y: y,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        maxLife: 0.4 + rand.nextDouble() * 0.45,
        size: 3.0 + rand.nextDouble() * 4.5,
        color: i % 2 == 0 ? const Color(0xFFFFD600) : const Color(0xFFFF3D00),
      ));
    }
  }

  void _createImpactSparks(double x, double y, Color color) {
    final rand = math.Random();
    for (int i = 0; i < 5; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final speed = 40.0 + rand.nextDouble() * 90.0;
      _particles.add(SpaceParticle(
        x: x,
        y: y,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        maxLife: 0.22,
        size: 2.2,
        color: color,
      ));
    }
  }

  void _addFloatingText(double x, double y, String text, Color color, {double scale = 1.0}) {
    _floatingTexts.add(FloatingText(x: x, y: y, text: text, color: color, scale: scale));
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Cosmic Canvas with Smooth 60-120fps Repaint Notifier
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                _isDragging = true;
                _targetPlayerPos = Offset(
                  details.localPosition.dx.clamp(30.0, _screenSize.width - 30.0),
                  (details.localPosition.dy - 35.0).clamp(80.0, _screenSize.height - 80.0),
                );
              },
              onPanUpdate: (details) {
                _targetPlayerPos = Offset(
                  details.localPosition.dx.clamp(30.0, _screenSize.width - 30.0),
                  (details.localPosition.dy - 35.0).clamp(80.0, _screenSize.height - 80.0),
                );
              },
              onPanEnd: (_) => _isDragging = false,
              onPanCancel: () => _isDragging = false,
              child: AnimatedBuilder(
                animation: _frameNotifier,
                builder: (context, _) {
                  return CustomPaint(
                    painter: SpacePainter(
                      stars: _stars,
                      nebulae: _nebulae,
                      particles: _particles,
                      bullets: _bullets,
                      powerUps: _powerUps,
                      enemies: _enemies,
                      floatingTexts: _floatingTexts,
                      drones: _drones,
                      playerPos: _playerPos,
                      playerHealth: _playerHealth,
                      maxHealth: _maxHealth,
                      playerShield: _playerShield,
                      maxShield: _maxShield,
                      weaponLevel: _weaponLevel,
                      isInvulnerable: _invulnerableTimer > 0,
                      isOverdrive: _overdriveTimer > 0,
                      animTime: _animTime,
                      screenShake: _screenShake,
                      flashOpacity: _flashOpacity,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Top HUD: Stage, HP, Shield, Score
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Back to Menu
                        InkWell(
                          onTap: widget.onExitToMenu,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.arrow_back, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('MENU', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),

                        // Stage Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _stage >= 8
                                  ? [const Color(0xFFFF1744), const Color(0xFFD500F9)]
                                  : [const Color(0xFF00E5FF), const Color(0xFF7C4DFF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: (_stage >= 8 ? Colors.red : Colors.cyan).withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            'STAGE $_stage/8',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                          ),
                        ),
                        const Spacer(),

                        // Score
                        Text(
                          '$_score',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Health & Shield Bars
                    Row(
                      children: [
                        // HP
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.favorite, color: Color(0xFFFF1744), size: 12),
                                  const SizedBox(width: 4),
                                  Text('HP ${_playerHealth.round()}', style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (_playerHealth / _maxHealth).clamp(0.0, 1.0),
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF1744)),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Shield
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield, color: Color(0xFF00E5FF), size: 12),
                                  const SizedBox(width: 4),
                                  Text('SHIELD ${_playerShield.round()}', style: const TextStyle(color: Color(0xFF80D8FF), fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (_playerShield / _maxShield).clamp(0.0, 1.0),
                                  backgroundColor: Colors.white12,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom Controls: Weapon Level & EMP Nuke Skill
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Weapon Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _weaponLevel >= 6 ? const Color(0xFFFFD600) : const Color(0xFF00E5FF),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bolt,
                        color: _weaponLevel >= 6 ? const Color(0xFFFFD600) : const Color(0xFF00E5FF),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _weaponLevel >= 6 ? 'SÚNG MAX (LV.6)' : 'SÚNG LV.$_weaponLevel',
                        style: TextStyle(
                          color: _weaponLevel >= 6 ? const Color(0xFFFFD600) : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (_drones.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFE040FB), borderRadius: BorderRadius.circular(4)),
                          child: Text('${_drones.length} DRONE', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),

                // EMP Nuke Button
                GestureDetector(
                  onTap: _detonateBomb,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _bombCount > 0
                            ? [const Color(0xFFFF1744), const Color(0xFFD500F9)]
                            : [Colors.grey.shade800, Colors.grey.shade900],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _bombCount > 0
                          ? [BoxShadow(color: const Color(0xFFFF1744).withValues(alpha: 0.5), blurRadius: 10)]
                          : [],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'BOM EMP ($_bombCount)',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. STAGE CLEAR DIALOG OVERLAY
          if (_isStageClear)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00E676), width: 2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00E676).withValues(alpha: 0.4), blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.military_tech, color: Color(0xFFFFD600), size: 54),
                        const SizedBox(height: 10),
                        Text(
                          'STAGE $_stage/8 HOÀN THÀNH!',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Đã hạ gục ${BossConfig.allBosses[(_stage - 1).clamp(0, 7)].name}',
                          style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Điểm hiện tại: $_score',
                          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _startNextStage,
                            icon: const Icon(Icons.arrow_forward),
                            label: Text(
                              'TIẾP TỤC: SANG BÀN ${_stage + 1}/8',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E676),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 6. ULTIMATE VICTORY (BEAT STAGE 8)
          if (_isGameVictory)
            Positioned.fill(
              child: Container(
                color: Colors.black87,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E0854), Color(0xFF131B2E)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 25),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 64),
                        const SizedBox(height: 10),
                        const Text(
                          'CHIẾN THẦN PHÁ ĐẢO VŨ TRỤ!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Vinh danh: Anh Khánh Đẹp Trai Nhất Vũ Trụ đã tiêu diệt Trùm Cuối Cấp 8 Bá Đạo Nhất!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'KỶ LỤC TỔNG ĐIỂM: $_score',
                          style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _startNewGame,
                            icon: const Icon(Icons.replay),
                            label: const Text('CHƠI LẠI TỪ CẤP 1', style: TextStyle(fontWeight: FontWeight.w900)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFD700),
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 7. GAME OVER OVERLAY
          if (_isGameOver)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.85),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF1744), width: 2),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF1744).withValues(alpha: 0.4), blurRadius: 20),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.warning, color: Color(0xFFFF1744), size: 52),
                        const SizedBox(height: 8),
                        const Text(
                          'CHIẾN CƠ BỊ PHÁ HỦY!',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Dừng bước tại: STAGE $_stage/10',
                          style: const TextStyle(color: Color(0xFFFF5252), fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Điểm số: $_score',
                          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onExitToMenu,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('MENU', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _startNewGame,
                                icon: const Icon(Icons.refresh),
                                label: const Text('HỒI SINH', style: TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF1744),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}