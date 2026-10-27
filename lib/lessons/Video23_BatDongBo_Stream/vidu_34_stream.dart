// Bài 23: Lập trình Bất Đồng Bộ - Giới thiệu về STREAM trong Dart
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

import 'dart:async';

// Hàm generator phát sinh dữ liệu liên tục qua Stream (sử dụng async* và yield)
Stream<int> taoDongDemNguoc(int max) async* {
  for (int i = 1; i <= max; i++) {
    yield i;
  }
}

void main([List<String>? args]) async {
  print("=== BÀI 23: LẬP TRÌNH BẤT ĐỒNG BỘ VỚI STREAM ===");
  print("1. Khái niệm Stream: Chuỗi các sự kiện hoặc dữ liệu trả về theo thời gian.");

  print("\n2. Lắng nghe dòng dữ liệu từ Stream Generator:");
  await for (int giaTri in taoDongDemNguoc(5)) {
    print("   📡 Nhận gói tin Stream số: $giaTri");
  }

  print("\n3. Sử dụng StreamController thủ công:");
  final controller = StreamController<String>();

  // Đăng ký lắng nghe (listen)
  final subscription = controller.stream.listen(
    (data) => print("   🔔 Thông báo Stream: $data"),
    onDone: () => print("   🏁 StreamController đã hoàn thành và đóng kết nối!"),
  );

  controller.add("Khởi tạo tiến trình");
  controller.add("Tải thành phần UI");
  controller.add("Sẵn sàng phục vụ anh Khánh đẹp trai nhất vũ trụ!");

  await controller.close();
  await subscription.cancel();

  print("=================================================");
}
