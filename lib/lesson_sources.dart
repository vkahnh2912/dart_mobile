// Mã nguồn các bài học Dart & Flutter TITV (Video 10 đến 30) chuẩn UTF-8
const Map<int, String> lessonSources = {
  10: r'''// Bài 10: Ôn tập câu lệnh điều kiện if-else - Giải phương trình bậc 2 (ax^2 + bx + c = 0)
// Video: https://www.youtube.com/watch?v=zQ1olRwC3nw

import 'dart:math';

void main() {
  double a = 1.0;
  double b = -5.0;
  double c = 6.0;

  print('=== BÀI 10: GIẢI PHƯƠNG TRÌNH BẬC 2 ===');
  print('Phương trình: ${a}x^2 + (${b})x + $c = 0');

  double delta = b * b - 4 * a * c;
  print('Delta = b^2 - 4ac = $delta');

  if (delta < 0) {
    print('Kết quả: Phương trình vô nghiệm!');
  } else if (delta == 0) {
    double x = -b / (2 * a);
    print('Kết quả: Phương trình có nghiệm kép x1 = x2 = ${x.toStringAsFixed(2)}');
  } else {
    double x1 = (-b - sqrt(delta)) / (2 * a);
    double x2 = (-b + sqrt(delta)) / (2 * a);
    print('Kết quả: Phương trình có 2 nghiệm phân biệt:');
    print('   x1 = ${x1.toStringAsFixed(2)}');
    print('   x2 = ${x2.toStringAsFixed(2)}');
  }
}
''',

  11: r'''// Bài 11: Cấu trúc dữ liệu List trong Dart
// Video: https://www.youtube.com/watch?v=bnvBX0GO644

void main() {
  print('=== BÀI 11: CẤU TRÚC DỮ LIỆU LIST ===');
  List<String> danhSach = ['Dart', 'Flutter', 'Firebase'];

  // 1. Thêm phần tử
  danhSach.add('API');
  danhSach.addAll(['Git', 'VS Code']);
  print('1. Sau khi thêm: $danhSach');

  // 2. Chèn và xóa
  danhSach.insert(0, 'Dart Cơ Bản');
  danhSach.remove('Git');
  print('2. Sau khi chèn & xóa: $danhSach');

  // 3. Truy cập phần tử
  print('3. Phần tử đầu: ${danhSach.first} | Cuối: ${danhSach.last} | Tổng: ${danhSach.length}');

  // 4. Sắp xếp
  danhSach.sort();
  print('4. Sau khi sắp xếp: $danhSach');

  // 5. Duyệt forEach
  print('5. Duyệt danh sách bài học:');
  danhSach.forEach((item) => print('   • $item'));
}
''',

  12: r'''// Bài 12: Cấu trúc dữ liệu Set trong Dart
// Video: https://www.youtube.com/watch?v=0sICP2qI_BI

void main() {
  print('=== BÀI 12 (Phần 1): TẬP HỢP SET KHÔNG TRÙNG LẶP ===');
  Set<int> setA = {1, 2, 3, 4, 5};
  Set<int> setB = {4, 5, 6, 7, 8};

  print('Set A: $setA');
  print('Set B: $setB');

  // Phép hợp (Union)
  print('Hợp (A ∪ B): ${setA.union(setB)}');

  // Phép giao (Intersection)
  print('Giao (A ∩ B): ${setA.intersection(setB)}');

  // Phép hiệu (Difference)
  print('Hiệu (A \\ B): ${setA.difference(setB)}');
}
''',

  13: r'''// Bài 12: Cấu trúc dữ liệu Map trong Dart
// Video: https://www.youtube.com/watch?v=0sICP2qI_BI

void main() {
  print('=== BÀI 12 (Phần 2): TỪ ĐIỂN MAP (KEY-VALUE) ===');
  Map<String, dynamic> thongTin = {
    'hoTen': 'Vũ Trọng Khánh',
    'vaiTro': 'Lập trình viên đẹp trai nhất vũ trụ',
    'lop': 'PM28.12',
    'gpa': 3.9,
  };

  thongTin['email'] = 'khanh.pm2812@gmail.com';
  thongTin.putIfAbsent('status', () => 'Đang học Flutter');

  print('1. Thông tin sinh viên:');
  thongTin.forEach((key, val) => print('   $key: $val'));

  print('\n2. Kiểm tra tồn tại:');
  print('   Có chứa key hoTen? ${thongTin.containsKey('hoTen')}');
}
''',

  14: r'''// Bài 13: Kiểu dữ liệu Runes và Biểu tượng Emoji trong Dart
// Video: https://www.youtube.com/watch?v=Z5roSszYgJI

void main() {
  print('=== BÀI 13: RUNES VÀ BIỂU TƯỢNG EMOJI ===');

  Runes traiTim = Runes('\u2665');
  Runes matCuoi = Runes('\u{1f600}');
  Runes tenLua = Runes('\u{1f680}');

  print('Ký tự trái tim: ${String.fromCharCodes(traiTim)}');
  print('Emoji mặt cười: ${String.fromCharCodes(matCuoi)}');
  print('Emoji tên lửa: ${String.fromCharCodes(tenLua)}');

  String tinNhan = 'Anh Khánh đẹp trai 🚀 ♥';
  print('\nPhân tích chuỗi Unicode: "$tinNhan"');
  tinNhan.runes.forEach((r) {
    print('   Mã Unicode: $r -> Ký tự: ${String.fromCharCode(r)}');
  });
}
''',

  15: r'''// Bài 14: Giới thiệu về Record trong Dart 3.0+
// Video: https://www.youtube.com/watch?v=8wIqlz-Z7Dg

// Hàm trả về đồng thời nhiều giá trị nhờ Record
(String, int, double) layThongTin() {
  return ('Vũ Trọng Khánh', 22, 3.9);
}

// Record có đặt tên trường (Named fields)
({String title, int videoCount}) layKhoaHoc() {
  return (title: 'Lập trình Dart & Flutter TITV', videoCount: 56);
}

void main() {
  print('=== BÀI 14: RECORDS TRONG DART 3 ===');
  var sv = layThongTin();
  print('Tên: ${sv.$1} | Tuổi: ${sv.$2} | Điểm: ${sv.$3}');

  var khoaHoc = layKhoaHoc();
  print('Khóa học: ${khoaHoc.title} (${khoaHoc.videoCount} videos)');
}
''',

  16: r'''// Bài 15: Cách sử dụng Typedef trong Dart
// Video: https://www.youtube.com/watch?v=lXIdchI7BB4

typedef DanhSachSo = List<int>;
typedef PhepTinh = int Function(int a, int b);

int cong(int a, int b) => a + b;
int nhan(int a, int b) => a * b;

void thucHienPhepTinh(int x, int y, PhepTinh calculation) {
  print('Kết quả: ${calculation(x, y)}');
}

void main() {
  print('=== BÀI 15: ĐỊNH NGHĨA BÍ DANH TYPE TYPEDEF ===');
  DanhSachSo mangSo = [10, 20, 30, 40, 50];
  print('Danh sách số nguyên: $mangSo');

  print('Thực hiện phép cộng 8 + 12:');
  thucHienPhepTinh(8, 12, cong);

  print('Thực hiện phép nhân 8 * 12:');
  thucHienPhepTinh(8, 12, nhan);
}
''',

  17: r'''// Bài 16: Cách xây dựng Functions trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

String chaoMung() => "Chào mừng anh Khánh đến với Video 16!";
int tinhTong(int a, int b) => a + b;

String thongTinSinhVien(String ten, [int? tuoi, String lop = "PM28.12"]) {
  return "SV: $ten | Tuổi: ${tuoi ?? 'N/A'} | Lớp: $lop";
}

void guiThongBao({required String nguoiNhan, String noiDung = "Học tốt nhé!"}) {
  print("📩 Gửi tới: $nguoiNhan -> $noiDung");
}

void main() {
  print('=== BÀI 16: XÂY DỰNG VÀ SỬ DỤNG FUNCTIONS ===');
  print(chaoMung());
  print('Tổng 15 + 25 = ${tinhTong(15, 25)}');
  print(thongTinSinhVien("Vũ Trọng Khánh", 22));
  guiThongBao(nguoiNhan: "Anh Khánh đẹp trai", noiDung: "App Dart đã sẵn sàng!");
}
''',

  18: r'''// Bài 17: Câu lệnh điều kiện nâng cao & Switch Expressions
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

String layThu(int day) {
  return switch (day) {
    1 => "Chủ Nhật",
    2 => "Thứ Hai",
    3 => "Thứ Ba",
    4 => "Thứ Tư",
    5 => "Thứ Năm",
    6 => "Thứ Sáu",
    7 => "Thứ Bảy",
    _ => "Không hợp lệ",
  };
}

String xepLoai(double diem) {
  return switch (diem) {
    >= 9.0 && <= 10.0 => "Xuất sắc",
    >= 8.0 && < 9.0 => "Giỏi",
    >= 6.5 && < 8.0 => "Khá",
    >= 5.0 && < 6.5 => "Trung bình",
    _ => "Yếu",
  };
}

void main() {
  print('=== BÀI 17: SWITCH EXPRESSIONS HIỆN ĐẠI ===');
  print('Thứ 2: ${layThu(2)}');
  print('Điểm 9.5: ${xepLoai(9.5)}');
}
''',

  19: r'''// Bài 18: Các cấu trúc vòng lặp trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 18: VÒNG LẶP FOR, WHILE, FOR-IN ===');

  print('1. Bảng cửu chương 7:');
  for (int i = 1; i <= 5; i++) {
    print('   7 x $i = ${7 * i}');
  }

  print('\n2. Vòng lặp for-in:');
  var danhSach = ['Dart', 'Flutter', 'Android'];
  for (var mon in danhSach) {
    print('   🔥 Đang học: $mon');
  }

  print('\n3. Vòng lặp while:');
  int dem = 1;
  while (dem <= 3) {
    print('   Bước lặp: $dem');
    dem++;
  }
}
''',

  20: r'''// Bài 19: Lập trình hướng đối tượng - Class & Object
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

class SinhVien {
  String maSV;
  String hoTen;
  double diemGPA;

  SinhVien(this.maSV, this.hoTen, this.diemGPA);

  void inThongTin() {
    print('👨‍🎓 Mã: $maSV | Tên: $hoTen | GPA: $diemGPA');
  }
}

void main() {
  print('=== BÀI 19: CLASS VÀ OBJECT TRONG DART ===');
  var sv = SinhVien('PM28.12-01', 'Vũ Trọng Khánh', 3.9);
  sv.inThongTin();
}
''',

  21: r'''// Bài 20: Lập trình hướng đối tượng - Tính Kế thừa (Inheritance)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

class Nguoi {
  String hoTen;
  int namSinh;
  Nguoi(this.hoTen, this.namSinh);

  void gioiThieu() => print('Xin chào, tôi là $hoTen, sinh năm $namSinh');
}

class LapTrinhVien extends Nguoi {
  String chuyenMon;
  LapTrinhVien(super.hoTen, super.namSinh, this.chuyenMon);

  @override
  void gioiThieu() {
    super.gioiThieu();
    print('   💻 Chuyên môn: $chuyenMon');
  }
}

void main() {
  print('=== BÀI 20: TÍNH KẾ THỪA VÀ GHI ĐÈ PHƯƠNG THỨC ===');
  var dev = LapTrinhVien('Vũ Trọng Khánh', 2004, 'Flutter & Dart');
  dev.gioiThieu();
}
''',

  22: r'''// Bài 21: Giới thiệu về Mixin trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

mixin CoTheBay {
  void bay() => print('   🦅 Đang cất cánh bay lượn!');
}

mixin CoTheBoi {
  void boi() => print('   🐟 Đang lặn ngụp bơi lội!');
}

abstract class DongVat {
  String ten;
  DongVat(this.ten);
}

class VitTroi extends DongVat with CoTheBay, CoTheBoi {
  VitTroi(super.ten);
}

void main() {
  print('=== BÀI 21: SỬ DỤNG MIXIN TÁI SỬ DỤNG HÀNH VI ===');
  var vit = VitTroi('Vịt trời Donald');
  print('Năng lực của ${vit.ten}:');
  vit.bay();
  vit.boi();
}
''',

  23: r'''// Bài 22: Lập trình bất đồng bộ - Future & async/await
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

Future<String> layDuLieu() async {
  await Future.delayed(const Duration(milliseconds: 200));
  return "Dữ liệu 56 bài học Flutter đã sẵn sàng!";
}

void main() async {
  print('=== BÀI 22: LẬP TRÌNH BẤT ĐỒNG BỘ VỚI FUTURE ===');
  print('1. Đang gửi yêu cầu tới máy chủ...');
  String ketQua = await layDuLieu();
  print('2. Nhận kết quả thành công: $ketQua');
}
''',

  24: r'''// Bài 23: Lập trình bất đồng bộ - Stream trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

Stream<int> taoDongDem(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i;
  }
}

void main() async {
  print('=== BÀI 23: LẮNG NGHE DÒNG DỮ LIỆU STREAM ===');
  await for (int val in taoDongDem(4)) {
    print('   📡 Nhận gói tin Stream số: $val');
  }
}
''',

  25: r'''// Bài 24: Hướng dẫn cài đặt Flutter SDK & Thiết lập môi trường
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

import 'dart:io';

void main() {
  print('=== BÀI 24: CÀI ĐẶT FLUTTER SDK ===');
  print('• Dart Version: ${Platform.version.split(' ').first}');
  print('• Hệ điều hành: ${Platform.operatingSystem}');
  print('• Lệnh kiểm tra: flutter doctor -v');
}
''',

  26: r'''// Bài 25: Cài đặt Android Studio & Cấu hình máy ảo AVD
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 25: MÁY ẢO ANDROID STUDIO AVD ===');
  print('• Tên máy ảo: FLAPPY FLY PIXEL');
  print('• Phiên bản: Android 15 (API 35)');
  print('• Khởi động máy ảo: flutter emulators --launch FLAPPY_FLY_PIXEL');
}
''',

  27: r'''// Bài 26: Xây dựng Interface và Abstract Class trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

abstract class HinhHoc {
  double tinhDienTich();
}

class HinhChuNhat implements HinhHoc {
  double dai;
  double rong;
  HinhChuNhat(this.dai, this.rong);

  @override
  double tinhDienTich() => dai * rong;
}

void main() {
  print('=== BÀI 26: ABSTRACT CLASS & IMPLEMENTS INTERFACE ===');
  var hcn = HinhChuNhat(10, 5);
  print('Diện tích hình chữ nhật: ${hcn.tinhDienTich()} m2');
}
''',

  28: r'''// Bài 27: Flutter Widgets - Giới thiệu về Widget Scaffold
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 27: WIDGET SCAFFOLD TRONG FLUTTER ===');
  print('Cung cấp cấu trúc màn hình: appBar, body, floatingActionButton, bottomNavigationBar');
}
''',

  29: r'''// Bài 28: Flutter Widgets - Chi tiết về Widget AppBar
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 28: THANH TIÊU ĐỀ APPBAR TRONG FLUTTER ===');
  print('Các thuộc tính chính: title, leading, actions, backgroundColor, elevation, centerTitle');
}
''',

  30: r'''// Bài 29: Flutter Widgets - Text Widget & Typography (Times New Roman)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 29: TEXT WIDGET & TYPOGRAPHY ===');
  print('Tùy biến TextStyle: fontFamily: Times New Roman, fontSize: 18, color: Colors.blueAccent');
}
''',

  31: r'''// Bài 30: Flutter Widgets - Giới thiệu về Container Widget
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 30: CONTAINER WIDGET ĐA NĂNG ===');
  print('Kết hợp: width, height, padding, margin, decoration (BoxDecoration bo tròn góc, shadow)');
}
''',

  32: r'''// Bài 31: Flutter Widgets - Bố cục Column và Row
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 31: BỐ CỤC COLUMN VÀ ROW ===');
  print('1. Column: Sắp xếp các widget con theo chiều DỌC.');
  print('2. Row: Sắp xếp các widget con theo chiều NGANG.');
  print('3. Căn lề: mainAxisAlignment (trục chính), crossAxisAlignment (trục phụ).');
  print('4. Tránh lỗi tràn giao diện (Overflow) bằng cách bọc văn bản trong Expanded hoặc Flexible.');
}
''',

  33: r'''// Bài 32: Flutter Widgets - Các loại Button (Types of Buttons)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 32: CÁC LOẠI BUTTON TRONG FLUTTER ===');
  print('1. ElevatedButton: Nút nổi có đổ bóng elevation (Hành động chính).');
  print('2. OutlinedButton: Nút viền mảnh sang trọng (Hành động phụ).');
  print('3. TextButton: Nút phẳng không viền dùng cho liên kết / dialog.');
  print('4. IconButton: Nút biểu tượng dùng trên AppBar hoặc Action Bar.');
}
''',

  34: r'''// Bài 33: Flutter Widgets - Tùy biến kiểu dáng ButtonStyle
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 33: TÙY BIẾN BUTTONSTYLE VỚI STYLEFROM ===');
  print('Tùy chỉnh: backgroundColor, foregroundColor, elevation, padding, shape bo góc.');
  print('Ví dụ: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2563EB), elevation: 4);');
}
''',

  35: r'''// Bài 34: Flutter Widgets - Widget InkWell (Ripple Effect)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 34: WIDGET INKWELL - HIỆU ỨNG GỢN SÓNG NƯỚC ===');
  print('Biến bất kỳ widget nào thành nút bấm có hiệu ứng gợn sóng Material Design.');
  print('Bắt buộc đặt trong Material widget để hiển thị mực lan tỏa (splashColor).');
}
''',

  36: r'''// Bài 35: Flutter Widgets - Xử lý sự kiện và truyền tham số Button
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 35: XỬ LÝ SỰ KIỆN VÀ TRUYỀN THAM SỐ BUTTON ===');
  print('1. Hàm không tham số: onPressed: xuLyBamNut');
  print('2. Truyền tham số qua Closure: onPressed: () => xuLyBamNut(\'anh Khánh\', 100)');
  print('3. Cập nhật giao diện sau khi bấm nút bằng cách gọi setState().');
}
''',

  37: r'''// Bài 36: Flutter Widgets - Bắt cử chỉ chạm vuốt với GestureDetector
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 36: BẮT CỬ CHỈ VỚI GESTUREDETECTOR ===');
  print('1. Chạm: onTap, onDoubleTap, onLongPress.');
  print('2. Kéo vuốt: onPanStart, onPanUpdate, onPanEnd (làm joystick game).');
  print('3. Phóng to / Thu nhỏ: onScaleStart, onScaleUpdate (zoom ảnh).');
}
''',

  38: r'''// Bài 37: Flutter Widgets - Ô nhập văn bản TextField cơ bản
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 37: TEXTFIELD NHẬP LIỆU CƠ BẢN ===');
  print('1. onChanged: Bắt sự kiện mỗi khi người dùng gõ hoặc xóa chữ.');
  print('2. onSubmitted: Bắt sự kiện khi người dùng ấn phím Gửi / Enter trên bàn phím.');
}
''',

  39: r'''// Bài 38: Flutter Widgets - Tùy biến giao diện & Bàn phím TextField
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 38: TRANG TRÍ INPUTDECORATION & KEYBOARDTYPE ===');
  print('1. InputDecoration: labelText, hintText, prefixIcon, suffixIcon, OutlineInputBorder.');
  print('2. obscureText: true (ẩn mật khẩu thành dấu chấm tròn).');
  print('3. keyboardType: TextInputType.emailAddress / number / phone.');
}
''',

  40: r'''// Bài 39: Flutter Widgets - Quản lý ô nhập bằng TextEditingController
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 39: TEXTEDITINGCONTROLLER TRONG FLUTTER ===');
  print('1. Khởi tạo: final _controller = TextEditingController(text: \'Vũ Trọng Khánh\');');
  print('2. Đọc giá trị: _controller.text');
  print('3. Xóa trắng: _controller.clear()');
  print('4. BẮT BUỘC: gọi _controller.dispose() khi hủy widget để tránh rò rỉ bộ nhớ.');
}
''',

  41: r'''// Bài 40: Flutter Widgets - Quản lý Form & Validation
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main() {
  print('=== BÀI 40: QUẢN LÝ FORM & VALIDATION TRONG FLUTTER ===');
  print('1. Tạo khóa quản lý: final _formKey = GlobalKey<FormState>();');
  print('2. Bọc trong Form(key: _formKey, child: ...)');
  print('3. Dùng TextFormField có thuộc tính validator để kiểm tra dữ liệu hợp lệ.');
  print('4. Kiểm tra hợp lệ khi bấm nút: if (_formKey.currentState!.validate()) { ... }');
}
''',
};
