// Bài 43: Cơ sở dữ liệu SQLite (sqflite) - Thực hành 4 thao tác CRUD (Insert, Query, Update, Delete)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 43: SQLITE (SQFLITE) - THỰC HÀNH CRUD (INSERT, QUERY, UPDATE, DELETE) ===');

  print('1. CREATE - Thêm bản ghi mới (db.insert):');
  print('   final id = await db.insert("notes", note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);');
  print('   -> SQL tương đương: INSERT INTO notes (title, content, category, priority) VALUES (?, ?, ?, ?)');

  print('\n2. READ - Truy vấn & Tìm kiếm danh sách (db.query):');
  print('   final maps = await db.query("notes", where: "title LIKE ?", whereArgs: ["%Flutter%"], orderBy: "id DESC");');
  print('   -> SQL tương đương: SELECT * FROM notes WHERE title LIKE "%Flutter%" ORDER BY id DESC');

  print('\n3. UPDATE - Cập nhật bản ghi theo khóa chính id (db.update):');
  print('   final rows = await db.update("notes", note.toMap(), where: "id = ?", whereArgs: [note.id]);');
  print('   -> SQL tương đương: UPDATE notes SET title = ?, content = ?, isCompleted = ? WHERE id = ?');

  print('\n4. DELETE - Xóa bản ghi theo id (db.delete):');
  print('   final rows = await db.delete("notes", where: "id = ?", whereArgs: [id]);');
  print('   -> SQL tương đương: DELETE FROM notes WHERE id = ?');

  print('\n5. Lưu ý bảo mật (Chống SQL Injection):');
  print('   • Luôn sử dụng dấu hỏi chấm (?) trong where kết hợp mảng whereArgs: [...]!');
  print('==================================================');
}

