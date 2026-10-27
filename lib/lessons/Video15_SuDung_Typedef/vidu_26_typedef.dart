// Bài 15 - Ví dụ 26: Cách sử dụng Typedef trong Dart
// Video: https://www.youtube.com/watch?v=lXIdchI7BB4

typedef IntList = List<int>;

typedef ListMapper<X> = Map<X, List<X>>;

typedef Compare<T> = int Function(T a, T b);

void main() {
  IntList l1 = [1, 2, 3, 4, 5];
  print(l1);

  IntList l2 = [1, 2, 3, 4, 5, 6, 7];
  print(l2);

  Map<String, List<String>> m1 = {};
  ListMapper<String> m2 = {};

  m1['nhomA'] = ['An', 'Binh'];
  m2['nhomB'] = ['Cuong', 'Dung'];
  print('m1: $m1');
  print('m2: $m2');

  Compare<int> sortDesc = (a, b) => b.compareTo(a);
  IntList l3 = [3, 1, 9, 4];
  l3.sort(sortDesc);
  print('Sắp xếp giảm dần với typedef Compare<int>: $l3');
}
