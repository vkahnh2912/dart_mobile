// Bài 32: Flutter Widgets - Các loại Button (Types of Buttons)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 32: FLUTTER WIDGETS - CÁC LOẠI BUTTON ===');
  print('1. Tổng quan 4 loại nút bấm chuẩn Material trong Flutter:');
  print('   [1] ElevatedButton: Nút nổi có đổ bóng elevation, thường dùng cho hành động chính.');
  print('   [2] OutlinedButton: Nút có đường viền bo quanh, dùng cho hành động phụ.');
  print('   [3] TextButton: Nút phẳng không viền, dùng cho dialog hoặc link điều hướng.');
  print('   [4] IconButton: Nút chỉ gồm icon, thích hợp trên AppBar hoặc Action Bar.');

  print('\n2. Cú pháp khởi tạo các loại Button:');
  print(r'''
    // 1. ElevatedButton
    ElevatedButton(
      onPressed: () => print('Đã ấn ElevatedButton!'),
      child: Text('Lưu Dự Án', style: TextStyle(fontFamily: 'Times New Roman')),
    )

    // 2. OutlinedButton
    OutlinedButton(
      onPressed: () => print('Đã ấn OutlinedButton!'),
      child: Text('Hủy Bỏ', style: TextStyle(fontFamily: 'Times New Roman')),
    )

    // 3. TextButton
    TextButton(
      onPressed: () => print('Đã ấn TextButton!'),
      child: Text('Xem Thêm Điều Khoản', style: TextStyle(fontFamily: 'Times New Roman')),
    )

    // 4. IconButton
    IconButton(
      icon: Icon(Icons.favorite_rounded, color: Colors.red),
      tooltip: 'Yêu thích',
      onPressed: () => print('Đã thả tim!'),
    )

    // 5. Button có kèm Icon (ElevatedButton.icon)
    ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(Icons.rocket_launch_rounded),
      label: Text('Khởi Động App'),
    )
  ''');

  print('3. Trạng thái vô hiệu hóa (Disabled state):');
  print('   • Khi truyền onPressed: null, Button sẽ tự động chuyển sang trạng thái disabled (mờ đi).');
  print('==================================================');
}
