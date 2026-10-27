// Bài 31: Flutter Widgets - Bố cục Column và Row
// Video: https://www.youtube.com/playlist?list=PLyxSzL3F7484qhNw1K08o8kDn8ecCpA_j
// Tác giả khóa học: TITV - Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀

void main([List<String>? args]) {
  print('=== BÀI 31: FLUTTER WIDGETS - COLUMN VÀ ROW ===');
  print('1. Khái niệm cơ bản:');
  print('   • Row: Sắp xếp các widget con theo chiều NGANG (trục chính x).');
  print('   • Column: Sắp xếp các widget con theo chiều DỌC (trục chính y).');

  print('\n2. Các thuộc tính căn lề quan trọng:');
  print('   • mainAxisAlignment: Căn lề theo trục chính');
  print('       - MainAxisAlignment.start: Dồn về đầu trục.');
  print('       - MainAxisAlignment.center: Căn giữa.');
  print('       - MainAxisAlignment.end: Dồn về cuối trục.');
  print('       - MainAxisAlignment.spaceBetween: Dãn đều, 2 đầu sát mép.');
  print('       - MainAxisAlignment.spaceAround: Dãn đều, viền ngoài có khoảng cách nhỏ.');
  print('       - MainAxisAlignment.spaceEvenly: Dãn đều mọi khoảng cách bằng nhau.');
  print('   • crossAxisAlignment: Căn lề theo trục vuông góc');
  print('       - CrossAxisAlignment.center / start / end / stretch.');

  print('\n3. Chống tràn màn hình (Overflow Error) với Expanded & Spacer:');
  print(r'''
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.star, color: Colors.amber),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Học Flutter cùng anh Khánh đẹp trai nhất vũ trụ',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16),
          ),
        ),
        Spacer(),
        ElevatedButton(
          onPressed: () {},
          child: Text('Chi tiết'),
        ),
      ],
    )
  ''');

  print('4. Quy tắc vàng khi làm Layout:');
  print('   • Khi phần tử văn bản dài trong Row, LUÔN bọc trong Expanded hoặc Flexible.');
  print('   • Sử dụng Column bọc trong SingleChildScrollView khi danh sách có thể dài quá màn hình.');
  print('==================================================');
}
