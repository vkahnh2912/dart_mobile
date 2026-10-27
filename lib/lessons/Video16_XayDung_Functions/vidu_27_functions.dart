// Bài 16: Cách xây dựng và sử dụng Functions (Hàm) trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

// 1. Hàm cơ bản không tham số và có trả về
String chaoMung() {
  return "Chào mừng anh Khánh đẹp trai nhất vũ trụ đến với Video 16!";
}

// 2. Hàm có tham số vị trí bắt buộc
int tinhTong(int a, int b) {
  return a + b;
}

// 3. Hàm có tham số tùy chọn trong dấu ngoặc vuông [ ]
String thongTinSinhVien(String ten, [int? tuoi, String lop = "PM28.12"]) {
  return "Sinh viên: $ten | Tuổi: ${tuoi ?? 'Chưa rõ'} | Lớp: $lop";
}

// 4. Hàm có tham số đặt tên (Named Parameters) trong dấu { }
void guiLoiNhan({required String nguoiNhan, String noiDung = "Chúc một ngày tốt lành", int mucDoUuTien = 1}) {
  print("📩 Gửi tới: $nguoiNhan [Ưu tiên: $mucDoUuTien]");
  print("   Nội dung: $noiDung");
}

// 5. Arrow Function (Cú pháp mũi tên thu gọn =>)
int tinhBinhPhuong(int x) => x * x;
bool laSoChan(int n) => n % 2 == 0;

void main([List<String>? args]) {
  print("=== BÀI 16: XÂY DỰNG & SỬ DỤNG FUNCTIONS TRONG DART ===");
  print(chaoMung());
  print("\n1. Tham số vị trí:");
  print("   5 + 7 = ${tinhTong(5, 7)}");

  print("\n2. Tham số tùy chọn [optional]:");
  print("   ${thongTinSinhVien("Vũ Trọng Khánh", 22)}");
  print("   ${thongTinSinhVien("Nguyễn Văn A")}");

  print("\n3. Tham số đặt tên {named parameters}:");
  guiLoiNhan(nguoiNhan: "Anh Khánh đẹp trai", noiDung: "Đang học Flutter cực đỉnh!", mucDoUuTien: 5);

  print("\n4. Arrow Functions (=>):");
  print("   Bình phương của 9: ${tinhBinhPhuong(9)}");
  print("   Số 10 là số chẵn? ${laSoChan(10) ? 'Đúng' : 'Sai'}");
  print("=====================================================");
}
