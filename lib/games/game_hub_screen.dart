import 'package:flutter/material.dart';
import 'flappy_game.dart';
import 'spaceshooter/spaceshooter_game.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  int? _selectedGame;

  @override
  Widget build(BuildContext context) {
    if (_selectedGame == 1) {
      return FlappyGame(
        onExitToMenu: () => setState(() => _selectedGame = null),
      );
    }

    if (_selectedGame == 2) {
      return SpaceShooterGame(
        onExitToMenu: () => setState(() => _selectedGame = null),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1D) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.15),
                        border: Border.all(
                          color: const Color(0xFFFFD54F),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.videogame_asset_rounded,
                        color: Color(0xFFFFD54F),
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'VuTrongKhanh.PM28.12 🎮',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.8,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Game Arcade đỉnh cao dành riêng cho Anh Khánh',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Game 2 (Chiến cơ Galaxy - Lên đầu vì đây là game khủng nhất)
              _buildGameCard(
                isDark: isDark,
                title: 'CHIẾN CƠ GALAXY',
                badge: 'ARCADE SHOOTER | BULLET HELL',
                badgeColor: const Color(0xFF00E5FF),
                description:
                    'Lái chiến cơ không gian né bão đạn, nhặt đạn chùm, laser hủy diệt, tên lửa tầm nhiệt, thả bom EMP và hạ gục Đại Boss Galaxy Dreadnought (Level 1 - 8)!',
                buttonText: 'XUẤT KÍCH CHIẾN CƠ',
                buttonColor: const Color(0xFF0288D1),
                icon: Icons.rocket_launch_rounded,
                onPlay: () => setState(() => _selectedGame = 2),
              ),

              const SizedBox(height: 18),

              // Game 1 (Flappy Fly)
              _buildGameCard(
                isDark: isDark,
                title: 'FLAPPY FLY',
                badge: '2D RETRO | 60 FPS',
                badgeColor: const Color(0xFF4CAF50),
                description:
                    'Bay lượn qua các đường ống cống xanh retro, chạm nhảy tính điểm kỷ lục và săn huy chương Vàng / Bạch Kim.',
                buttonText: 'CHƠI FLAPPY FLY',
                buttonColor: const Color(0xFF2E7D32),
                icon: Icons.flight_takeoff_rounded,
                onPlay: () => setState(() => _selectedGame = 1),
              ),

              const SizedBox(height: 28),

              // Footer
              Center(
                child: Text(
                  '⚡ Tích hợp cùng Khóa học Dart & Không Gian Code của Anh Khánh',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required bool isDark,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required IconData icon,
    required VoidCallback onPlay,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: badgeColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: badgeColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF475569),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  letterSpacing: 0.8,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
