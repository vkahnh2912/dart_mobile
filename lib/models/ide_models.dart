import 'dart:convert';

/// Đại diện cho một file mã nguồn .dart do người dùng tạo
class UserFile {
  final String id;
  String name;
  String content;
  DateTime updatedAt;

  UserFile({
    required this.id,
    required this.name,
    required this.content,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'content': content,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserFile.fromMap(Map<String, dynamic> map) {
    return UserFile(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String? ?? 'untitled.dart',
      content: map['content'] as String? ?? '',
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Đại diện cho một Project (thư mục chứa nhiều file .dart)
class UserProject {
  final String id;
  String name;
  String description;
  DateTime createdAt;
  List<UserFile> files;

  UserProject({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.files,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'files': files.map((f) => f.toMap()).toList(),
    };
  }

  factory UserProject.fromMap(Map<String, dynamic> map) {
    final rawFiles = map['files'] as List<dynamic>? ?? [];
    return UserProject(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name'] as String? ?? 'Dự án mới',
      description: map['description'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      files: rawFiles
          .map((f) => UserFile.fromMap(f as Map<String, dynamic>))
          .toList(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProject.fromJson(String source) =>
      UserProject.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
