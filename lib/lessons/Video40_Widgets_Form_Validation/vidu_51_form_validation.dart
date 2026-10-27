// Bài 40: Flutter Widgets - Quản lý Form & Kiểm tra tính hợp lệ (Validation)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 40: FLUTTER WIDGETS - QUẢN LÝ FORM & VALIDATION ===');
  print('1. Tổng quan về Form trong Flutter:');
  print('   • Form là widget vùng chứa nhóm nhiều trường nhập liệu (TextFormField, DropdownFormField...).');
  print('   • Cung cấp cơ chế xác thực toàn diện (validate) và lưu trữ (save) đồng loạt chỉ với một lệnh.');

  print('\n2. Khởi tạo GlobalKey<FormState>:');
  print('   • Khóa GlobalKey cho phép truy cập vào trạng thái của Form từ bất kỳ đâu.');
  print('   • Cú pháp: final _formKey = GlobalKey<FormState>();');

  print('\n3. Cấu trúc một Form hoàn chỉnh có Validate:');
  print(r'''
    final _formKey = GlobalKey<FormState>();
    final _emailController = TextEditingController();

    Form(
      key: _formKey,
      child: Column(
        children: [
          // Trường nhập liệu TextFormField
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email của anh Khánh',
              hintText: 'vidu@gmail.com',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            // Hàm kiểm tra hợp lệ
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '⚠️ Vui lòng không để trống email!';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return '⚠️ Định dạng email không hợp lệ!';
              }
              return null; // Hợp lệ (không có lỗi)
            },
          ),
          SizedBox(height: 16),
          // Nút gửi biểu mẫu
          ElevatedButton(
            onPressed: () {
              // Kích hoạt toàn bộ hàm validator của các trường bên trong Form:
              if (_formKey.currentState!.validate()) {
                print('✅ Dữ liệu hợp lệ! Tiến hành gửi form...');
                _formKey.currentState!.save();
              } else {
                print('❌ Biểu mẫu còn lỗi, vui lòng kiểm tra lại!');
              }
            },
            child: Text('GỬI BIỂU MẪU'),
          ),
        ],
      ),
    )
  ''');

  print('4. Reset Form:');
  print('   • Muốn đưa toàn bộ các trường về trạng thái ban đầu: _formKey.currentState!.reset();');
  print('==================================================');
}
