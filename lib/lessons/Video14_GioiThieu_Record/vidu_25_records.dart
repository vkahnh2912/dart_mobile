// Bài 14 - Ví dụ 25: Giới thiệu về Record trong Dart (từ Dart 3.0)
// Video: https://www.youtube.com/watch?v=8wIqlz-Z7Dg

void main() {
  var r = ('first', a: 2, 5, 10.5); // record hỗn hợp

  // Định nghĩa record có 2 giá trị
  var point = (123, 456); // x, y

  // Định nghĩa person
  var person = (name: 'Alice', age: 25, 5);

  // Truy cập giá trị trong record:
  // 1. Dùng chỉ số (positional fields: $1, $2, ...)
  print(point.$1); // 123
  print(point.$2); // 456
  print(person.$1); // 5 (vì 'name' và 'age' là named fields nên 5 là positional field thứ 1)

  // 2. Dùng tên (named fields)
  print(person.name); // Alice
  print(person.age); // 25

  print('Record r: first=${r.$1}, a=${r.a}, second=${r.$2}, third=${r.$3}');
}
