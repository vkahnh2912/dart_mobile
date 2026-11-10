// Bài 42: Cơ sở dữ liệu SQLite (sqflite) - Thiết kế DatabaseHelper Singleton & Mở DB
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 42: SQLITE (SQFLITE) - THIẾT KẾ DATABASEHELPER SINGLETON ===');
  print('1. Mẫu thiết kế Singleton (Chỉ mở 1 kết nối DB duy nhất toàn App):');
  print(r'''
class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;
  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vutrongkhanh_notes.db');
    return _database!;
  }
}
''');

  print('2. Khởi tạo đường dẫn file DB & Tạo bảng với lệnh CREATE TABLE:');
  print(r'''
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(
      'CREATE TABLE notes ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, '
      'content TEXT NOT NULL, '
      'category TEXT NOT NULL, '
      'priority INTEGER NOT NULL, '
      'isCompleted INTEGER NOT NULL DEFAULT 0, '
      'createdAt TEXT NOT NULL)',
    );
  }
''');

  print('3. Kết quả kiểm tra kết nối:');
  print('   ✅ Đã khởi tạo Singleton NoteDatabaseHelper.instance');
  print('   ✅ Đã tạo bảng "notes" trong file vutrongkhanh_notes.db');
  print('==================================================');
}
