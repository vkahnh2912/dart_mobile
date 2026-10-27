// Bài 19: Lập trình hướng đối tượng (OOP) - Lớp (Class) và Đối tượng (Object)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

class SinhVien {
  // Thuộc tính (Properties)
  String maSV;
  String hoTen;
  double diemGPA;

  // Constructor cơ bản (Khởi tạo)
  SinhVien(this.maSV, this.hoTen, this.diemGPA);

  // Named Constructor (Constructor có tên)
  SinhVien.moi(this.maSV, this.hoTen) : diemGPA = 0.0;

  // Phương thức (Methods)
  void hienThiThongTin() {
    print("👨‍🎓 Mã SV: $maSV | Họ tên: $hoTen | GPA: $diemGPA (${xepLoai()})");
  }

  String xepLoai() {
    if (diemGPA >= 3.6) return "Xuất sắc";
    if (diemGPA >= 3.2) return "Giỏi";
    if (diemGPA >= 2.5) return "Khá";
    return "Trung bình";
  }
}

void main([List<String>? args]) {
  print("=== BÀI 19: LẬP TRÌNH HƯỚNG ĐỐI TƯỢNG (OOP) - CLASS & OBJECT ===");

  // Khởi tạo đối tượng bằng constructor chính
  var sv1 = SinhVien("PM28.12-01", "Vũ Trọng Khánh", 3.9);
  var sv2 = SinhVien("PM28.12-02", "Trần Minh Đức", 3.4);

  // Khởi tạo đối tượng bằng named constructor
  var sv3 = SinhVien.moi("PM28.12-03", "Lê Thu Hà");

  print("1. Thông tin sinh viên lớp PM28.12:");
  sv1.hienThiThongTin();
  sv2.hienThiThongTin();
  sv3.hienThiThongTin();

  print("\n2. Cập nhật thuộc tính đối tượng:");
  sv3.diemGPA = 3.3;
  print("   Cập nhật điểm cho ${sv3.hoTen}:");
  sv3.hienThiThongTin();
  print("===============================================================");
}
