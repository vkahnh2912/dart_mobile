// Bài 39: Flutter Widgets - Quản lý ô nhập bằng TextEditingController
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 39: FLUTTER WIDGETS - TEXTEDITINGCONTROLLER ===');
  print('1. Tại sao cần TextEditingController?');
  print('   • Giúp đọc giá trị ô nhập bất kỳ lúc nào mà không cần phụ thuộc sự kiện onChanged.');
  print('   • Gán sẵn giá trị ban đầu cho ô nhập (initial text).');
  print('   • Xóa trắng ô nhập nhanh chóng (clear).');
  print('   • Đặt con trỏ hoặc bôi đen văn bản theo ý muốn.');

  print('\n2. Quy trình 4 bước chuẩn với TextEditingController:');
  print('   • Bước 1: Khai báo biến controller trong State:');
  print('       late TextEditingController _hoTenController;');
  print('   • Bước 2: Khởi tạo trong initState():');
  print('       _hoTenController = TextEditingController(text: \'Vũ Trọng Khánh\');');
  print('   • Bước 3: Gắn controller vào TextField:');
  print('       TextField(controller: _hoTenController)');
  print('   • Bước 4: HỦY CONTROLLER BẮT BUỘC trong dispose():');
  print('       _hoTenController.dispose(); // Tránh rò rỉ bộ nhớ (Memory Leak)');

  print('\n3. Thao tác thực tế:');
  print(r'''
    // Đọc giá trị:
    String ten = _hoTenController.text.trim();
    print('Học viên xuất sắc: $ten');

    // Xóa trắng ô nhập:
    _hoTenController.clear();

    // Lắng nghe thay đổi liên tục:
    _hoTenController.addListener(() {
      print('Nội dung vừa đổi thành: ${_hoTenController.text}');
    });
  ''');
  print('==================================================');
}
