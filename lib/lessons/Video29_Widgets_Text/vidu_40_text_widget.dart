// Bài 29: Flutter Widgets - Giới thiệu về Text Widget & Định dạng TextStyle
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 29: FLUTTER WIDGETS - TEXT WIDGET & TYPOGRAPHY ===");
  print("1. Text Widget là gì?");
  print("   • Widget cơ bản nhất để hiển thị văn bản, đoạn văn và tiêu đề trên màn hình.");

  print("\n2. Cách tùy biến kiểu chữ phong phú với TextStyle:");
  print(r'''
   Text(
     'Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀',
     textAlign: TextAlign.center,
     maxLines: 2,
     overflow: TextOverflow.ellipsis,
     style: TextStyle(
       fontFamily: 'Times New Roman', // Font chữ Times New Roman sang trọng
       fontSize: 18.0,                // Cỡ chữ
       fontWeight: FontWeight.bold,   // Độ đậm
       fontStyle: FontStyle.italic,   // Kiểu nghiêng
       color: Color(0xFF2563EB),      // Màu chữ
       letterSpacing: 0.8,            // Khoảng cách giữa các ký tự
       height: 1.4,                   // Chiều cao dòng (line-height)
     ),
   )
  ''');

  print("3. RichText và TextSpan:");
  print("   • Dùng khi một đoạn văn cần nhiều màu sắc hoặc định dạng khác nhau trên cùng một dòng.");
  print("==========================================================");
}
