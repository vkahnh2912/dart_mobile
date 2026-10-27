// Bài 12 - Ví dụ 20: Cấu trúc dữ liệu Map trong Dart
// Video: https://www.youtube.com/watch?v=0sICP2qI_BI

void main() {
  Map<String, dynamic> user1 = {
    'name': 'Tung',
    'age': 20,
    'isStudent': true,
    'address': 'Tung'
  };

  var user2 = <String, dynamic>{
    'name': 'Hoa',
    'age': 25
  };

  Map<int, String> numbers = {};
  var emptyMap = Map<String, int>();

  user1['email'] = 'tung@gmail.com';
  user1['age'] = 21;
  user1.putIfAbsent('phone', () => '0123456789');
  user1.addAll({
    'address': 'Ha Noi',
    'gender': 'male'
  });

  user1.remove('age');
  user1.removeWhere((key, value) => value == null);
  numbers.clear();

  print(user1['name']);
  print(user1.length);

  String phone = user1['phone'] ?? 'Khong co so dien thoai';
  print('Phone: $phone');

  print(user1.isEmpty);
  print(user1.isNotEmpty);
  print(user1.containsKey('name'));
  print(user1.containsValue('Tung'));

  print('Keys: ${user1.keys}');
  print('Values: ${user1.values}');
  print('Entries: ${user1.entries}');

  user1.forEach((key, value) {
    print('$key: $value');
  });

  for (var entry in user1.entries) {
    print('${entry.key} -> ${entry.value}');
  }

  var upperMap = user1.map((key, value) =>
      MapEntry(key.toUpperCase(), value.toString().toUpperCase()));
  print('UpperMap: $upperMap');

  var filteredMap = Map.fromEntries(
      user1.entries.where((entry) => entry.value is String));
  print('FilteredMap (chỉ lấy value kiểu String): $filteredMap');

  Map<String, int> cart = {
    'SP001': 2,
    'SP002': 1,
    'SP003': 3
  };

  void addToCart(String productId) {
    cart.update(
      productId,
      (quantity) => quantity + 1,
      ifAbsent: () => 1,
    );
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      cart.remove(productId);
    } else {
      cart[productId] = quantity;
    }
  }

  addToCart('SP001');
  addToCart('SP004');
  updateQuantity('SP002', 5);
  print('Giỏ hàng sau khi cập nhật: $cart');
}
