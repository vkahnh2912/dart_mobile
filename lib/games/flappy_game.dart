import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'bird.dart';
import 'pipe.dart';
import 'particle.dart';
import 'score_manager.dart';
import 'game_painter.dart';
import 'audio/audio_manager.dart';

enum GameState { ready, playing, gameOver }

class FlappyGame extends StatefulWidget {
  final VoidCallback? onExitToMenu;
  const FlappyGame({super.key, this.onExitToMenu});

  @override
  State<FlappyGame> createState() => _FlappyGameState();
}

class _FlappyGameState extends State<FlappyGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  GameState _state = GameState.ready;
  final Bird _bird = Bird();
  final List<Pipe> _pipes = [];
  final List<Particle> _particles = [];
  final ScoreManager _scoreManager = ScoreManager();

  double _groundOffset = 0.0;
  double _cloudOffset = 0.0;
  double _pipeSpawnTimer = 0.0;
  final double _gameSpeed = 125.0;
  bool _isNight = false;
  double _flashOpacity = 0.0;

  // Score pop animation
  double _scoreScale = 1.0;

  @override
  void initState() {
    super.initState();
    _scoreManager.init().then((_) {
      if (mounted) setState(() {});
    });

    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_lastElapsed == Duration.zero) {
      _lastElapsed = elapsed;
      return;
    }

    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    final double clampedDt = dt.clamp(0.001, 0.05);

    _updateGame(clampedDt);
  }

  void _updateGame(double dt) {
    if (_flashOpacity > 0.0) {
      _flashOpacity = math.max(0.0, _flashOpacity - dt * 4.0);
    }

    _cloudOffset += dt * 14.0;
    _particles.removeWhere((p) => !p.update(dt));

    if (_scoreScale > 1.0) {
      _scoreScale = math.max(1.0, _scoreScale - dt * 3.0);
    }

    if (_state == GameState.ready) {
      _bird.updateIdle(dt);
      _groundOffset += _gameSpeed * dt;
    } else if (_state == GameState.playing) {
      _bird.update(dt);
      _groundOffset += _gameSpeed * dt;

      _pipeSpawnTimer += dt;
      if (_pipeSpawnTimer > 1.75) {
        _pipeSpawnTimer = 0.0;
        _spawnPipe();
      }

      final birdBox = _bird.hitBox;

      if (_bird.y + Bird.radiusY >= GamePainter.groundY) {
        _bird.y = GamePainter.groundY - Bird.radiusY;
        _triggerGameOver();
        return;
      }

      if (_bird.y - Bird.radiusY <= 0) {
        _bird.y = Bird.radiusY;
        _bird.vy = 0;
      }

      for (int i = _pipes.length - 1; i >= 0; i--) {
        final pipe = _pipes[i];
        pipe.update(dt, _gameSpeed);

        if (!pipe.isPassed && pipe.x + Pipe.width < _bird.x) {
          pipe.isPassed = true;
          _scoreManager.addPoint();
          _scoreScale = 1.35;
          AudioManager.playPoint();
        }

        if (pipe.collidesWith(birdBox, GamePainter.groundY)) {
          _triggerGameOver();
          return;
        }

        if (pipe.x + Pipe.width < -30) {
          _pipes.removeAt(i);
        }
      }
    } else if (_state == GameState.gameOver) {
      if (_bird.y + Bird.radiusY < GamePainter.groundY) {
        _bird.update(dt);
        if (_bird.y + Bird.radiusY >= GamePainter.groundY) {
          _bird.y = GamePainter.groundY - Bird.radiusY;
          _bird.vy = 0;
        }
      }
    }

    setState(() {});
  }

  void _spawnPipe() {
    final random = math.Random();
    final topH = 70.0 + random.nextDouble() * 200.0;
    _pipes.add(Pipe(x: GamePainter.virtualWidth + 20, topHeight: topH));
  }

  void _flap() {
    if (_state == GameState.ready) {
      _state = GameState.playing;
      _scoreManager.reset();
      _pipes.clear();
      _spawnPipe();
      _bird.jump();
      _particles.addAll(Particle.createJumpBurst(_bird.x, _bird.y));
      AudioManager.playFlap();
    } else if (_state == GameState.playing) {
      _bird.jump();
      _particles.addAll(Particle.createJumpBurst(_bird.x, _bird.y));
      AudioManager.playFlap();
    }
  }

  void _triggerGameOver() {
    if (_state == GameState.gameOver) return;
    _state = GameState.gameOver;
    _flashOpacity = 0.8;
    AudioManager.playHit();
    Future.delayed(const Duration(milliseconds: 140), () {
      AudioManager.playDie();
    });
  }

  void _restart() {
    setState(() {
      _state = GameState.ready;
      _bird.reset(280.0);
      _pipes.clear();
      _particles.clear();
      _pipeSpawnTimer = 0.0;
      _scoreManager.reset();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isNight = !_isNight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.arrowUp) {
              if (_state == GameState.gameOver) {
                _restart();
              } else {
                _flap();
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            if (_state != GameState.gameOver) {
              _flap();
            }
          },
          child: Stack(
            children: [
              // 1. Core 60fps Game Canvas
              Positioned.fill(
                child: CustomPaint(
                  painter: GamePainter(
                    bird: _bird,
                    pipes: _pipes,
                    particles: _particles,
                    groundOffset: _groundOffset,
                    cloudOffset: _cloudOffset,
                    isNight: _isNight,
                    flashOpacity: _flashOpacity,
                  ),
                ),
              ),

              // 2. Safe Top Navigation Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back to Menu Button
                        if (widget.onExitToMenu != null)
                          _buildNavPill(
                            icon: Icons.arrow_back_rounded,
                            label: 'MENU',
                            onTap: widget.onExitToMenu!,
                          )
                        else
                          const SizedBox.shrink(),

                        // Day/Night Toggle
                        _buildNavPill(
                          icon: _isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                          label: _isNight ? 'DEM' : 'NGAY',
                          iconColor: _isNight ? const Color(0xFF80D8FF) : const Color(0xFFFFD54F),
                          onTap: _toggleTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Ready State Overlay
              if (_state == GameState.ready)
                Positioned.fill(
                  child: _buildReadyOverlay(),
                ),

              // 4. In-Game Live Score Counter
              if (_state == GameState.playing)
                Positioned(
                  top: 75,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.scale(
                      scale: _scoreScale,
                      child: Text(
                        '${_scoreManager.currentScore}',
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // 5. Game Over Scoreboard Modal
              if (_state == GameState.gameOver)
                Positioned.fill(
                  child: _buildGameOverOverlay(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavPill({
    required IconData icon,
    required String label,
    Color iconColor = Colors.white,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyOverlay() {
    return IgnorePointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          // Logo Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'FLAPPY FLY',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2.5,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(height: 180),
          // Instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.touch_app_rounded, color: Color(0xFFFFD54F), size: 18),
                SizedBox(width: 8),
                Text(
                  'CHẠM ĐỂ BAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1.0,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'KỶ LỤC: ${_scoreManager.bestScore}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.8,
              decoration: TextDecoration.none,
              shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final medal = _scoreManager.getMedal();

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Modern Title
              const Text(
                'KẾT THÚC',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Color(0xFFF43F5E),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Vòng chơi đã kết thúc',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white54,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 18),

              // Score Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Medal
                    Column(
                      children: [
                        const Text(
                          'HUY CHƯƠNG',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            letterSpacing: 0.8,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMedalBadge(medal),
                      ],
                    ),
                    Container(height: 48, width: 1, color: Colors.white12),
                    // Scores
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'ĐIỂM SỐ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white54,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Text(
                          '${_scoreManager.currentScore}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (_scoreManager.isNewHighScore)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'MỚI',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),
                            const Text(
                              'KỶ LỤC: ',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white54,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Text(
                              '${_scoreManager.bestScore}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFB300),
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Button 1: CHƠI LẠI
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: const Text(
                    'CHƠI LẠI',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Button 2: QUAY VỀ MENU (Back to Game Hub)
              if (widget.onExitToMenu != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onExitToMenu,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.home_rounded, size: 18, color: Colors.white70),
                    label: const Text(
                      'VỀ MENU CHỌN GAME',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedalBadge(String medal) {
    Color col;
    IconData icon;
    switch (medal) {
      case 'PLATINUM':
        col = const Color(0xFF00E5FF);
        icon = Icons.workspace_premium;
        break;
      case 'GOLD':
        col = const Color(0xFFFFD700);
        icon = Icons.emoji_events;
        break;
      case 'SILVER':
        col = const Color(0xFFC0C0C0);
        icon = Icons.military_tech;
        break;
      case 'BRONZE':
        col = const Color(0xFFCD7F32);
        icon = Icons.shield;
        break;
      default:
        col = Colors.white24;
        icon = Icons.lock_outline;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: col.withValues(alpha: 0.2),
        border: Border.all(color: col, width: 2),
      ),
      child: Icon(icon, color: col, size: 22),
    );
  }
}