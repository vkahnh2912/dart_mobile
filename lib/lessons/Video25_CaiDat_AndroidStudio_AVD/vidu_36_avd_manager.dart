// Bài 25: Cài đặt Android Studio & Cấu hình máy ảo AVD (Android Virtual Device)
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j

void main([List<String>? args]) {
  print("=== BÀI 25: CÀI ĐẶT ANDROID STUDIO & CẤU HÌNH MÁY ẢO AVD ===");
  print("1. Tại sao cần cài Android Studio:");
  print("   • Cung cấp Android SDK Build-Tools và Platform-Tools (adb, emulator)");
  print("   • Cung cấp máy ảo điện thoại mô phỏng phần cứng thực tế (GPS, camera, xoay màn hình)");
  print("   • Trình quản lý AVD Manager trực quan.");

  print("\n2. Cách tạo máy ảo tối ưu (như máy FLAPPY FLY PIXEL của anh Khánh):");
  print("   • Mở Android Studio ➔ Virtual Device Manager ➔ Create Device");
  print("   • Chọn thiết bị: Pixel 7 Pro hoặc Pixel 8 Pro");
  print("   • Chọn phiên bản Android System Image: Android 15 (VanillaIceCream API 35 x86_64)");
  print("   • Bật tính năng tăng tốc phần cứng Hyper-V / Windows Hypervisor Platform");

  print("\n3. Các lệnh điều khiển máy ảo nhanh từ dòng lệnh:");
  print("   • Xem danh sách: flutter emulators");
  print("   • Khởi chạy máy ảo: flutter emulators --launch FLAPPY_FLY_PIXEL");
  print("   • Kiểm tra kết nối thiết bị: adb devices");
  print("=============================================================");
}
