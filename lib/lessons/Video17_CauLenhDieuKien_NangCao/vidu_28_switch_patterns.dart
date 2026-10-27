// Bài 17: Ôn tập câu lệnh điều kiện nâng cao (Switch-Case & Pattern Matching)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

String layTenThuTrongTuan(int thu) {
  // Cú pháp Switch Expression hiện đại trong Dart 3
  return switch (thu) {
    1 => "Chủ Nhật",
    2 => "Thứ Hai",
    3 => "Thứ Ba",
    4 => "Thứ Tư",
    5 => "Thứ Năm",
    6 => "Thứ Sáu",
    7 => "Thứ Bảy",
    _ => "Ngày không hợp lệ",
  };
}

String danhGiaDiem(double diem) {
  // Pattern matching với điều kiện so sánh guarded pattern
  return switch (diem) {
    >= 9.0 && <= 10.0 => "Xuất sắc (Học bổng loại A)",
    >= 8.0 && < 9.0 => "Giỏi (Học bổng loại B)",
    >= 6.5 && < 8.0 => "Khá",
    >= 5.0 && < 6.5 => "Trung bình",
    >= 0.0 && < 5.0 => "Yếu (Cần cố gắng thêm)",
    _ => "Điểm số không hợp lệ",
  };
}

void main([List<String>? args]) {
  print("=== BÀI 17: CÂU LỆNH ĐIỀU KIỆN & SWITCH EXPRESSIONS ===");
  print("1. Tra cứu thứ trong tuần:");
  print("   Thứ 2 là: ${layTenThuTrongTuan(2)}");
  print("   Thứ 7 là: ${layTenThuTrongTuan(7)}");

  print("\n2. Đánh giá học lực với Pattern Matching:");
  double diemKhanh = 9.5;
  print("   Điểm số $diemKhanh: ${danhGiaDiem(diemKhanh)}");
  print("   Điểm số 7.2: ${danhGiaDiem(7.2)}");

  print("\n3. Toán tử 3 ngôi (Ternary Operator):");
  int tuoi = 22;
  String trangThai = tuoi >= 18 ? "Đã đủ tuổi công dân" : "Chưa đủ tuổi";
  print("   Tuổi $tuoi: $trangThai");

  print("\n4. Toán tử Null-coalescing (??):");
  String? tenChuaNhap;
  String tenMacDinh = tenChuaNhap ?? "Khách quý";
  print("   Xin chào, $tenMacDinh!");
  print("=====================================================");
}
