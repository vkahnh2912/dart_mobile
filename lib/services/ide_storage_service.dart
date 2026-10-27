import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ide_models.dart';

class IdeStorageService {
  static const String _storageKey = 'khanh_dart_ide_projects_v1';

  /// Tải danh sách project từ bộ nhớ
  static Future<List<UserProject>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      // Nếu chưa có, khởi tạo bộ dự án mẫu ban đầu
      final defaultProjects = _createDefaultProjects();
      await saveProjects(defaultProjects);
      return defaultProjects;
    }

    try {
      final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
      return decodedList
          .map((item) => UserProject.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final defaultProjects = _createDefaultProjects();
      await saveProjects(defaultProjects);
      return defaultProjects;
    }
  }

  /// Lưu danh sách project vào bộ nhớ
  static Future<void> saveProjects(List<UserProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(projects.map((p) => p.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  /// Khởi tạo dữ liệu mẫu ban đầu
  static List<UserProject> _createDefaultProjects() {
    return [
      UserProject(
        id: 'proj_khanh_01',
        name: '🚀 Dự Án Của Anh Khánh',
        description: 'Dự án chính để thỏa sức sáng tạo và thử nghiệm code Dart',
        createdAt: DateTime.now(),
        files: [
          UserFile(
            id: 'file_01',
            name: 'main.dart',
            updatedAt: DateTime.now(),
            content: '''void main() {
  print('=== XIN CHÀO ANH KHÁNH ĐẸP TRAI NHẤT VŨ TRỤ! ===');
  print('Chào mừng anh đến với Dart IDE trên Mobile 🚀\\n');
  
  var hoTen = 'Khánh';
  var diemSo = 100;
  print('Học viên xuất sắc: \$hoTen - Điểm: \$diemSo/100');
  
  print('\\n--- In Bảng Cửu Chương 9 ---');
  for (var i = 1; i <= 9; i++) {
    print('9 x \$i = \${9 * i}');
  }
}
''',
          ),
          UserFile(
            id: 'file_02',
            name: 'giai_thua.dart',
            updatedAt: DateTime.now(),
            content: '''int tinhGiaiThua(int n) {
  if (n <= 1) return 1;
  return n * tinhGiaiThua(n - 1);
}

void main() {
  print('--- TÍNH GIAI THỪA TRÊN DART MOBILE ---');
  for (int i = 1; i <= 6; i++) {
    print('\$i! = \${tinhGiaiThua(i)}');
  }
}
''',
          ),
        ],
      ),
      UserProject(
        id: 'proj_khanh_02',
        name: '💡 Thử Nghiệm Sáng Tạo',
        description: 'Thực hành các cấu trúc dữ liệu List, Map và thuật toán',
        createdAt: DateTime.now(),
        files: [
          UserFile(
            id: 'file_03',
            name: 'danh_sach.dart',
            updatedAt: DateTime.now(),
            content: '''void main() {
  print('--- LÀM VIỆC VỚI LIST VÀ MAP ---');
  List<String> monHoc = ['Dart Cơ Bản', 'Flutter Mobile', 'Mini IDE'];
  monHoc.add('State Management');

  print('Danh sách môn: \$monHoc');
  print('Tổng số môn học: \${monHoc.length}');
  
  Map<String, dynamic> info = {
    'ten': 'Anh Khánh',
    'chucVu': 'Đẹp trai nhất vũ trụ',
    'ngonNgu': 'Dart & Flutter',
  };
  print('\\nThông tin: \$info');
}
''',
          ),
        ],
      ),
    ];
  }
}
