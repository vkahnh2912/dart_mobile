// Bài 41: Cơ sở dữ liệu SQLite (sqflite) - Cài đặt & Xây dựng Model (toMap, fromMap)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 41: SQLITE (SQFLITE) - CÀI ĐẶT & XÂY DỰNG MODEL ===');
  print('1. Cài đặt thư viện trong pubspec.yaml:');
  print('   dependencies:');
  print('     sqflite: ^2.4.5');
  print('     path: ^1.9.1');

  print('\n2. Tại sao cần toMap() và fromMap() trong Model SQLite?');
  print('   • SQLite lưu trữ từng bản ghi dưới dạng hàng-cột (Map<String, dynamic>).');
  print('   • toMap(): Chuyển đối tượng Dart (NoteItem) -> Map để INSERT / UPDATE vào bảng.');
  print('   • fromMap(): Chuyển Map đọc từ câu lệnh SELECT -> đối tượng Dart (NoteItem).');

  // Minh họa thực thi chuyển đổi Model <-> Map
  final noteData = <String, dynamic>{
    'id': 1,
    'title': 'Học lập trình SQLite sqflite cùng thầy Tùng TITV',
    'content': 'Xây dựng lớp NoteItem chuẩn OOP cho anh Khánh PM28.12',
    'category': 'Dự án Flutter',
    'priority': 3,
    'isCompleted': 1,
    'createdAt': '03/11/2026 09:20',
  };

  print('\n3. Thực nghiệm chuyển đổi dữ liệu Map -> Object -> Map:');
  print('   • Dữ liệu thô từ SQLite (Map): $noteData');
  print('   • Đọc trường title: ${noteData['title']}');
  print('   • Đọc trạng thái hoàn thành (1 -> true): ${noteData['isCompleted'] == 1}');
  print('==================================================');
}

