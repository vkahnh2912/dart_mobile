// Bài 37: Flutter Widgets - Ô nhập văn bản TextField cơ bản
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 37: FLUTTER WIDGETS - TEXTFIELD CƠ BẢN ===');
  print('1. TextField là gì?');
  print('   • TextField là thành phần nhập dữ liệu văn bản quan trọng hàng đầu trong ứng dụng di động.');
  print('   • Cho phép người dùng gõ văn bản, số điện thoại, mật khẩu, tìm kiếm...');

  print('\n2. Hai sự kiện nhập liệu cốt lõi:');
  print('   • onChanged: Kích hoạt mỗi khi người dùng thêm/xóa bất kỳ ký tự nào.');
  print('   • onSubmitted: Kích hoạt khi người dùng ấn nút Done / Gửi / Enter trên bàn phím.');

  print('\n3. Cú pháp cơ bản của TextField:');
  print(r'''
    TextField(
      onChanged: (text) {
        print('Người dùng đang gõ: $text');
      },
      onSubmitted: (text) {
        print('Người dùng đã ấn Enter gửi nội dung: $text');
      },
      maxLength: 50, // Giới hạn tối đa 50 ký tự
      autofocus: false,
      style: TextStyle(
        fontFamily: 'Times New Roman',
        fontSize: 16,
        color: Colors.black87,
      ),
    )
  ''');
  print('==================================================');
}
