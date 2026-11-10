import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/note_model.dart';

class NoteDatabaseHelper {
  // Singleton Pattern chuẩn theo bài giảng TITV
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  static const String dbFileName = 'vutrongkhanh_notes.db';
  static const String tableNotes = 'notes';

  String _dbFullPath = 'vutrongkhanh_notes.db (SQLite Mobile)';
  String get dbFullPath => _dbFullPath;

  // Lưu nhật ký các câu lệnh SQL thực thi để hiển thị trực quan cho giảng viên kiểm tra
  final List<String> sqlLogs = [];

  // Fallback bộ nhớ tạm phòng trường hợp chạy trên trình duyệt Web
  bool _useMemoryFallback = false;
  final List<NoteItem> _memoryNotes = [];
  int _nextMemoryId = 1;

  void _addSqlLog(String sql) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    sqlLogs.insert(0, '[$timeStr] $sql');
    if (sqlLogs.length > 40) {
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
      _database = await _initDB(dbFileName);
      return _database!;
    } catch (e) {
      _useMemoryFallback = true;
      _addSqlLog('⚠️ Fallback In-Memory DB: $e');
      _seedMemoryIfNeeded();
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);
    _dbFullPath = path;
    _addSqlLog('OPEN DATABASE: $path (version: 1)');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const createTableSql = '''
CREATE TABLE $tableNotes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  priority INTEGER NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  createdAt TEXT NOT NULL
)''';
    await db.execute(createTableSql);
    _addSqlLog('EXECUTE: CREATE TABLE $tableNotes (...)');

    // Khởi tạo dữ liệu mẫu ban đầu cho anh Khánh đẹp trai nhất vũ trụ
    final samples = _defaultSampleNotes();
    for (final note in samples) {
      await db.insert(tableNotes, note.toMap());
    }
    _addSqlLog('SEED DATA: Đã thêm ${samples.length} bản ghi mẫu vào bảng $tableNotes');
  }

  List<NoteItem> _defaultSampleNotes() {
    return const [
      NoteItem(
        title: 'Hoàn thành bài thực hành SQLite (sqflite) Flutter',
        content: 'Thiết kế Model NoteItem (toMap/fromMap), DatabaseHelper Singleton và đầy đủ 4 thao tác CRUD (Insert, Query, Update, Delete).',
        category: 'Dự án Flutter',
        priority: 3,
        isCompleted: true,
        createdAt: '03/11/2026 08:30',
      ),
      NoteItem(
        title: 'Ôn tập Form & Validation (GlobalKey<FormState>)',
        content: 'Kiểm tra dữ liệu đầu vào với TextFormField, validator và kết hợp lưu trữ trực tiếp xuống cơ sở dữ liệu SQLite cục bộ.',
        category: 'Học tập',
        priority: 2,
        isCompleted: true,
        createdAt: '03/11/2026 08:45',
      ),
      NoteItem(
        title: 'Nâng cấp siêu phẩm Game Chiến Cơ Galaxy Cấp 8',
        content: 'Cập nhật giao diện Quái Tinh Thể Độc Nhãn Tím, đạn kim cương đỏ và tốc độ bay x2 dành riêng cho anh Khánh PM28.12.',
        category: 'Dự án Flutter',
        priority: 3,
        isCompleted: false,
        createdAt: '03/11/2026 09:00',
      ),
      NoteItem(
        title: 'Chuẩn bị báo cáo đồ án lập trình thiết bị di động',
        content: 'Demo trực tiếp trên máy ảo Android Pixel: Chạy tự động chuỗi bài tập Dart/Flutter TITV và thao tác thêm/sửa/xóa SQLite.',
        category: 'Công việc',
        priority: 2,
        isCompleted: false,
        createdAt: '03/11/2026 09:15',
      ),
    ];
  }

  void _seedMemoryIfNeeded() {
    if (_memoryNotes.isEmpty) {
      for (final item in _defaultSampleNotes()) {
        _memoryNotes.add(item.copyWith(id: _nextMemoryId++));
      }
      _addSqlLog('MEMORY DB: Khởi tạo ${_memoryNotes.length} ghi chú mẫu');
    }
  }

  // 1. CREATE - Thêm ghi chú mới (INSERT INTO notes)
  Future<NoteItem> insertNote(NoteItem note) async {
    final db = await database;
    if (db == null) {
      final created = note.copyWith(id: _nextMemoryId++);
      _memoryNotes.insert(0, created);
      _addSqlLog('INSERT INTO $tableNotes VALUES ("${note.title}", category="${note.category}") -> id=${created.id}');
      return created;
    }

    final id = await db.insert(
      tableNotes,
      note.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _addSqlLog('INSERT INTO $tableNotes (title, category, priority) VALUES ("${note.title}", "${note.category}", ${note.priority}) -> rowId=$id');
    return note.copyWith(id: id);
  }

  // 2. READ - Truy vấn danh sách ghi chú (SELECT * FROM notes)
  Future<List<NoteItem>> getAllNotes({
    String? searchQuery,
    String? category,
    bool? isCompleted,
  }) async {
    final db = await database;
    if (db == null) {
      var list = List<NoteItem>.from(_memoryNotes);
      if (category != null && category != 'Tất cả') {
        list = list.where((n) => n.category == category).toList();
      }
      if (isCompleted != null) {
        list = list.where((n) => n.isCompleted == isCompleted).toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        list = list
            .where((n) =>
                n.title.toLowerCase().contains(q) ||
                n.content.toLowerCase().contains(q))
            .toList();
      }
      _addSqlLog('SELECT * FROM $tableNotes ORDER BY priority DESC, id DESC -> ${list.length} rows');
      return list;
    }

    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    if (category != null && category != 'Tất cả') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }
    if (isCompleted != null) {
      whereClauses.add('isCompleted = ?');
      whereArgs.add(isCompleted ? 1 : 0);
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR content LIKE ?)');
      final pattern = '%${searchQuery.trim()}%';
      whereArgs.add(pattern);
      whereArgs.add(pattern);
    }

    final whereString = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final maps = await db.query(
      tableNotes,
      where: whereString,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'isCompleted ASC, priority DESC, id DESC',
    );

    _addSqlLog(
      'SELECT * FROM $tableNotes ${whereString != null ? "WHERE $whereString " : ""}ORDER BY isCompleted ASC, priority DESC, id DESC -> ${maps.length} rows',
    );

    return maps.map((m) => NoteItem.fromMap(m)).toList();
  }

  // 3. UPDATE - Cập nhật ghi chú (UPDATE notes SET ... WHERE id = ?)
  Future<int> updateNote(NoteItem note) async {
    final db = await database;
    if (db == null) {
      final idx = _memoryNotes.indexWhere((n) => n.id == note.id);
      if (idx != -1) {
        _memoryNotes[idx] = note;
      }
      _addSqlLog('UPDATE $tableNotes SET title="${note.title}", isCompleted=${note.isCompleted ? 1 : 0} WHERE id=${note.id}');
      return 1;
    }

    final rows = await db.update(
      tableNotes,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    _addSqlLog('UPDATE $tableNotes SET title="${note.title}", priority=${note.priority}, isCompleted=${note.isCompleted ? 1 : 0} WHERE id = ${note.id} -> $rows row(s)');
    return rows;
  }

  // 4. DELETE - Xóa ghi chú theo ID (DELETE FROM notes WHERE id = ?)
  Future<int> deleteNote(int id) async {
    final db = await database;
    if (db == null) {
      _memoryNotes.removeWhere((n) => n.id == id);
      _addSqlLog('DELETE FROM $tableNotes WHERE id = $id');
      return 1;
    }

    final rows = await db.delete(
      tableNotes,
      where: 'id = ?',
      whereArgs: [id],
    );
    _addSqlLog('DELETE FROM $tableNotes WHERE id = $id -> $rows row(s)');
    return rows;
  }

  // 5. Khôi phục lại dữ liệu mẫu (DELETE + INSERT)
  Future<void> resetSampleData() async {
    final db = await database;
    if (db == null) {
      _memoryNotes.clear();
      _seedMemoryIfNeeded();
      return;
    }

    await db.delete(tableNotes);
    _addSqlLog('DELETE FROM $tableNotes (Xóa toàn bộ bảng để nạp lại dữ liệu mẫu)');
    final samples = _defaultSampleNotes();
    for (final note in samples) {
      await db.insert(tableNotes, note.toMap());
    }
    _addSqlLog('INSERT ${samples.length} sample rows INTO $tableNotes');
  }
}

