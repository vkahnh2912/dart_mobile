// Bài 34: Flutter Widgets - Widget InkWell (Hiệu ứng Ripple Effect)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 34: FLUTTER WIDGETS - WIDGET INKWELL ===');
  print('1. InkWell là gì?');
  print('   • InkWell là widget tạo hiệu ứng gợn sóng mực (Material Splash/Ripple Effect) khi người dùng chạm vào.');
  print('   • Giúp biến bất kỳ thành phần tĩnh nào (Container, Card, Image) thành nút bấm phản hồi sinh động.');

  print('\n2. Quy tắc quan trọng:');
  print('   • InkWell PHẢI nằm bên trong một widget Material để hiệu ứng gợn sóng có thể vẽ lên bề mặt.');

  print('\n3. Mã nguồn ví dụ InkWell chuẩn Material Design:');
  print(r'''
    Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Color(0xFF2563EB).withValues(alpha: 0.2), // Màu gợn sóng
        highlightColor: Color(0xFF2563EB).withValues(alpha: 0.1), // Màu khi giữ
        onTap: () {
          print('Anh Khánh vừa chạm nhẹ (onTap) vào thẻ bài học!');
        },
        onDoubleTap: () {
          print('Anh Khánh vừa chạm đúp (onDoubleTap)!');
        },
        onLongPress: () {
          print('Anh Khánh vừa nhấn giữ lâu (onLongPress)!');
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app_rounded, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Text(
                'Chạm vào đây để xem hiệu ứng gợn sóng',
                style: TextStyle(fontFamily: 'Times New Roman', fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    )
  ''');
  print('==================================================');
}
