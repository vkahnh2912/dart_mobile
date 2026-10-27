// Bài 13 - Ví dụ 21: Kiểu dữ liệu Runes và biểu tượng Emoji
// Video: https://www.youtube.com/watch?v=Z5roSszYgJI

void main() {
  String str = 'Hello';
  Runes runes1 = str.runes;

  Runes runes2 = Runes('\u2665'); // Ký tự trái tim (♥)
  print(runes2);

  Runes runes3 = Runes('\u{1f600}'); // Emoji mặt cười 😀
  print(runes3);

  String heartSymbol = String.fromCharCodes(runes2);
  print(heartSymbol); // ♥

  String emoji = String.fromCharCode(0x1f600);
  print(emoji); // 😀

  print(runes1.length); // 5
  print(runes1.first); // 72 ('H')
  print(runes1.last); // 111 ('o')

  Runes inputRunes = 'Xin chào 😀, tôi ♥ bạn!'.runes;
  inputRunes.forEach((int rune) {
    print('Unicode: $rune, Ký tự: ${String.fromCharCode(rune)}');
  });

  print(runes1.isEmpty); // false
  print(runes1.isNotEmpty); // true
}
