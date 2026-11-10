// Bài 44: Cơ sở dữ liệu SQLite (sqflite) - Ứng dụng Quản lý Ghi chú (Notes App) hoàn chỉnh
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 44: XÂY DỰNG ỨNG DỤNG QUẢN LÝ GHI CHÚ VỚI SQLITE (SQFLITE) ===');
  print('1. Kiến trúc 3 tầng chuẩn mực của ứng dụng Notes SQLite:');
  print('   • Tầng Model (lib/models/note_model.dart): Lớp NoteItem định nghĩa cấu trúc bảng & toMap/fromMap.');
  print('   • Tầng Data/Service (lib/services/note_database_helper.dart): Quản lý kết nối SQLite & các hàm bất đồng bộ CRUD.');
  print('   • Tầng UI (lib/screens/sqlite_notes_screen.dart): Giao diện danh sách, tìm kiếm, lọc danh mục, Form thêm/sửa và vuốt xóa Dismissible.');

  print('\n2. Chu trình đồng bộ dữ liệu giữa SQLite và giao diện Flutter:');
  print('   • Khi mở màn hình (initState): Gọi _refreshNotes() -> await _dbHelper.getAllNotes() -> setState() hiển thị ListView.');
  print('   • Khi Thêm / Sửa trong BottomSheet Form: Kiểm tra _formKey.currentState!.validate() -> gọi insertNote / updateNote -> gọi lại _refreshNotes().');
  print('   • Khi Vuốt xóa (Dismissible) hoặc bấm nút Xóa: Gọi deleteNote(id) -> cập nhật lại danh sách ngay lập tức.');

  print('\n3. Trải nghiệm thực tế ngay trên App:');
  print('   👉 Anh Khánh có thể bấm nút "MỞ APP QUẢN LÝ GHI CHÚ SQLITE" ngay phía trên hoặc chuyển sang tab "SQLite CRUD" ở thanh điều hướng dưới cùng!');
  print('==================================================');
}

