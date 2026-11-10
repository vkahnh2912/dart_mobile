import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/monster.dart';
import '../repositories/monster_repository.dart';
import '../services/api_service.dart';
import 'flappy_game.dart';
import 'spaceshooter/spaceshooter_game.dart';

class GameHubScreen extends StatefulWidget {
  const GameHubScreen({super.key});

  @override
  State<GameHubScreen> createState() => _GameHubScreenState();
}

class _GameHubScreenState extends State<GameHubScreen> {
  int? _selectedGame;
  int _selectedStartStage = 1;
  final MonsterRepository _monsterRepository = MonsterRepository();
  List<Monster> _monsters = [];
  Map<String, dynamic>? _playerProfile;
  bool _loadingDb = true;

  @override
  void initState() {
    super.initState();
    _loadGameDatabase();
  }

  Future<void> _loadGameDatabase() async {
    setState(() => _loadingDb = true);
    try {
      final monsters = await _monsterRepository.getAllMonsters();
      final player = await _monsterRepository.getPlayerProfile();
      final maxStage = ((player['current_stage'] as num?)?.toInt() ?? 1).clamp(
        1,
        8,
      );
      if (!mounted) return;
      setState(() {
        _monsters = monsters;
        _playerProfile = player;
        if (_selectedStartStage > maxStage) {
          _selectedStartStage = maxStage;
        }
        _loadingDb = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingDb = false);
    }
  }

  Future<void> _showPlayerRecordDialog() async {
    final playerName = (_playerProfile?['name'] ?? 'Vũ Trọng Khánh PM28.12')
        .toString();
    final highScore = ((_playerProfile?['high_score'] as num?)?.toInt() ?? 0);
    final highestStage =
        ((_playerProfile?['current_stage'] as num?)?.toInt() ?? 1).clamp(1, 8);

    final nameCtrl = TextEditingController(text: playerName);
    final scoreCtrl = TextEditingController(text: highScore.toString());
    final stageCtrl = TextEditingController(text: highestStage.toString());

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            '🏆 Cập nhật Kỷ Lục & Bàn Cao Nhất (players)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tên người chơi (name)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Điểm cao nhất (high_score)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bàn cao nhất đạt được (1 - 8)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newScore =
                    int.tryParse(scoreCtrl.text.trim()) ?? highScore;
                final newStage =
                    (int.tryParse(stageCtrl.text.trim()) ?? highestStage).clamp(
                      1,
                      8,
                    );
                await _monsterRepository.updatePlayerRecord(
                  name: nameCtrl.text,
                  highScore: newScore,
                  highestStage: newStage,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() => _selectedStartStage = newStage);
                await _loadGameDatabase();
              },
              child: const Text('LƯU KỶ LỤC'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showMonsterFormDialog({Monster? existing}) async {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(
      text: existing?.name ?? 'Purple Demon',
    );
    final hpCtrl = TextEditingController(
      text: (existing?.hp ?? 100).toString(),
    );
    final dmgCtrl = TextEditingController(
      text: (existing?.damage ?? 20).toString(),
    );
    final speedCtrl = TextEditingController(
      text: (existing?.speed ?? 2.0).toString(),
    );
    final scoreCtrl = TextEditingController(
      text: (existing?.score ?? 100).toString(),
    );
    final imageCtrl = TextEditingController(
      text: existing?.image ?? DatabaseHelper.purpleDemonAssetPath,
    );

    const presetSprites = [
      ('Tím (Purple)', 'assets/images/purple_demon.png'),
      ('Đỏ (Crimson)', 'assets/images/crimson_demon.png'),
      ('Băng (Cyber)', 'assets/images/cyber_demon.png'),
      ('Lục (Emerald)', 'assets/images/emerald_demon.png'),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final previewPath = imageCtrl.text.trim().isEmpty
                ? DatabaseHelper.purpleDemonAssetPath
                : imageCtrl.text.trim();

            return AlertDialog(
              title: Text(
                isEdit
                    ? 'Cập nhật Quái #${existing.id}'
                    : 'Thêm Quái mới (game.db)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0F1D),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE040FB).withValues(alpha: 0.6),
                          ),
                        ),
                        child: Image.asset(
                          previewPath,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.bug_report_rounded,
                            color: Color(0xFFE040FB),
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn nhanh giao diện quái đã cắt sẵn (nền trong suốt):',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: presetSprites.map((preset) {
                        final isSelected = previewPath == preset.$2;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              imageCtrl.text = preset.$2;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFE040FB)
                                  : const Color(0xFFE040FB).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              preset.$1,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF9333EA),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên quái (name)',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Máu (hp)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: dmgCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Sát thương (damage)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: speedCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Tốc độ (speed)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: scoreCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Điểm (score)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: imageCtrl,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Đường dẫn ảnh (image)',
                        helperText: 'Thư mục: assets/images/<ten_anh>.png',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('HỦY'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final monster = Monster(
                      id: existing?.id,
                      name: nameCtrl.text.trim().isEmpty
                          ? 'Purple Demon'
                          : nameCtrl.text.trim(),
                      hp: int.tryParse(hpCtrl.text.trim()) ?? 100,
                      damage: int.tryParse(dmgCtrl.text.trim()) ?? 20,
                      speed: double.tryParse(speedCtrl.text.trim()) ?? 2.0,
                      score: int.tryParse(scoreCtrl.text.trim()) ?? 100,
                      image: imageCtrl.text.trim().isEmpty
                          ? DatabaseHelper.purpleDemonAssetPath
                          : imageCtrl.text.trim(),
                    );
                    if (isEdit) {
                      await _monsterRepository.updateMonster(monster);
                    } else {
                      await _monsterRepository.addMonster(monster);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _loadGameDatabase();
                  },
                  child: Text(isEdit ? 'CẬP NHẬT' : 'THÊM QUÁI'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedGame == 1) {
      return FlappyGame(
        onExitToMenu: () {
          setState(() => _selectedGame = null);
          _loadGameDatabase();
        },
      );
    }

    if (_selectedGame == 2) {
      return SpaceShooterGame(
        initialStage: _selectedStartStage,
        onExitToMenu: () {
          setState(() => _selectedGame = null);
          _loadGameDatabase();
        },
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highScore = ((_playerProfile?['high_score'] as num?)?.toInt() ?? 0);
    final highestStage =
        ((_playerProfile?['current_stage'] as num?)?.toInt() ?? 1).clamp(1, 8);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0F1D)
          : const Color(0xFFF1F5F9),
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
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Banner Kỷ lục Điểm cao nhất & Bàn cao nhất từ SQLite (bảng players)
              _buildPlayerRecordBanner(isDark, highScore, highestStage),

              const SizedBox(height: 18),

              // Game 2 (Chiến cơ Galaxy - Lên đầu vì đây là game khủng nhất)
              _buildGameCard(
                isDark: isDark,
                title: 'CHIẾN CƠ GALAXY',
                badge: 'ARCADE SHOOTER | BULLET HELL',
                badgeColor: const Color(0xFF00E5FF),
                description:
                    'Lái chiến cơ không gian né bão đạn, nhặt đạn chùm, laser hủy diệt, tên lửa tầm nhiệt, thả bom EMP và hạ gục Đại Boss Galaxy Dreadnought (Level 1 - 8)!',
                buttonText: 'XUẤT KÍCH CHIẾN CƠ (BÀN $_selectedStartStage/8)',
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

              const SizedBox(height: 18),

              // SQLite game.db Section (Monsters & Players CRUD)
              _buildGameDatabaseCard(isDark),

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

  Widget _buildPlayerRecordBanner(
    bool isDark,
    int highScore,
    int highestStage,
  ) {
    final playerName = (_playerProfile?['name'] ?? 'Vũ Trọng Khánh PM28.12')
        .toString();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFFEF3C7), const Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFF59E0B),
                size: 26,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KỶ LỤC SQLITE: $playerName',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Tự động lưu Điểm cao nhất & Bàn cao nhất vào bảng players (game.db)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sửa kỷ lục / Mở khóa bàn',
                visualDensity: VisualDensity.compact,
                onPressed: _showPlayerRecordDialog,
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black26
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏆 ĐIỂM CAO NHẤT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$highScore',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black26
                        : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '⭐ BÀN CAO NHẤT',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'STAGE $highestStage / 8',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Chọn bàn xuất kích (Đã mở khóa tới Bàn $highestStage/8):',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(8, (index) {
                final stageNum = index + 1;
                final isUnlocked = stageNum <= highestStage;
                final isSelected = _selectedStartStage == stageNum;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      isUnlocked ? 'Bàn $stageNum' : '🔒 Bàn $stageNum',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (isUnlocked
                                  ? (isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A))
                                  : Colors.grey),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF0288D1),
                    onSelected: isUnlocked
                        ? (_) => setState(() => _selectedStartStage = stageNum)
                        : null,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameDatabaseCard(bool isDark) {
    final highScore = _playerProfile?['high_score'] ?? 0;
    final currentStage = _playerProfile?['current_stage'] ?? 1;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131B2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE040FB).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE040FB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storage_rounded,
                  color: Color(0xFFE040FB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SQLite game.db (Monsters & Players)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Kỷ lục: $highScore điểm • Bàn cao nhất: $currentStage/8 • Số quái: ${_monsters.length}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Thêm quái mới',
                onPressed: () => _showMonsterFormDialog(),
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Color(0xFFE040FB),
                ),
              ),
              IconButton(
                tooltip: 'Gọi API tải Quái vật mới vào game.db',
                onPressed: () async {
                  final apiMonsters = await ApiService.instance
                      .fetchMonstersFromOnlineApi();
                  for (final m in apiMonsters) {
                    await _monsterRepository.addMonster(m);
                  }
                  await _loadGameDatabase();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '🌐 Đã gọi API và nạp ${apiMonsters.length} Quái vật mới vào SQLite game.db!',
                        ),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    );
                  }
                },
                icon: const Icon(
                  Icons.cloud_download_rounded,
                  color: Color(0xFF3B82F6),
                ),
              ),
              IconButton(
                tooltip: 'Khôi phục Purple Demon mặc định',
                onPressed: () async {
                  await _monsterRepository.resetDefaultMonsters();
                  await _loadGameDatabase();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_loadingDb)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_monsters.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Chưa có quái trong bảng monsters. Nhấn nút làm mới để tạo Purple Demon.',
              ),
            )
          else
            ..._monsters.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE040FB).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        m.image,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFF4A148C),
                          child: const Icon(
                            Icons.bug_report_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${m.id ?? 1} ${m.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'HP: ${m.hp} | DMG: ${m.damage} | SPEED: ${m.speed}x | SCORE: ${m.score}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Sửa quái',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _showMonsterFormDialog(existing: m),
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 19,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Xóa quái',
                      visualDensity: VisualDensity.compact,
                      onPressed: () async {
                        if (m.id != null) {
                          await _monsterRepository.deleteMonster(m.id!);
                          await _loadGameDatabase();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 19,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
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
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFE2E8F0),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
