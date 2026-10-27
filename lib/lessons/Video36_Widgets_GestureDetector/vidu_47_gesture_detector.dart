// Bài 36: Flutter Widgets - Bắt cử chỉ chạm vuốt với GestureDetector
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 36: FLUTTER WIDGETS - GESTUREDETECTOR ===');
  print('1. GestureDetector là gì?');
  print('   • GestureDetector là widget vô hình mạnh mẽ nhất để nhận diện mọi tương tác vật lý của người dùng.');
  print('   • Khác với InkWell, GestureDetector không kèm hiệu ứng vẽ mực Material, chuyên trị các cử chỉ phức tạp.');

  print('\n2. Danh mục cử chỉ hỗ trợ:');
  print('   [1] Cử chỉ Chạm (Tap):');
  print('       • onTapDown / onTapUp / onTap / onTapCancel');
  print('       • onDoubleTap: Chạm 2 lần nhanh (thả tim ảnh như Instagram)');
  print('       • onLongPress: Nhấn giữ lâu (mở menu ngữ cảnh)');
  print('   [2] Cử chỉ Kéo rê / Vuốt (Pan / Drag):');
  print('       • onPanStart / onPanUpdate / onPanEnd (làm joystick điều khiển game)');
  print('   [3] Cử chỉ Thu phóng (Scale):');
  print('       • onScaleStart / onScaleUpdate / onScaleEnd (dùng 2 ngón zoom ảnh/map)');

  print('\n3. Đoạn mã ví dụ mẫu GestureDetector:');
  print(r'''
    GestureDetector(
      onTap: () => print('Chạm nhẹ'),
      onDoubleTap: () => print('Thả tim 2 lần ❤️'),
      onLongPress: () => print('Hiện hộp thoại tùy chọn'),
      onPanUpdate: (details) {
        // Tọa độ ngón tay di chuyển: details.delta.dx, details.delta.dy
        print('Đang di chuyển: (${details.localPosition.dx}, ${details.localPosition.dy})');
      },
      child: Container(
        width: 250,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text('Vùng cảm ứng thông minh của anh Khánh', style: TextStyle(color: Colors.white)),
      ),
    )
  ''');
  print('==================================================');
}
