// Bài 20: Lập trình hướng đối tượng - Tính Kế Thừa (Inheritance) trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

// Lớp cha (Superclass)
class Nguoi {
  String hoTen;
  int namSinh;

  Nguoi(this.hoTen, this.namSinh);

  int tinhTuoi() => DateTime.now().year - namSinh;

  void gioiThieu() {
    print("Xin chào! Tôi là $hoTen, $namSinh (Tuổi: ${tinhTuoi()})");
  }
}

// Lớp con (Subclass kế thừa từ Nguoi)
class LapTrinhVien extends Nguoi {
  String ngonNguChinh;
  double luongCoBan;

  // Sử dụng từ khóa super để gọi constructor của lớp cha
  LapTrinhVien(String hoTen, int namSinh, this.ngonNguChinh, this.luongCoBan)
      : super(hoTen, namSinh);

  // Ghi đè phương thức (@override)
  @override
  void gioiThieu() {
    super.gioiThieu();
    print("   💻 Vị trí: Flutter & Dart Developer ($ngonNguChinh)");
    print("   💰 Thu nhập: \$${luongCoBan.toStringAsFixed(0)} / tháng");
  }

  void vietCode() {
    print("🚀 $hoTen đang viết ứng dụng Flutter siêu đẹp cho anh Khánh!");
  }
}

void main([List<String>? args]) {
  print("=== BÀI 20: TÍNH KẾ THỪA TRONG LẬP TRÌNH DART ===");

  var dev = LapTrinhVien("Vũ Trọng Khánh", 2004, "Flutter & Dart", 3500);

  print("1. Thông tin kế thừa từ lớp cha và mở rộng ở lớp con:");
  dev.gioiThieu();

  print("\n2. Hành vi riêng của lớp con:");
  dev.vietCode();
  print("==================================================");
}
