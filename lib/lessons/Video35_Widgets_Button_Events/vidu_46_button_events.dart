// Bài 35: Flutter Widgets - Xử lý sự kiện và truyền tham số Button
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void xuLyChonKhoaHoc(String tenKhoaHoc, int hocPhi) {
  print('-> Đã chọn khóa: $tenKhoaHoc - Học phí: $hocPhi VNĐ');
}

void main([List<String>? args]) {
  print('=== BÀI 35: FLUTTER WIDGETS - XỬ LÝ SỰ KIỆN BUTTON ===');
  print('1. Các cách gắn hàm vào sự kiện onPressed:');
  print('   • Cách 1: Gán trực tiếp tham chiếu hàm (khi không cần tham số):');
  print('       onPressed: xuLyBamNut');
  print('   • Cách 2: Dùng hàm ẩn danh (Anonymous Closure) để truyền tham số:');
  print('       onPressed: () => xuLyChonKhoaHoc(\'Flutter Cơ Bản\', 500000)');

  print('\n2. Thực thi thử nghiệm truyền tham số vào sự kiện:');
  xuLyChonKhoaHoc('Lập trình Flutter từ Video 10 đến 40', 0);
  xuLyChonKhoaHoc('Dart OOP Chuyên Sâu cho anh Khánh', 0);

  print('\n3. Cập nhật giao diện với setState() trong StatefulWidget:');
  print(r'''
    int _demSoLanBam = 0;

    ElevatedButton(
      onPressed: () {
        setState(() {
          _demSoLanBam++; // Tăng biến đếm và vẽ lại Widget
        });
        print('Đã bấm: $_demSoLanBam lần');
      },
      child: Text('Đã bấm $_demSoLanBam lần'),
    )
  ''');
  print('==================================================');
}
