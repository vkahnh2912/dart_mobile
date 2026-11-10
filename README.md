# 🚀 Ứng Dụng Học Tập & Thực Hành Dart / Flutter Toàn Diện (`dart_mobile`)

> **Tác giả**: **Vũ Trọng Khánh** — Lớp **PM28.12**  
> **GitHub**: [https://github.com/vkahnh2912/dart_mobile](https://github.com/vkahnh2912/dart_mobile)

---

## 📌 1. Giới Thiệu Dự Án

Dự án **Dart & Flutter Toàn Diện (`VuTrongKhanh.PM28.12`)** là ứng dụng di động đa năng tích hợp trọn vẹn chương trình thực hành lập trình thiết bị di động với **3 kỹ thuật trọng tâm** cùng hệ thống bài giảng, trình soạn thảo code và Game 2D Arcade:

### 🎯 3 Kỹ Thuật Trọng Tâm
1. **Kỹ thuật 1 — Sử dụng thành thạo SQLite (`sqflite`)**:
   - Cơ sở dữ liệu **`game.db`** ([`lib/database/database_helper.dart`](lib/database/database_helper.dart)):
     - Bảng `monsters` (`id`, `name`, `hp`, `damage`, `speed`, `score`, `image`): Quản lý danh sách quái vật trong game với đầy đủ **CRUD (Thêm, Xem, Sửa, Xóa)**, chọn 4 mẫu sprite cắt sẵn (`purple_demon.png`, `crimson_demon.png`, `cyber_demon.png`, `emerald_demon.png`).
     - Bảng `players` (`id`, `name`, `high_score`, `current_stage`, `created_at`): Lưu kỷ lục điểm cao nhất (`high_score`) và màn chơi cao nhất đã mở khóa (`Stage 1–8`).
   - Cơ sở dữ liệu **`vutrongkhanh_notes.db`** ([`lib/services/note_database_helper.dart`](lib/services/note_database_helper.dart)):
     - Quản lý ghi chú học tập & công việc (Thêm, Sửa, Xóa, Tìm kiếm theo từ khóa, Lọc theo danh mục và Mức độ ưu tiên).

2. **Kỹ thuật 2 — Gọi các REST API trên mạng & Hiển thị dữ liệu JSON (`HTTP GET / POST / PUT / DELETE`)**:
   - Kết nối trực tiếp tới các REST API công khai trên mạng ([`lib/services/api_service.dart`](lib/services/api_service.dart) & [`lib/screens/rest_api_screen.dart`](lib/screens/rest_api_screen.dart)):
     - `GET https://dummyjson.com/products?limit=24` & `/products/search?q=...`: Tải danh sách sản phẩm công nghệ, tìm kiếm trực tuyến trên API.
     - `GET / POST / PUT / DELETE https://dummyjson.com/posts`: Xem danh sách bài viết, đăng bài viết mới lên API (`POST /posts/add`), sửa bài viết (`PUT /posts/{id}`), xóa bài viết (`DELETE /posts/{id}`).
     - `GET https://dummyjson.com/users?limit=18`: Tải danh sách hồ sơ người dùng trực tuyến.
     - **Tải Quái vật từ API vào Game (`game.db`)**: Tải cấu hình quái vật từ API và nạp trực tiếp vào bảng `monsters` trong SQLite.
     - **Trình Test URL API tùy chỉnh & Live JSON Console**: Cho phép nhập bất kỳ đường dẫn REST API nào trên mạng và xem phản hồi JSON trực tiếp kèm thời gian phản hồi (`ms`).

3. **Kỹ thuật 3 — Dùng Firebase tạo CSDL & Backend (`Authentication` & `Cloud Database`)**:
   - Kết nối trực tiếp với dự án Firebase **`khanh-app`** qua [`android/app/google-services.json`](android/app/google-services.json) và [`lib/services/firebase_backend_service.dart`](lib/services/firebase_backend_service.dart):
     - **Đăng ký tài khoản mới (`signUp`)**: Gọi `POST https://identitytoolkit.googleapis.com/v1/accounts:signUp` tạo tài khoản thật trên Firebase Authentication và khởi tạo hồ sơ người dùng.
     - **Đăng nhập (`signInWithPassword`)**: Xác thực Email/Password, cấp phát `idToken` (JWT) và tự động duy trì phiên đăng nhập.
     - **Sửa Profile người dùng (`updateProfile`)**: Cập nhật Họ tên (`displayName`), Lớp/MSSV (`studentId`), Số điện thoại (`phone`), Giới thiệu (`bio`), Ảnh đại diện (`avatarUrl`).
     - **Đổi mật khẩu & Đồng bộ Đám mây**: Đồng bộ Kỷ lục điểm cao Game (`highScore`), Màn chơi cao nhất (`highestStage`) và số lượng Ghi chú từ SQLite lên Cloud Database (`/users/{uid}`).

---

## 🛠️ 2. Yêu Cầu Cài Đặt Môi Trường (Environment Requirements)

Để biên dịch và chạy dự án mượt mà trên máy tính, cần cài đặt các công cụ sau:

| Công cụ / Thành phần | Phiên bản khuyến nghị | Công dụng |
| :--- | :--- | :--- |
| **Flutter SDK** | `>= 3.11.0` (Stable) | Framework phát triển ứng dụng đa nền tảng |
| **Dart SDK** | `>= 3.11.0` (đi kèm Flutter) | Ngôn ngữ lập trình chính của dự án |
| **Java Development Kit (JDK)** | **JDK 17** | Biên dịch Gradle cho ứng dụng Android |
| **Android Studio / Android SDK** | Android SDK Platform 34+ | Cung cấp Android Build-Tools, Platform-Tools (`adb`) & Máy ảo AVD |
| **Git** | `>= 2.35+` | Quản lý mã nguồn và clone dự án từ GitHub |
| **VS Code / Android Studio** | Mới nhất | IDE lập trình (cài thêm extension **Flutter** & **Dart**) |

### 📦 Các thư viện (`dependencies`) sử dụng trong `pubspec.yaml`
- `sqflite: ^2.4.2` & `sqflite_common_ffi: ^2.3.5` — Quản trị cơ sở dữ liệu SQLite trên Android, iOS và Desktop.
- `path: ^1.9.1` — Xử lý đường dẫn file cơ sở dữ liệu (`game.db`, `vutrongkhanh_notes.db`).
- `shared_preferences: ^2.3.2` — Lưu trữ cấu hình và phiên đăng nhập Firebase.
- `audioplayers: ^6.6.0` — Phát hiệu ứng âm thanh trong Game.

> **Kiểm tra môi trường nhanh**: Mở Terminal / PowerShell và chạy lệnh:
> ```bash
> flutter doctor -v
> ```
> Đảm bảo các mục **Flutter**, **Android toolchain**, và **Connected device** đều có dấu tích xanh `[✓]`.

---

## ⚙️ 3. Hướng Dẫn Cài Đặt & Khởi Chạy Dự Án

### Bước 1: Clone dự án từ GitHub
```bash
git clone https://github.com/vkahnh2912/dart_mobile.git
cd dart_mobile
```

### Bước 2: Cài đặt các gói thư viện (Packages)
```bash
flutter pub get
```

### Bước 3: Khởi động Máy ảo Android (hoặc cắm điện thoại Android thật)
- Kiểm tra danh sách thiết bị đang kết nối:
  ```bash
  flutter devices
  ```
- Nếu chưa bật máy ảo, có thể khởi chạy máy ảo từ Android Studio (**Device Manager**) hoặc qua dòng lệnh:
  ```bash
  flutter emulators --launch <ten_may_ao_avd>
  ```

### Bước 4: Chạy ứng dụng lên thiết bị
```bash
flutter run
```

### Bước 5: Xuất file cài đặt `.apk` (khi cần nộp bài hoặc cài lên điện thoại)
- **Bản Debug APK (nhanh)**:
  ```bash
  flutter build apk --debug
  ```
  *(File nằm tại: `build/app/outputs/flutter-apk/app-debug.apk`)*
- **Bản Release APK (tối ưu dung lượng & hiệu năng)**:
  ```bash
  flutter build apk --release --no-tree-shake-icons
  ```
  *(File nằm tại: `build/app/outputs/flutter-apk/app-release.apk`)*

---

## 📱 4. Hướng Dẫn Sử Dụng Ứng Dụng (5 Tab Điều Hướng Chính)

Ứng dụng được thiết kế với thanh điều hướng 5 Tab trực quan ở phía dưới màn hình:

### 📖 Tab 1: `Bài Học` (Video 10 – Video 46)
- Tra cứu, tìm kiếm và lọc nhanh **47 bài thực hành** từ cơ bản đến nâng cao (Toán tử, List/Set/Map, OOP, Future/Stream, Flutter Widgets, SQLite, REST API, Firebase).
- Bấm vào bất kỳ bài học nào để xem **Mã nguồn Dart có tô màu cú pháp** và bấm **`▶ CHẠY VÍ DỤ NÀY`** để xem kết quả thực thi trực tiếp.
- Bấm biểu tượng **Terminal (`>_`)** trên thanh công cụ để mở **Không gian viết code (IDE Workspace)** hoặc bấm nút **Play danh sách** để chạy tự động toàn bộ bài tập.

### 🗄️ Tab 2: `1. SQLite` (Quản lý CSDL SQLite cục bộ)
- Xem thống kê tổng số bản ghi, số mục đã hoàn thành và đang thực hiện.
- **Thêm mới**: Bấm nút **`+ Thêm Ghi Chú SQLite`** để thêm bản ghi mới vào bảng `notes`.
- **Sửa / Xóa / Đánh dấu hoàn thành**: Chạm vào từng mục để chỉnh sửa nội dung, đổi mức độ ưu tiên (`1⭐ – 3⭐`) hoặc xóa khỏi SQLite.
- Hỗ trợ tìm kiếm theo từ khóa và lọc theo danh mục trực tiếp bằng truy vấn SQL.

### 🌐 Tab 3: `2. Gọi API` (Kỹ thuật gọi REST API trên mạng & JSON)
- Chuyển đổi giữa 4 Endpoint trực tuyến:
  1. **`SP`**: Danh sách sản phẩm lấy từ `GET https://dummyjson.com/products` + thanh tìm kiếm trực tuyến `/products/search?q=...`.
  2. **`Posts`**: Danh sách bài viết từ `GET https://dummyjson.com/posts`. Bấm **`POST Bài Viết Lên API`** để gửi dữ liệu mới, bấm biểu tượng `✏️` để gửi `PUT` sửa bài viết, hoặc `🗑️` để gửi `DELETE` xóa bài viết.
  3. **`Users`**: Danh sách người dùng lấy từ `GET https://dummyjson.com/users`.
  4. **`Quái API`**: Tải danh sách 4 Quái vật từ API và bấm **`Nạp Game`** (hoặc **`Nạp cả 4`**) để lưu thẳng vào bảng `monsters` của `game.db`.
- **Nút `Test URL` (`HTTP`)**: Nhập bất kỳ URL API nào trên mạng và bấm **`GỌI GET API & XEM JSON`** để kiểm tra dữ liệu trả về.
- **Nút `{}` (`Live Network Log`)**: Bật/tắt bảng nhật ký gói tin HTTP và chuỗi JSON thời gian thực.

### ☁️ Tab 4: `3. Firebase` (Firebase Authentication & Cloud Database)
- **Đăng ký tài khoản mới**: Chuyển sang chế độ **`ĐĂNG KÝ MỚI`**, nhập Email, Mật khẩu ($\ge 6$ ký tự), Họ tên, Lớp/MSSV, SĐT, Giới thiệu và bấm **`TẠO TÀI KHOẢN & LƯU LÊN FIREBASE CSDL`**. Tài khoản sẽ được tạo trực tiếp trên Firebase Authentication (`khanh-app`).
- **Đăng nhập**: Chọn nhanh tài khoản có sẵn trong danh sách `/users` bên dưới hoặc nhập Email/Mật khẩu rồi bấm **`ĐĂNG NHẬP FIREBASE NGAY`**.
- **Sửa Profile & Đồng bộ Cloud**: Sau khi đăng nhập, bấm **`SỬA PROFILE`** để cập nhật thông tin cá nhân & Avatar, hoặc bấm **`ĐỒNG BỘ CLOUD`** để đẩy kỷ lục điểm cao Game từ SQLite lên Firebase.
- **Cây dữ liệu Firebase**: Kéo xuống cuối màn hình để xem trực tiếp cấu trúc cây JSON `/users/{uid}`.

### 🎮 Tab 5: `Chơi Game` (Space Shooter 8 Màn & Flappy Bird kết nối SQLite `game.db`)
- **Chọn bàn chơi (`Stage 1` – `Stage 8`)**: Tự động mở khóa các màn tiếp theo khi vượt qua màn hiện tại và lưu vào bảng `players` trong `game.db`.
- **Quản lý Quái vật (`SQLite game.db`)**:
  - Bấm **`+`** để thêm quái vật mới, chọn nhanh **1 trong 4 hình giao diện Quái vật** đã cắt sẵn (`Tím`, `Đỏ`, `Xanh Băng`, `Xanh Lá`), tùy chỉnh `HP`, `Damage`, `Speed`, `Score`.
  - Bấm biểu tượng **Đám mây tải xuống (`☁️⬇️`)** để gọi API tải thêm quái vật mới vào `game.db`.
  - Khi bấm **`✏️` Sửa quái** và đổi hình ảnh của quái đầu tiên, hình ảnh quái vật bay trong màn chơi **Chiến Cơ Vũ Trụ (Space Shooter)** sẽ lập tức thay đổi theo!

---

## 📂 5. Cấu Trúc Thư Mục Mã Nguồn

```text
lib/
├── main.dart                          # Điểm khởi chạy ứng dụng & Khung điều hướng 5 Tab chính
├── lessons_registry.dart              # Danh mục đăng ký 47 bài thực hành (Video 10 - 46)
├── lesson_sources.dart                # Mã nguồn hiển thị trực tiếp cho từng bài học
├── database/
│   └── database_helper.dart           # Khởi tạo SQLite game.db (bảng monsters, players, firebase_users)
├── models/
│   ├── monster.dart                   # Model Monster (fromMap / toMap)
│   ├── note_model.dart                # Model NoteItem cho ứng dụng Ghi chú SQLite
│   ├── api_models.dart                # Model JSON cho REST API (ApiProduct, ApiArticle, ApiRemoteUser)
│   └── user_profile_model.dart        # Model Hồ sơ người dùng Firebase (FirebaseUserProfile)
├── repositories/
│   └── monster_repository.dart        # Tầng Repository xử lý CRUD cho bảng monsters & players
├── services/
│   ├── note_database_helper.dart      # Xử lý SQLite cho vutrongkhanh_notes.db
│   ├── api_service.dart               # Dịch vụ gọi HTTP GET / POST / PUT / DELETE tới REST API
│   └── firebase_backend_service.dart  # Dịch vụ kết nối Firebase Auth & Cloud Database (khanh-app)
├── screens/
│   ├── sqlite_notes_screen.dart       # Giao diện Kỹ thuật 1: Quản lý SQLite
│   ├── rest_api_screen.dart           # Giao diện Kỹ thuật 2: Gọi REST API & JSON
│   ├── firebase_backend_screen.dart   # Giao diện Kỹ thuật 3: Đăng ký, Đăng nhập & Sửa Profile Firebase
│   ├── ide_workspace_screen.dart      # Không gian quản lý Project & Viết code
│   └── code_editor_screen.dart        # Trình soạn thảo mã nguồn Dart
├── games/
│   ├── game_hub_screen.dart           # Trung tâm chọn Game, chọn Màn chơi & Quản lý Quái SQLite
│   ├── flappy_game.dart               # Game Flappy Bird Arcade
│   └── spaceshooter/                  # Game Chiến Cơ Vũ Trụ (Space Shooter 8 Stages + Boss)
└── lessons/                           # Thư mục chứa 47 bài tập thực hành từ Video 10 đến Video 46
```
