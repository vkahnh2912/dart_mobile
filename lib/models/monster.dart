class Monster {
  final int? id;
  final String name;
  final int hp;
  final int damage;
  final double speed;
  final int score;
  final String image;

  const Monster({
    this.id,
    required this.name,
    required this.hp,
    required this.damage,
    required this.speed,
    required this.score,
    required this.image,
  });

  // Khởi tạo đối tượng Monster từ Map đọc từ bảng `monsters` trong SQLite (game.db)
  factory Monster.fromMap(Map<String, dynamic> map) {
    return Monster(
      id: map['id'] as int?,
      name: (map['name'] ?? '') as String,
      hp: (map['hp'] as num?)?.toInt() ?? 100,
      damage: (map['damage'] as num?)?.toInt() ?? 20,
      speed: (map['speed'] as num?)?.toDouble() ?? 2.0,
      score: (map['score'] as num?)?.toInt() ?? 100,
      image: (map['image'] ?? 'assets/images/purple_demon.png') as String,
    );
  }

  // Chuyển đối tượng Monster thành Map để lưu vào bảng `monsters` trong SQLite (game.db)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'hp': hp,
      'damage': damage,
      'speed': speed,
      'score': score,
      'image': image,
    };
  }

  Monster copyWith({
    int? id,
    String? name,
    int? hp,
    int? damage,
    double? speed,
    int? score,
    String? image,
  }) {
    return Monster(
      id: id ?? this.id,
      name: name ?? this.name,
      hp: hp ?? this.hp,
      damage: damage ?? this.damage,
      speed: speed ?? this.speed,
      score: score ?? this.score,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'Monster(id: $id, name: $name, hp: $hp, damage: $damage, speed: $speed, score: $score, image: $image)';
  }
}

