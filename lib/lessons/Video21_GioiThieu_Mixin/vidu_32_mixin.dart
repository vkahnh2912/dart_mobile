// Bài 21: Giới thiệu về MIXIN trong lập trình Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

// Mixin là cách tái sử dụng mã nguồn của nhiều class mà không cần đa kế thừa
mixin CoTheBay {
  void bay() {
    print("   🦅 Đang cất cánh bay lượn trên bầu trời xanh!");
  }
}

mixin CoTheBoi {
  void boi() {
    print("   🐟 Đang lặn ngụp và bơi lội dưới làn nước!");
  }
}

mixin CoTheChayNhanh {
  int tocDoToiDa = 80;
  void chay() {
    print("   🐆 Đang phóng nhanh với vận tốc $tocDoToiDa km/h!");
  }
}

// Lớp cơ sở
abstract class DongVat {
  String ten;
  DongVat(this.ten);
}

// Vịt trời: vừa biết bay, vừa biết bơi (Sử dụng từ khóa with)
class VitTroi extends DongVat with CoTheBay, CoTheBoi {
  VitTroi(super.ten);
}

// Siêu anh hùng: bay được, chạy siêu nhanh
class SieuNhan extends DongVat with CoTheBay, CoTheChayNhanh {
  SieuNhan(super.ten);
}

void main([List<String>? args]) {
  print("=== BÀI 21: SỬ DỤNG MIXIN TÁI SỬ DỤNG HÀNH VI ĐA HÌNH ===");

  var donald = VitTroi("Vịt Donald");
  print("1. Kiểm tra năng lực của ${donald.ten}:");
  donald.bay();
  donald.boi();

  var hero = SieuNhan("Flash Khanh");
  print("\n2. Kiểm tra năng lực của ${hero.ten}:");
  hero.bay();
  hero.chay();
  print("=========================================================");
}
