// Bài 38: Flutter Widgets - Tùy biến giao diện & Bàn phím TextField
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 38: FLUTTER WIDGETS - TÙY BIẾN TEXTFIELD & KEYBOARD ===');
  print('1. Trang trí ô nhập liệu với InputDecoration:');
  print('   • labelText: Tiêu đề nổi phía trên ô nhập khi focus.');
  print('   • hintText: Chữ gợi ý mờ khi ô nhập còn trống.');
  print('   • prefixIcon: Biểu tượng ở đầu ô nhập (ví dụ icon email, lock).');
  print('   • suffixIcon: Biểu tượng ở cuối ô (ví dụ nút ẩn/hiện mật khẩu).');
  print('   • border: Viền xung quanh, phổ biến là OutlineInputBorder bo cong.');

  print('\n2. Tùy chỉnh loại bàn phím (keyboardType):');
  print('   • TextInputType.text: Bàn phím chữ bình thường.');
  print('   • TextInputType.emailAddress: Bàn phím có sẵn phím @ và domain.');
  print('   • TextInputType.number / phone: Bàn phím chuyên nhập số / gọi điện.');
  print('   • TextInputType.multiline: Cho phép xuống dòng nhiều hàng.');

  print('\n3. Đoạn mã mẫu ô nhập Mật Khẩu chuyên nghiệp:');
  print(r'''
    bool _hienThiMatKhau = false;

    TextField(
      obscureText: !_hienThiMatKhau, // Ẩn văn bản thành dấu chấm tròn
      obscuringCharacter: '•',
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: 'Mật khẩu của anh Khánh',
        hintText: 'Nhập ít nhất 8 ký tự...',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB)),
        suffixIcon: IconButton(
          icon: Icon(_hienThiMatKhau ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() => _hienThiMatKhau = !_hienThiMatKhau);
          },
        ),
        filled: true,
        fillColor: Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
      ),
    )
  ''');
  print('==================================================');
}
