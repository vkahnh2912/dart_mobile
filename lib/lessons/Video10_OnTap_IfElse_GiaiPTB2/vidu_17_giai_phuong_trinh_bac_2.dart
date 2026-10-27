// Bài 10 - Ví dụ 17: Ôn tập câu lệnh điều kiện if-else - Giải phương trình bậc 2 (ax^2 + bx + c = 0)
// Video: https://www.youtube.com/watch?v=zQ1olRwC3nw

import 'dart:math';
import 'dart:io';

void solveEquation([double? customA, double? customB, double? customC]) {
  double a = 0, b = 0, c = 0;

  if (customA != null && customB != null && customC != null) {
    a = customA;
    b = customB;
    c = customC;
  } else if (stdin.hasTerminal) {
    do {
      stdout.write("Nhap he so a (a khac 0): ");
      String? input = stdin.readLineSync();
      if (input != null) {
        a = double.tryParse(input) ?? 0;
      }
    } while (a == 0);

    stdout.write("Nhap he so b: ");
    String? inputB = stdin.readLineSync();
    if (inputB != null) {
      b = double.tryParse(inputB) ?? 0;
    }

    stdout.write("Nhap he so c: ");
    String? inputC = stdin.readLineSync();
    if (inputC != null) {
      c = double.tryParse(inputC) ?? 0;
    }
  } else {
    a = 1;
    b = -5;
    c = 6;
    print('[Mobile Simulator] Phương trình mẫu: 1x^2 - 5x + 6 = 0');
  }

  double delta = b * b - 4 * a * c;

  print('Phuong trinh: ${a}x^2 + ${b}x + $c = 0');

  if (delta < 0) {
    print('Phuong trinh vo nghiem!');
  } else if (delta == 0) {
    double x = -b / (2 * a);
    print("Phuong trinh co nghiem kep x1 = x2 = ${x.toStringAsFixed(2)}");
  } else {
    double x1 = (-b - sqrt(delta)) / (2 * a);
    double x2 = (-b + sqrt(delta)) / (2 * a);
    print('Phuong trinh co 2 nghiem phan biet:');
    print('x1 = ${x1.toStringAsFixed(2)}');
    print('x2 = ${x2.toStringAsFixed(2)}');
  }
}

void main([List<String>? args]) {
  solveEquation();
}
