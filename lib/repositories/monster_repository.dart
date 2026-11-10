import '../database/database_helper.dart';
import '../models/monster.dart';

/// Repository quản lý truy vấn dữ liệu bảng `monsters` và `players` trong `game.db`.
/// Đóng gói các thao tác CRUD từ [DatabaseHelper].
class MonsterRepository {
  final DatabaseHelper _dbHelper;

  MonsterRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  // ===========================================================================
  // CRUD CHO MONSTERS
  // ===========================================================================

  /// 1. Thêm quái mới (Create)
  Future<int> addMonster(Monster monster) {
    return _dbHelper.insertMonster(monster);
  }

  /// Alias hỗ trợ tên hàm insertMonster
  Future<int> insertMonster(Monster monster) {
    return _dbHelper.insertMonster(monster);
  }

  /// 2. Lấy danh sách toàn bộ quái (Read All)
  Future<List<Monster>> getAllMonsters() {
    return _dbHelper.getMonsters();
  }

  /// Alias hỗ trợ tên hàm getMonsters
  Future<List<Monster>> getMonsters() {
    return _dbHelper.getMonsters();
  }

  /// 3. Lấy quái theo ID (Read By ID)
  Future<Monster?> getMonsterById(int id) {
    return _dbHelper.getMonsterById(id);
  }

  /// Lấy thông tin quái Purple Demon từ database (nếu chưa có sẽ trả về mẫu mặc định)
  Future<Monster> getPurpleDemon() async {
    final monsters = await _dbHelper.getMonsters();
    for (final m in monsters) {
      if (m.name.toLowerCase() == 'purple demon') {
        return m;
      }
    }
    if (monsters.isNotEmpty) {
      return monsters.first;
    }
    return DatabaseHelper.defaultPurpleDemon;
  }

  /// 4. Cập nhật thông tin quái (Update)
  Future<int> updateMonster(Monster monster) {
    return _dbHelper.updateMonster(monster);
  }

  /// 5. Xóa quái theo ID (Delete)
  Future<int> deleteMonster(int id) {
    return _dbHelper.deleteMonster(id);
  }

  /// Khôi phục quái mặc định Purple Demon nếu danh sách trống
  Future<void> resetDefaultMonsters() {
    return _dbHelper.resetDefaultMonsters();
  }

  // ===========================================================================
  // THÔNG TIN NGƯỜI CHƠI (BẢNG PLAYERS)
  // ===========================================================================

  Future<Map<String, dynamic>> getPlayerProfile() {
    return _dbHelper.getPlayerProfile();
  }

  Future<void> savePlayerProgress({
    String? name,
    required int hp,
    required int shield,
    required int weaponLevel,
    required int bombs,
    required int score,
    required int stage,
  }) {
    return _dbHelper.savePlayerProgress(
      name: name,
      hp: hp,
      shield: shield,
      weaponLevel: weaponLevel,
      bombs: bombs,
      score: score,
      stage: stage,
    );
  }

  Future<void> updatePlayerRecord({
    required String name,
    required int highScore,
    required int highestStage,
  }) {
    return _dbHelper.updatePlayerRecord(
      name: name,
      highScore: highScore,
      highestStage: highestStage,
    );
  }
}

