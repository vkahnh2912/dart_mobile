// Bài 33: Flutter Widgets - Tùy biến kiểu dáng ButtonStyle
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 33: FLUTTER WIDGETS - TÙY BIẾN BUTTONSTYLE ===');
  print('1. Cách sử dụng phương thức tiện ích styleFrom():');
  print('   • styleFrom() là cách nhanh nhất và trực quan nhất để tạo ButtonStyle.');

  print('\n2. Mã nguồn mẫu nút bấm VIP phong cách hiện đại:');
  print(r'''
    ElevatedButton(
      style: ElevatedButton.styleFrom(
        // Màu nền nút
        backgroundColor: Color(0xFF2563EB), // Xanh Sapphire
        // Màu chữ và icon khi hiển thị
        foregroundColor: Colors.white,
        // Độ đổ bóng nút
        elevation: 4,
        shadowColor: Color(0xFF2563EB).withValues(alpha: 0.4),
        // Khoảng đệm bên trong
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        // Kích thước tối thiểu
        minimumSize: Size(180, 48),
        // Bo cong 4 góc
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Color(0xFF1D4ED8), width: 1.2),
        ),
        // Kiểu chữ mặc định
        textStyle: TextStyle(
          fontFamily: 'Times New Roman',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      onPressed: () {
        print('Nút VIP của anh Khánh đã được bấm!');
      },
      child: Text('ĐĂNG KÝ KHÓA HỌC DART'),
    )
  ''');

  print('3. Tùy biến nâng cao với WidgetStateProperty (Material 3):');
  print('   • Cho phép đổi màu nền riêng biệt khi Hover, Pressed, Disabled hoặc Focused.');
  print('==================================================');
}
