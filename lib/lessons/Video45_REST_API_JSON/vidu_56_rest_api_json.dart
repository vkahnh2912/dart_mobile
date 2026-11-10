// Bài 45: Kỹ thuật Gọi REST API trên mạng (HTTP GET / POST) & Giải mã JSON hiển thị lên App
// Dành riêng cho: Anh Khánh đẹp trai nhất vũ trụ (Vũ Trọng Khánh - PM28.12)

void main() {
  print('=== BÀI 45: KỸ THUẬT GỌI REST API TRÊN MẠNG & GIẢI MÃ JSON ===');
  print('1. Gửi HTTP GET tới: https://dummyjson.com/products?limit=24');
  print('2. Giải mã chuỗi JSON bằng jsonDecode(body) sang List<ApiProduct>.fromJson()');
  print('3. Gửi HTTP POST tới: https://dummyjson.com/posts/add để tạo bài viết mới');
  print('4. Hiển thị dữ liệu lên App bằng ListView / Card và cho phép lưu thẳng vào SQLite!');
}

