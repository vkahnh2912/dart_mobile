class NoteItem {
  final int? id;
  final String title;
  final String content;
  final String category;
  final int priority; // 1: Bình thường, 2: Quan trọng, 3: Khẩn cấp
  final bool isCompleted;
  final String createdAt;

  const NoteItem({
    this.id,
    required this.title,
    required this.content,
    required this.category,
    this.priority = 2,
    this.isCompleted = false,
    required this.createdAt,
  });

  // Chuyển đối tượng NoteItem sang Map<String, dynamic> để lưu vào bảng SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content,
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt,
    };
  }

  // Khởi tạo đối tượng NoteItem từ Map<String, dynamic> đọc từ SQLite
  factory NoteItem.fromMap(Map<String, dynamic> map) {
    return NoteItem(
      id: map['id'] as int?,
      title: (map['title'] ?? '') as String,
      content: (map['content'] ?? '') as String,
      category: (map['category'] ?? 'Học tập') as String,
      priority: (map['priority'] as int?) ?? 2,
      isCompleted: ((map['isCompleted'] as int?) ?? 0) == 1,
      createdAt: (map['createdAt'] ?? '') as String,
    );
  }

  NoteItem copyWith({
    int? id,
    String? title,
    String? content,
    String? category,
    int? priority,
    bool? isCompleted,
    String? createdAt,
  }) {
    return NoteItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

