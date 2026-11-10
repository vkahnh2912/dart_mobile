// Bài 46: Kỹ thuật Dùng Firebase tạo CSDL & Backend (Đăng ký, Đăng nhập, Sửa Profile)
// Dành riêng cho: Anh Khánh đẹp trai nhất vũ trụ (Vũ Trọng Khánh - PM28.12)

void main() {
  print('=== BÀI 46: FIREBASE AUTHENTICATION & CLOUD CSDL PROFILE ===');
  print('1. Đăng ký (Sign Up): POST https://identitytoolkit.googleapis.com/v1/accounts:signUp');
  print('2. Đăng nhập (Sign In): POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword');
  print('3. Khởi tạo & Sửa Profile trên CSDL Firebase: PUT / PATCH /users/{uid}.json');
  print('4. Đồng bộ điểm kỷ lục Game (high_score) & Ghi chú SQLite lên Cloud CSDL!');
}

