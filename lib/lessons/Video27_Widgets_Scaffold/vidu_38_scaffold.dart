// Bài 27: Flutter Widgets - Giới thiệu về Widget Scaffold
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 27: FLUTTER WIDGETS - GIỚI THIỆU VỀ SCAFFOLD ===");
  print("1. Scaffold là gì?");
  print("   • Scaffold là widget cung cấp khung sườn kiến trúc giao diện chuẩn Material Design.");
  print("   • Tự động xử lý vị trí của AppBar, Body, Drawer, FloatingActionButton và BottomNavigationBar.");

  print("\n2. Cấu trúc một màn hình chuẩn với Scaffold trong Flutter:");
  print(r'''
   Scaffold(
     appBar: AppBar(
       title: Text('TITV Dart & Flutter'),
       backgroundColor: Colors.blueAccent,
     ),
     body: Center(
       child: Text('Chào anh Khánh đẹp trai nhất vũ trụ!'),
     ),
     floatingActionButton: FloatingActionButton(
       onPressed: () {},
       child: Icon(Icons.add),
     ),
     bottomNavigationBar: BottomNavigationBar(
       items: [ ... ],
     ),
   )
  ''');

  print("3. Các thuộc tính quan trọng khác của Scaffold:");
  print("   • drawer: Menu trượt từ cạnh trái màn hình.");
  print("   • endDrawer: Menu trượt từ cạnh phải màn hình.");
  print("   • backgroundColor: Màu nền tổng thể của toàn màn hình.");
  print("   • resizeToAvoidBottomInset: Tự động cuộn giao diện khi bàn phím ảo xuất hiện.");
  print("=======================================================");
}
