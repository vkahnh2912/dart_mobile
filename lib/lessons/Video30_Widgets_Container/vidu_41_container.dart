// Bài 30: Flutter Widgets - Giới thiệu về Container Widget
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 30: FLUTTER WIDGETS - CONTAINER WIDGET ===");
  print("1. Container là gì?");
  print("   • Container là widget hộp đa năng kết hợp kích thước, căn lề, viền, bo góc và đổ bóng.");
  print("   • Tương đương thẻ <div> có CSS styling trong lập trình Web.");

  print("\n2. Cấu trúc mẫu một Container chuẩn đẹp trong Flutter:");
  print(r'''
   Container(
     width: 320,
     height: 140,
     margin: EdgeInsets.all(16),
     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       border: Border.all(color: Color(0xFFE2E8F0), width: 1.5),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.06),
           blurRadius: 10,
           offset: Offset(0, 4),
         ),
       ],
     ),
     child: Text(
       'Khung giao diện Container chuẩn của anh Khánh',
       style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
     ),
   )
  ''');

  print("3. Phân biệt Padding và Margin:");
  print("   • Padding: Khoảng cách từ nội dung bên trong tới viền của Container.");
  print("   • Margin: Khoảng cách từ viền Container tới các widget bên ngoài.");
  print("==================================================");
}
