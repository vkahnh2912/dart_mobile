// Bài 24: Hướng dẫn cài đặt Flutter SDK & Thiết lập môi trường phát triển
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

import 'dart:io';

void main([List<String>? args]) {
  print("=== BÀI 24: CÀI ĐẶT FLUTTER SDK & THIẾT LẬP MÔI TRƯỜNG ===");
  print("1. Các bước cài đặt Flutter SDK chuẩn:");
  print("   • Bước 1: Tải bộ cài Flutter từ trang chủ https://docs.flutter.dev");
  print("   • Bước 2: Giải nén thư mục flutter vào ổ đĩa (VD: C:\\src\\flutter)");
  print("   • Bước 3: Thêm đường dẫn 'C:\\src\\flutter\\bin' vào biến môi trường PATH");
  print("   • Bước 4: Mở Terminal và gõ lệnh kiểm tra: flutter doctor -v");

  print("\n2. Kiểm tra thông số máy hiện tại:");
  print("   • Hệ điều hành: ${Platform.operatingSystem} (${Platform.operatingSystemVersion})");
  print("   • Dart SDK: ${Platform.version.split(' ').first}");
  print("   • Số nhân CPU: ${Platform.numberOfProcessors}");
  print("   • Đường dẫn thực thi: ${Platform.resolvedExecutable}");

  print("\n3. Ý nghĩa các biểu tượng trong Flutter Doctor:");
  print("   [√] Đã cài đặt hoàn chỉnh và sẵn sàng hoạt động");
  print("   [!] Cảnh báo hoặc giấy phép cần chấp nhận (flutter doctor --android-licenses)");
  print("   [X] Thành phần chưa được cài đặt (Cần cài thêm để lập trình)");
  print("==========================================================");
}
