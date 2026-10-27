// Bài 12 - Ví dụ 19: Cấu trúc dữ liệu Set trong Dart
// Video: https://www.youtube.com/watch?v=0sICP2qI_BI

void main() {
  Set<String> set1 = {'A', 'B', 'C'};
  var set2 = <int>{1, 2, 3};
  Set<String> set3 = Set();
  var set4 = Set<int>.from([1, 2, 2, 3]);

  set1.add('D');
  set1.addAll(['E', 'F']);
  set1.remove('A');
  set1.removeAll(['B', 'C']);
  set1.clear();

  print(set2.length);
  print(set3.isEmpty);
  print(set2.contains(1));

  var set5 = {1, 2, 3};
  var set6 = {3, 4, 5};

  var union = set5.union(set6);
  var intersection = set5.intersection(set6);
  var difference = set5.difference(set6);
  var difference2 = set6.difference(set5);
  print('Union: $union');
  print('Intersection: $intersection');
  print('Difference (set5 - set6): $difference');
  print('Difference (set6 - set5): $difference2');

  Set<String> names = {'An', 'Binh', 'Cuong'};
  var list = names.toList();
  var newSet = Set<String>.from(names);
  var filtered = names.where((e) => e.startsWith('A'));
  var mapped = names.map((e) => e.toLowerCase());
  print('Filtered: $filtered, Mapped: $mapped');

  names.forEach((element) {
    print(element);
  });

  Set<String> friendIds = {'user1', 'user2', 'user3'};
  friendIds.add('user4');
  friendIds.add('user1');

  bool isFriend = friendIds.contains('user1');
  print('user1 có phải bạn bè: $isFriend');

  Set<String> suggestions = {'user5', 'user6', 'user1'};
  var newFriends = suggestions.difference(friendIds);
  print('Gợi ý kết bạn mới: $newFriends');
}
