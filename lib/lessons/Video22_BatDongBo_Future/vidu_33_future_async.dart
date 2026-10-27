// Bài 22: Lập trình Bất Đồng Bộ - Giới thiệu về Future và async/await trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

import 'dart:async';

// Hàm giả lập tải dữ liệu từ máy chủ mất thời gian
Future<String> layDuLieuTuServer() async {
  print("   [Server] Đang kết nối tới máy chủ TITV...");
  // Giả lập độ trễ 200 miligiây để chạy nhanh trên simulator
  await Future.delayed(const Duration(milliseconds: 200));
  return "Dữ liệu danh sách 56 bài học Flutter đã tải thành công!";
}

Future<double> tinhToanNang() async {
  await Future.delayed(const Duration(milliseconds: 100));
  return 99.99;
}

void main([List<String>? args]) async {
  print("=== BÀI 22: LẬP TRÌNH BẤT ĐỒNG BỘ (FUTURE & ASYNC/AWAIT) ===");
  print("1. Bắt đầu tác vụ bất đồng bộ:");

  try {
    String ketQua = await layDuLieuTuServer();
    print("2. Nhận kết quả: $ketQua");

    double soDiem = await tinhToanNang();
    print("3. Điểm số tối ưu hóa: $soDiem%");
  } catch (error) {
    print("❌ Xảy ra lỗi khi gọi dữ liệu: $error");
  } finally {
    print("4. Đóng kết nối máy chủ an toàn.");
  }

  print("============================================================");
}
