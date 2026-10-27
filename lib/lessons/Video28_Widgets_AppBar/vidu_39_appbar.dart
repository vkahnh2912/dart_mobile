// Bài 28: Flutter Widgets - Tìm hiểu chi tiết về Widget AppBar
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 28: FLUTTER WIDGETS - CHI TIẾT VỀ APPBAR ===");
  print("1. Thành phần cấu tạo của thanh AppBar:");
  print("   • leading: Widget nằm ở góc trên cùng bên trái (thường là Icon Menu hoặc Nút Back).");
  print("   • title: Tiêu đề trang, hỗ trợ Text hoặc thanh tìm kiếm TextField.");
  print("   • actions: Danh sách các nút tác vụ ở góc trên cùng bên phải (IconButton, PopupMenu).");
  print("   • bottom: Thường dùng để đặt TabBar điều hướng tab.");
  print("   • flexibleSpace: Tạo nền Gradient hoặc ảnh co giãn.");

  print("\n2. Đoạn mã mẫu cấu hình AppBar chuyên nghiệp:");
  print(r'''
   AppBar(
     leading: IconButton(
       icon: Icon(Icons.arrow_back_ios_new_rounded),
       onPressed: () => Navigator.pop(context),
     ),
     title: Text(
       'VuTrongKhanh.PM28.12',
       style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold),
     ),
     centerTitle: true,
     backgroundColor: Colors.indigo,
     elevation: 2,
     actions: [
       IconButton(icon: Icon(Icons.search), onPressed: () {}),
       IconButton(icon: Icon(Icons.settings), onPressed: () {}),
     ],
   )
  ''');

  print("3. Các thuộc tính thẩm mỹ nâng cao:");
  print("   • elevation: Độ đổ bóng của thanh AppBar.");
  print("   • centerTitle: Căn giữa tiêu đề (mặc định iOS là true, Android là false).");
  print("====================================================");
}
