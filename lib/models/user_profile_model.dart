class FirebaseUserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String studentId;
  final String phone;
  final String bio;
  final String avatarUrl;
  final int highScore;
  final int highestStage;
  final int syncedNotesCount;
  final String idToken;
  final String createdAt;
  final String updatedAt;

  const FirebaseUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.studentId,
    required this.phone,
    required this.bio,
    required this.avatarUrl,
    this.highScore = 0,
    this.highestStage = 1,
    this.syncedNotesCount = 0,
    this.idToken = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory FirebaseUserProfile.fromMap(Map<String, dynamic> map) {
    return FirebaseUserProfile(
      uid: (map['uid'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      displayName: (map['display_name'] ?? map['displayName'] ?? 'Vũ Trọng Khánh').toString(),
      studentId: (map['student_id'] ?? map['studentId'] ?? 'PM28.12').toString(),
      phone: (map['phone'] ?? '0988888888').toString(),
      bio: (map['bio'] ?? 'Sinh viên xuất sắc lớp PM28.12 - Flutter & Firebase Developer').toString(),
      avatarUrl: (map['avatar_url'] ?? map['avatarUrl'] ?? 'assets/images/purple_demon.png').toString(),
      highScore: (map['high_score'] ?? map['highScore'] as num?)?.toInt() ?? 0,
      highestStage: ((map['highest_stage'] ?? map['highestStage'] as num?)?.toInt() ?? 1).clamp(1, 8),
      syncedNotesCount: (map['synced_notes_count'] ?? map['syncedNotesCount'] as num?)?.toInt() ?? 0,
      idToken: (map['id_token'] ?? map['idToken'] ?? '').toString(),
      createdAt: (map['created_at'] ?? map['createdAt'] ?? '').toString(),
      updatedAt: (map['updated_at'] ?? map['updatedAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'display_name': displayName,
      'student_id': studentId,
      'phone': phone,
      'bio': bio,
      'avatar_url': avatarUrl,
      'high_score': highScore,
      'highest_stage': highestStage,
      'synced_notes_count': syncedNotesCount,
      'id_token': idToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Chuyển đổi sang cấu trúc JSON chuẩn của Cloud Firestore / Realtime Database
  Map<String, dynamic> toFirebaseJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'studentId': studentId,
      'phone': phone,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'highScore': highScore,
      'highestStage': highestStage,
      'syncedNotesCount': syncedNotesCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  FirebaseUserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? studentId,
    String? phone,
    String? bio,
    String? avatarUrl,
    int? highScore,
    int? highestStage,
    int? syncedNotesCount,
    String? idToken,
    String? createdAt,
    String? updatedAt,
  }) {
    return FirebaseUserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      highScore: highScore ?? this.highScore,
      highestStage: highestStage ?? this.highestStage,
      syncedNotesCount: syncedNotesCount ?? this.syncedNotesCount,
      idToken: idToken ?? this.idToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

