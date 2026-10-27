// Bài 26: Xây dựng Interface và Abstract Class trong lập trình Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

// 1. Abstract Class: Lớp trừu tượng định nghĩa các hành vi khung
abstract class HinhHoc {
  String tenHinh;
  HinhHoc(this.tenHinh);

  // Phương thức trừu tượng không có thân hàm
  double tinhDienTich();
  double tinhChuVi();

  void inThongSo() {
    print("📐 Hình: $tenHinh | Diện tích: ${tinhDienTich().toStringAsFixed(2)} | Chu vi: ${tinhChuVi().toStringAsFixed(2)}");
  }
}

// 2. Interface trong Dart: Mọi class đều có thể làm interface với từ khóa implements
abstract class CoTheInAn {
  void inRaGiay();
}

// Lớp thực thi (implements) cả HinhHoc và CoTheInAn
class HinhChuNhat extends HinhHoc implements CoTheInAn {
  double chieuDai;
  double chieuRong;

  HinhChuNhat(this.chieuDai, this.chieuRong) : super("Hình Chữ Nhật");

  @override
  double tinhDienTich() => chieuDai * chieuRong;

  @override
  double tinhChuVi() => 2 * (chieuDai + chieuRong);

  @override
  void inRaGiay() {
    print("🖨️ Đang gửi lệnh in bản vẽ kỹ thuật Hình Chữ Nhật (${chieuDai}x$chieuRong) ra máy in...");
  }
}

class HinhTron extends HinhHoc {
  double banKinh;
  HinhTron(this.banKinh) : super("Hình Tròn");

  @override
  double tinhDienTich() => 3.14159 * banKinh * banKinh;

  @override
  double tinhChuVi() => 2 * 3.14159 * banKinh;
}

void main([List<String>? args]) {
  print("=== BÀI 26: ABSTRACT CLASS VÀ INTERFACE TRONG DART ===");

  var hcn = HinhChuNhat(12.5, 6.0);
  hcn.inThongSo();
  hcn.inRaGiay();

  print("");
  var ht = HinhTron(5.0);
  ht.inThongSo();

  print("======================================================");
}
