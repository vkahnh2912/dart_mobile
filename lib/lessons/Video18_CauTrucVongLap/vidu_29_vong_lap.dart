// Bài 18: Ôn tập các cấu trúc vòng lặp trong Dart (for, while, do-while, for-in)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 18: CÁC CẤU TRÚC VÒNG LẶP TRONG DART ===");

  // 1. Vòng lặp for đếm bước
  print("1. Vòng lặp for cơ bản (in bảng cửu chương 5):");
  for (int i = 1; i <= 5; i++) {
    print("   5 x $i = ${5 * i}");
  }

  // 2. Vòng lặp for-in duyệt danh sách
  print("\n2. Vòng lặp for-in qua danh sách ngôn ngữ:");
  final ngonNgu = ["Dart", "Flutter", "Python", "JavaScript", "C++"];
  for (var lang in ngonNgu) {
    print("   🔥 Ngôn ngữ: $lang");
  }

  // 3. Vòng lặp while
  print("\n3. Vòng lặp while (tính tổng 1 + 2 + 3 + ... + 5):");
  int sum = 0;
  int k = 1;
  while (k <= 5) {
    sum += k;
    k++;
  }
  print("   Tổng sum = $sum");

  // 4. Vòng lặp do-while
  print("\n4. Vòng lặp do-while (chạy ít nhất 1 lần):");
  int dem = 3;
  do {
    print("   Đếm ngược: $dem");
    dem--;
  } while (dem > 0);

  // 5. Điều khiển vòng lặp với break và continue
  print("\n5. Sử dụng continue (bỏ qua số chẵn, chỉ in số lẻ):");
  List<int> soLe = [];
  for (int i = 1; i <= 10; i++) {
    if (i % 2 == 0) continue; // Bỏ qua số chẵn
    if (i > 7) break; // Dừng khi gặp số lớn hơn 7
    soLe.add(i);
  }
  print("   Kết quả: $soLe");
  print("=================================================");
}
