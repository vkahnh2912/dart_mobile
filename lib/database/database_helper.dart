import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/monster.dart';

class DatabaseHelper {
  // Singleton Pattern
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  static const String databaseName = 'game.db';
  static const int databaseVersion = 1;

  static const String tableMonsters = 'monsters';
  static const String tablePlayers = 'players';

  String get databasePath => _databasePath;
  String _databasePath = 'game.db';

  // Lưu nhật ký các câu lệnh SQL thực thi trên game.db
  final List<String> sqlLogs = [];

  // Fallback bộ nhớ tạm khi chạy trên nền tảng không hỗ trợ tệp SQLite cục bộ (như Web)
  bool _useMemoryFallback = false;
  final List<Monster> _memoryMonsters = [];
  Map<String, dynamic> _memoryPlayer = {
    'id': 1,
    'name': 'Vũ Trọng Khánh PM28.12',
    'hp': 100,
    'max_hp': 100,
    'shield': 100,
    'weapon_level': 1,
    'bombs': 3,
    'high_score': 0,
    'current_stage': 1,
    'updated_at': '2026-11-03',
  };
  int _nextMemoryMonsterId = 1;

  // Mẫu quái Purple Demon mặc định theo yêu cầu
  static const String purpleDemonAssetPath = 'assets/images/purple_demon.png';
  static const Monster defaultPurpleDemon = Monster(
    name: 'Purple Demon',
    hp: 100,
    damage: 20,
    speed: 2.0,
    score: 100,
    image: purpleDemonAssetPath,
  );

  void _logSql(String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    sqlLogs.insert(0, '[$timeStr] $message');
    if (sqlLogs.length > 50) {
      sqlLogs.removeLast();
    }
  }

  Future<Database?> get database async {
    if (_useMemoryFallback) return null;
    if (_database != null) return _database!;

    if (kIsWeb) {
      _useMemoryFallback = true;
      _seedMemoryIfNeeded();
      return null;
    }

    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      _useMemoryFallback = true;
      _logSql('Fallback In-Memory game.db: $e');
      _seedMemoryIfNeeded();
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    final dbDir = await getDatabasesPath();
    final fullPath = p.join(dbDir, databaseName);
    _databasePath = fullPath;
    _logSql('OPEN DATABASE: $fullPath (v$databaseVersion)');

    return await openDatabase(
      fullPath,
      version: databaseVersion,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Đảm bảo bảng monsters luôn có ít nhất Purple Demon nếu bảng đang trống
        final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableMonsters'),
        );
        if ((count ?? 0) == 0) {
          await db.insert(tableMonsters, defaultPurpleDemon.toMap());
          _logSql(
            'SEED: Đã thêm Purple Demon mặc định vào bảng $tableMonsters',
          );
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tạo bảng `monsters` theo đúng cấu trúc yêu cầu
    await db.execute('''
      CREATE TABLE $tableMonsters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        hp INTEGER,
        damage INTEGER,
        speed REAL,
        score INTEGER,
        image TEXT
      )
    ''');
    _logSql(
      'CREATE TABLE $tableMonsters (id, name, hp, damage, speed, score, image)',
    );

    // 2. Tạo bảng `players` để lưu thông tin người chơi
    await db.execute('''
      CREATE TABLE $tablePlayers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        hp INTEGER,
        max_hp INTEGER,
        shield INTEGER,
        weapon_level INTEGER,
        bombs INTEGER,
        high_score INTEGER,
        current_stage INTEGER,
        updated_at TEXT
      )
    ''');
    _logSql(
      'CREATE TABLE $tablePlayers (id, name, hp, max_hp, shield, weapon_level, bombs, high_score, current_stage, updated_at)',
    );

    // 3. Thêm con quái Purple Demon vừa thiết kế vào database mẫu
    await db.insert(
      tableMonsters,
      defaultPurpleDemon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _logSql('INSERT INTO $tableMonsters: ${defaultPurpleDemon.toMap()}');

    // 4. Thêm thông tin người chơi mặc định vào bảng `players`
    await db.insert(tablePlayers, {
      'name': 'Vũ Trọng Khánh PM28.12',
      'hp': 100,
      'max_hp': 100,
      'shield': 100,
      'weapon_level': 1,
      'bombs': 3,
      'high_score': 0,
      'current_stage': 1,
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    _logSql(
      'INSERT INTO $tablePlayers: Vũ Trọng Khánh PM28.12 (HP: 100, Shield: 100)',
    );
  }

  void _seedMemoryIfNeeded() {
    if (_memoryMonsters.isEmpty) {
      _memoryMonsters.add(
        defaultPurpleDemon.copyWith(id: _nextMemoryMonsterId++),
      );
    }
  }

  // ===========================================================================
  // CRUD ĐẦY ĐỦ CHO BẢNG `monsters`
  // ===========================================================================

  /// 1. Thêm quái mới vào bảng `monsters`
  Future<int> insertMonster(Monster monster) async {
    final db = await database;
    if (db == null) {
      final newId = _nextMemoryMonsterId++;
      _memoryMonsters.add(monster.copyWith(id: newId));
      _logSql('INSERT INTO $tableMonsters: ${monster.name} -> id=$newId');
      return newId;
    }

    final id = await db.insert(
      tableMonsters,
      monster.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _logSql(
      'INSERT INTO $tableMonsters (name="${monster.name}", hp=${monster.hp}, damage=${monster.damage}, speed=${monster.speed}, score=${monster.score}) -> id=$id',
    );
    return id;
  }

  /// 2. Lấy toàn bộ danh sách quái từ bảng `monsters`
  Future<List<Monster>> getMonsters() async {
    final db = await database;
    if (db == null) {
      _seedMemoryIfNeeded();
      _logSql('SELECT * FROM $tableMonsters -> ${_memoryMonsters.length} rows');
      return List<Monster>.from(_memoryMonsters);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableMonsters,
      orderBy: 'id ASC',
    );
    _logSql(
      'SELECT * FROM $tableMonsters ORDER BY id ASC -> ${maps.length} rows',
    );
    return maps.map((map) => Monster.fromMap(map)).toList();
  }

  /// 3. Lấy thông tin 1 con quái theo `id`
  Future<Monster?> getMonsterById(int id) async {
    final db = await database;
    if (db == null) {
      _seedMemoryIfNeeded();
      for (final m in _memoryMonsters) {
        if (m.id == id) return m;
      }
      return null;
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tableMonsters,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    _logSql(
      'SELECT * FROM $tableMonsters WHERE id = $id -> ${maps.isNotEmpty ? "Found" : "Not Found"}',
    );
    if (maps.isNotEmpty) {
      return Monster.fromMap(maps.first);
    }
    return null;
  }

  /// 4. Cập nhật thông tin quái trong bảng `monsters`
  Future<int> updateMonster(Monster monster) async {
    if (monster.id == null) return 0;
    final db = await database;
    if (db == null) {
      final idx = _memoryMonsters.indexWhere((m) => m.id == monster.id);
      if (idx != -1) {
        _memoryMonsters[idx] = monster;
        _logSql(
          'UPDATE $tableMonsters SET name="${monster.name}", hp=${monster.hp}, speed=${monster.speed} WHERE id=${monster.id}',
        );
        return 1;
      }
      return 0;
    }

    final rows = await db.update(
      tableMonsters,
      monster.toMap(),
      where: 'id = ?',
      whereArgs: [monster.id],
    );
    _logSql(
      'UPDATE $tableMonsters SET name="${monster.name}", hp=${monster.hp}, damage=${monster.damage}, speed=${monster.speed}, score=${monster.score} WHERE id = ${monster.id} -> $rows row(s)',
    );
    return rows;
  }

  /// 5. Xóa quái khỏi bảng `monsters` theo `id`
  Future<int> deleteMonster(int id) async {
    final db = await database;
    if (db == null) {
      _memoryMonsters.removeWhere((m) => m.id == id);
      _logSql('DELETE FROM $tableMonsters WHERE id = $id');
      return 1;
    }

    final rows = await db.delete(
      tableMonsters,
      where: 'id = ?',
      whereArgs: [id],
    );
    _logSql('DELETE FROM $tableMonsters WHERE id = $id -> $rows row(s)');
    return rows;
  }

  /// Khôi phục dữ liệu mẫu `Purple Demon`
  Future<void> resetDefaultMonsters() async {
    final db = await database;
    if (db == null) {
      _memoryMonsters.clear();
      _nextMemoryMonsterId = 1;
      _seedMemoryIfNeeded();
      return;
    }

    await db.delete(tableMonsters);
    await db.insert(tableMonsters, defaultPurpleDemon.toMap());
    _logSql(
      'RESET $tableMonsters: Khôi phục Purple Demon (hp: 100, damage: 20, speed: 2.0, score: 100)',
    );
  }

  // ===========================================================================
  // THAO TÁC BẢNG `players` (LƯU THÔNG TIN NGƯỜI CHƠI & ĐIỂM KỶ LỤC)
  // ===========================================================================

  Future<Map<String, dynamic>> getPlayerProfile() async {
    final db = await database;
    if (db == null) {
      return Map<String, dynamic>.from(_memoryPlayer);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tablePlayers,
      orderBy: 'id ASC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }

    final defaultPlayer = {
      'name': 'Vũ Trọng Khánh PM28.12',
      'hp': 100,
      'max_hp': 100,
      'shield': 100,
      'weapon_level': 1,
      'bombs': 3,
      'high_score': 0,
      'current_stage': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    final id = await db.insert(tablePlayers, defaultPlayer);
    return {...defaultPlayer, 'id': id};
  }

  Future<void> savePlayerProgress({
    String? name,
    required int hp,
    required int shield,
    required int weaponLevel,
    required int bombs,
    required int score,
    required int stage,
  }) async {
    final current = await getPlayerProfile();
    final currentHigh = (current['high_score'] as num?)?.toInt() ?? 0;
    final newHighScore = score > currentHigh ? score : currentHigh;
    final currentMaxStage = (current['current_stage'] as num?)?.toInt() ?? 1;
    final newHighestStage = (stage > currentMaxStage ? stage : currentMaxStage)
        .clamp(1, 8);
    final playerId = (current['id'] as num?)?.toInt() ?? 1;

    final updated = {
      'name': name ?? current['name'] ?? 'Vũ Trọng Khánh PM28.12',
      'hp': hp,
      'max_hp': 100,
      'shield': shield,
      'weapon_level': weaponLevel,
      'bombs': bombs,
      'high_score': newHighScore,
      'current_stage': newHighestStage,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final db = await database;
    if (db == null) {
      _memoryPlayer = {...updated, 'id': playerId};
      return;
    }

    await db.update(
      tablePlayers,
      updated,
      where: 'id = ?',
      whereArgs: [playerId],
    );
    _logSql(
      'UPDATE $tablePlayers SET high_score=$newHighScore, current_stage=$newHighestStage, hp=$hp WHERE id=$playerId',
    );
  }

  /// Cập nhật trực tiếp kỷ lục điểm số & bàn cao nhất của người chơi trong bảng `players`
  Future<void> updatePlayerRecord({
    required String name,
    required int highScore,
    required int highestStage,
  }) async {
    final current = await getPlayerProfile();
    final playerId = (current['id'] as num?)?.toInt() ?? 1;
    final clampedStage = highestStage.clamp(1, 8);

    final updated = {
      'name': name.trim().isEmpty ? 'Vũ Trọng Khánh PM28.12' : name.trim(),
      'hp': (current['hp'] as num?)?.toInt() ?? 100,
      'max_hp': 100,
      'shield': (current['shield'] as num?)?.toInt() ?? 100,
      'weapon_level': (current['weapon_level'] as num?)?.toInt() ?? 1,
      'bombs': (current['bombs'] as num?)?.toInt() ?? 3,
      'high_score': highScore < 0 ? 0 : highScore,
      'current_stage': clampedStage,
      'updated_at': DateTime.now().toIso8601String(),
    };

    final db = await database;
    if (db == null) {
      _memoryPlayer = {...updated, 'id': playerId};
      return;
    }

    await db.update(
      tablePlayers,
      updated,
      where: 'id = ?',
      whereArgs: [playerId],
    );
    _logSql(
      'UPDATE $tablePlayers SET name="${updated['name']}", high_score=$highScore, current_stage=$clampedStage WHERE id=$playerId',
    );
  }
}
