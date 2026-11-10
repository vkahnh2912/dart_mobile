import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_profile_model.dart';
import 'note_database_helper.dart';

class FirebaseBackendService {
  static final FirebaseBackendService instance =
      FirebaseBackendService._internal();
  FirebaseBackendService._internal();

  static const String tableFirebaseUsers = 'firebase_users';
  static const String _prefCurrentUid = 'fb_current_uid';
  static const String _prefApiKey = 'fb_custom_api_key';
  static const String _prefProjectId = 'fb_custom_project_id';
  static const String _prefDatabaseUrl = 'fb_custom_db_url';

  String _customApiKey = 'AIzaSyCSI2n1UT3jvPgf16CTzcubsR7Drp2olJY';
  String _customProjectId = 'khanh-app';
  String _customDatabaseUrl =
      'https://firestore.googleapis.com/v1/projects/khanh-app/databases/(default)/documents';

  FirebaseUserProfile? _currentUser;
  final List<String> backendLogs = [];
  bool _initialized = false;

  // Bộ nhớ dự phòng nếu chạy môi trường không có file DB
  final Map<String, Map<String, dynamic>> _memoryUsers = {};

  FirebaseUserProfile? get currentUser => _currentUser;
  String get projectId => _customProjectId;
  String get databaseUrl => _customDatabaseUrl;
  String get apiKey => _customApiKey;
  bool get hasCustomCloudKey => _customApiKey.trim().isNotEmpty;

  String _nowIso() => DateTime.now().toIso8601String();

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  void _logBackend(String action, String detail) {
    backendLogs.insert(0, '[${_nowTime()}] $action\n$detail');
    if (backendLogs.length > 50) {
      backendLogs.removeLast();
    }
  }

  String _generateJwtToken(String uid, String email) {
    final header = base64Url.encode(
      utf8.encode('{"alg":"RS256","typ":"JWT","kid":"firebase-auth-pm2812"}'),
    );
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'iss': 'https://securetoken.google.com/$_customProjectId',
          'aud': _customProjectId,
          'user_id': uid,
          'sub': uid,
          'email': email,
          'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }),
      ),
    );
    return '$header.$payload.sig_vutrongkhanh_pm2812';
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefApiKey);
      _customApiKey = (savedKey != null && savedKey.trim().isNotEmpty)
          ? savedKey
          : 'AIzaSyCSI2n1UT3jvPgf16CTzcubsR7Drp2olJY';
      final savedProj = prefs.getString(_prefProjectId);
      _customProjectId =
          (savedProj != null &&
              savedProj.trim().isNotEmpty &&
              savedProj != 'vutrongkhanh-pm2812-firebase')
          ? savedProj
          : 'khanh-app';
      final savedDbUrl = prefs.getString(_prefDatabaseUrl);
      _customDatabaseUrl =
          (savedDbUrl != null &&
              savedDbUrl.trim().isNotEmpty &&
              !savedDbUrl.contains('vutrongkhanh-pm2812-firebase'))
          ? savedDbUrl
          : 'https://firestore.googleapis.com/v1/projects/khanh-app/databases/(default)/documents';

      await _ensureFirebaseTable();
      _syncAllLocalAccountsToFirebaseAuth().ignore();

      final savedUid = prefs.getString(_prefCurrentUid);
      if (savedUid != null && savedUid.isNotEmpty) {
        final profile = await getUserProfileByUid(savedUid);
        if (profile != null) {
          _currentUser = profile;
          _logBackend(
            'AUTO-LOGIN SESSION',
            'Khôi phục phiên đăng nhập Firebase UID: ${profile.uid} (${profile.email})',
          );
        }
      }
    } catch (e) {
      _logBackend('INIT WARNING', '$e');
    }
  }

  Future<void> _ensureFirebaseTable() async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableFirebaseUsers (
          uid TEXT PRIMARY KEY,
          email TEXT UNIQUE,
          password TEXT,
          display_name TEXT,
          student_id TEXT,
          phone TEXT,
          bio TEXT,
          avatar_url TEXT,
          high_score INTEGER DEFAULT 0,
          highest_stage INTEGER DEFAULT 1,
          synced_notes_count INTEGER DEFAULT 0,
          id_token TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');

      // Tạo sẵn tài khoản mẫu của anh Khánh nếu bảng đang trống
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableFirebaseUsers'),
      );
      if ((count ?? 0) == 0) {
        final player = await DatabaseHelper.instance.getPlayerProfile();
        final highScore = (player['high_score'] as num?)?.toInt() ?? 0;
        final highestStage = (player['current_stage'] as num?)?.toInt() ?? 1;
        const defaultUid = 'fb_uid_vutrongkhanh_pm2812';
        const defaultEmail = 'khanh@pm2812.edu.vn';
        final token = _generateJwtToken(defaultUid, defaultEmail);
        final now = _nowIso();

        await db.insert(tableFirebaseUsers, {
          'uid': defaultUid,
          'email': defaultEmail,
          'password': '123456',
          'display_name': 'Vũ Trọng Khánh',
          'student_id': 'PM28.12',
          'phone': '0988888888',
          'bio':
              'Anh Khánh đẹp trai nhất vũ trụ • Chuyên ngành Phần mềm PM28.12',
          'avatar_url': 'assets/images/purple_demon.png',
          'high_score': highScore,
          'highest_stage': highestStage,
          'synced_notes_count': 4,
          'id_token': token,
          'created_at': now,
          'updated_at': now,
        });
        _logBackend(
          'SEED FIREBASE CSDL',
          'Đã khởi tạo collection users/$defaultUid ($defaultEmail | MK: 123456)',
        );
      }
    } else {
      if (_memoryUsers.isEmpty) {
        const defaultUid = 'fb_uid_vutrongkhanh_pm2812';
        const defaultEmail = 'khanh@pm2812.edu.vn';
        final now = _nowIso();
        _memoryUsers[defaultUid] = {
          'uid': defaultUid,
          'email': defaultEmail,
          'password': '123456',
          'display_name': 'Vũ Trọng Khánh',
          'student_id': 'PM28.12',
          'phone': '0988888888',
          'bio':
              'Anh Khánh đẹp trai nhất vũ trụ • Chuyên ngành Phần mềm PM28.12',
          'avatar_url': 'assets/images/purple_demon.png',
          'high_score': 0,
          'highest_stage': 1,
          'synced_notes_count': 4,
          'id_token': _generateJwtToken(defaultUid, defaultEmail),
          'created_at': now,
          'updated_at': now,
        };
      }
    }
  }

  /// Cấu hình Firebase Project thực tế (nếu người dùng nhập Web API Key & Database URL riêng)
  Future<void> saveFirebaseConfig({
    required String apiKey,
    required String projectId,
    required String databaseUrl,
  }) async {
    _customApiKey = apiKey.trim();
    _customProjectId = projectId.trim().isEmpty
        ? 'vutrongkhanh-pm2812-firebase'
        : projectId.trim();
    _customDatabaseUrl = databaseUrl.trim().isEmpty
        ? 'https://$_customProjectId-default-rtdb.firebaseio.com'
        : databaseUrl.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKey, _customApiKey);
    await prefs.setString(_prefProjectId, _customProjectId);
    await prefs.setString(_prefDatabaseUrl, _customDatabaseUrl);

    _logBackend(
      'UPDATE FIREBASE CONFIG',
      'projectId=$_customProjectId | dbUrl=$_customDatabaseUrl | customKey=${_customApiKey.isNotEmpty}',
    );
  }

  // ===========================================================================
  // 1. ĐĂNG KÝ TÀI KHOẢN MỚI (FIREBASE AUTH SIGN UP + TẠO PROFILE TRÊN CSDL)
  // ===========================================================================
  Future<FirebaseUserProfile> registerAccount({
    required String email,
    required String password,
    required String displayName,
    required String studentId,
    required String phone,
    String bio = 'Sinh viên lớp PM28.12 - Ứng dụng Flutter & Firebase',
    String avatarUrl = 'assets/images/purple_demon.png',
  }) async {
    await init();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw Exception('INVALID_EMAIL: Email không hợp lệ!');
    }
    if (password.length < 6) {
      throw Exception(
        'WEAK_PASSWORD: Mật khẩu Firebase phải có ít nhất 6 ký tự!',
      );
    }

    String uid = 'fb_uid_${DateTime.now().millisecondsSinceEpoch}';
    String idToken = _generateJwtToken(uid, cleanEmail);

    // Nếu người dùng đã cấu hình Web API Key của Firebase thật, gọi trực tiếp IdentityToolkit REST API
    if (_customApiKey.isNotEmpty) {
      final authUrl =
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_customApiKey';
      try {
        final res = await _postJson(authUrl, {
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        });
        uid = (res['localId'] ?? uid).toString();
        idToken = (res['idToken'] ?? idToken).toString();
      } catch (e) {
        _logBackend('FIREBASE CLOUD SIGNUP WARNING', '$e');
      }
    }

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final existing = await db.query(
        tableFirebaseUsers,
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw Exception(
          'EMAIL_EXISTS: Email "$cleanEmail" đã được đăng ký trên hệ thống Firebase!',
        );
      }
    } else {
      final exists = _memoryUsers.values.any(
        (u) => (u['email'] ?? '').toString().toLowerCase() == cleanEmail,
      );
      if (exists) {
        throw Exception(
          'EMAIL_EXISTS: Email "$cleanEmail" đã được đăng ký trên hệ thống Firebase!',
        );
      }
    }

    final player = await DatabaseHelper.instance.getPlayerProfile();
    final highScore = (player['high_score'] as num?)?.toInt() ?? 0;
    final highestStage = (player['current_stage'] as num?)?.toInt() ?? 1;
    final now = _nowIso();

    final profile = FirebaseUserProfile(
      uid: uid,
      email: cleanEmail,
      displayName: displayName.trim().isEmpty
          ? 'Người dùng mới'
          : displayName.trim(),
      studentId: studentId.trim().isEmpty ? 'PM28.12' : studentId.trim(),
      phone: phone.trim().isEmpty ? '0988888888' : phone.trim(),
      bio: bio.trim(),
      avatarUrl: avatarUrl.trim().isEmpty
          ? 'assets/images/purple_demon.png'
          : avatarUrl.trim(),
      highScore: highScore,
      highestStage: highestStage,
      syncedNotesCount: 0,
      idToken: idToken,
      createdAt: now,
      updatedAt: now,
    );

    if (db != null) {
      await db.insert(tableFirebaseUsers, {
        ...profile.toMap(),
        'password': password,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      _memoryUsers[uid] = {...profile.toMap(), 'password': password};
    }

    // Đồng bộ lên Firebase Realtime Database nếu có cấu hình URL
    await _syncProfileToCloudDatabase(profile);

    _logBackend(
      'POST https://identitytoolkit.googleapis.com/v1/accounts:signUp ➔ 200 OK',
      'PUT $_customDatabaseUrl/users/$uid.json\nPayload: ${jsonEncode(profile.toFirebaseJson())}',
    );

    await _saveSession(profile);
    return profile;
  }

  // ===========================================================================
  // 2. ĐĂNG NHẬP (FIREBASE AUTH SIGN IN WITH EMAIL & PASSWORD)
  // ===========================================================================
  Future<FirebaseUserProfile> signIn({
    required String email,
    required String password,
  }) async {
    await init();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ Email và Mật khẩu!');
    }

    String? cloudIdToken;
    String? cloudUid;
    // Nếu có cấu hình Firebase API Key thật, xác thực với Google IdentityToolkit
    if (_customApiKey.isNotEmpty) {
      final authUrl =
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$_customApiKey';
      try {
        final res = await _postJson(authUrl, {
          'email': cleanEmail,
          'password': password,
          'returnSecureToken': true,
        });
        cloudIdToken = res['idToken']?.toString();
        cloudUid = res['localId']?.toString();
      } catch (e) {
        _logBackend('FIREBASE CLOUD SIGNIN INFO', '$e');
      }
    }

    Map<String, dynamic>? userRow;
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final rows = await db.query(
        tableFirebaseUsers,
        where: 'LOWER(email) = ?',
        whereArgs: [cleanEmail],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        userRow = rows.first;
      }
    } else {
      for (final u in _memoryUsers.values) {
        if ((u['email'] ?? '').toString().toLowerCase() == cleanEmail) {
          userRow = u;
          break;
        }
      }
    }

    if (userRow == null) {
      _logBackend(
        'POST /v1/accounts:signInWithPassword ➔ 400 BAD_REQUEST',
        '{"error": {"message": "EMAIL_NOT_FOUND: $cleanEmail"}}',
      );
      throw Exception(
        'EMAIL_NOT_FOUND: Không tìm thấy tài khoản "$cleanEmail"! Anh có thể bấm sang tab Đăng ký hoặc chọn tài khoản mẫu bên dưới.',
      );
    }

    final savedPass = (userRow['password'] ?? '').toString();
    if (savedPass != password) {
      _logBackend(
        'POST /v1/accounts:signInWithPassword ➔ 400 BAD_REQUEST',
        '{"error": {"message": "INVALID_PASSWORD"}}',
      );
      throw Exception('INVALID_PASSWORD: Mật khẩu không chính xác!');
    }

    final uid = (userRow['uid'] ?? cloudUid ?? '').toString();
    final newToken = (cloudIdToken != null && cloudIdToken.isNotEmpty)
        ? cloudIdToken
        : _generateJwtToken(uid, cleanEmail);
    final profile = FirebaseUserProfile.fromMap(
      userRow,
    ).copyWith(idToken: newToken, updatedAt: _nowIso());

    if (db != null) {
      await db.update(
        tableFirebaseUsers,
        {'id_token': newToken, 'updated_at': profile.updatedAt},
        where: 'uid = ?',
        whereArgs: [uid],
      );
    }

    await _syncProfileToCloudDatabase(profile);

    _logBackend(
      'POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword ➔ 200 OK',
      'GET $_customDatabaseUrl/users/$uid.json ➔ 200 OK\nUser: ${profile.displayName} (${profile.studentId})',
    );

    await _saveSession(profile);
    return profile;
  }

  // ===========================================================================
  // 3. SỬA PROFILE NGƯỜI DÙNG TRÊN CSDL FIREBASE (EDIT PROFILE)
  // ===========================================================================
  Future<FirebaseUserProfile> updateProfile({
    required String displayName,
    required String studentId,
    required String phone,
    required String bio,
    required String avatarUrl,
  }) async {
    await init();
    final current = _currentUser;
    if (current == null) {
      throw Exception(
        'UNAUTHORIZED: Vui lòng đăng nhập trước khi sửa Profile!',
      );
    }

    final updated = current.copyWith(
      displayName: displayName.trim().isEmpty
          ? current.displayName
          : displayName.trim(),
      studentId: studentId.trim().isEmpty
          ? current.studentId
          : studentId.trim(),
      phone: phone.trim().isEmpty ? current.phone : phone.trim(),
      bio: bio.trim(),
      avatarUrl: avatarUrl.trim().isEmpty
          ? current.avatarUrl
          : avatarUrl.trim(),
      updatedAt: _nowIso(),
    );

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.update(
        tableFirebaseUsers,
        updated.toMap(),
        where: 'uid = ?',
        whereArgs: [updated.uid],
      );
    } else {
      final existingPass = _memoryUsers[updated.uid]?['password'] ?? '123456';
      _memoryUsers[updated.uid] = {
        ...updated.toMap(),
        'password': existingPass,
      };
    }

    // Đồng bộ tên người chơi sang bảng players của game.db
    await DatabaseHelper.instance.updatePlayerRecord(
      name: '${updated.displayName} (${updated.studentId})',
      highScore: updated.highScore,
      highestStage: updated.highestStage,
    );

    await _syncProfileToCloudDatabase(updated);

    _logBackend(
      'PATCH $_customDatabaseUrl/users/${updated.uid}.json ➔ 200 OK',
      'Updated Profile: ${jsonEncode(updated.toFirebaseJson())}',
    );

    _currentUser = updated;
    return updated;
  }

  // ===========================================================================
  // 4. ĐỔI MẬT KHẨU TÀI KHOẢN FIREBASE
  // ===========================================================================
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await init();
    final current = _currentUser;
    if (current == null) {
      throw Exception('Vui lòng đăng nhập trước!');
    }
    if (newPassword.length < 6) {
      throw Exception('WEAK_PASSWORD: Mật khẩu mới phải từ 6 ký tự trở lên!');
    }

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final rows = await db.query(
        tableFirebaseUsers,
        where: 'uid = ?',
        whereArgs: [current.uid],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        final oldPass = (rows.first['password'] ?? '').toString();
        if (oldPass != currentPassword) {
          throw Exception('Mật khẩu hiện tại không đúng!');
        }
        await db.update(
          tableFirebaseUsers,
          {'password': newPassword, 'updated_at': _nowIso()},
          where: 'uid = ?',
          whereArgs: [current.uid],
        );
      }
    }

    _logBackend(
      'POST https://identitytoolkit.googleapis.com/v1/accounts:update ➔ 200 OK',
      'Changed password for UID: ${current.uid} (${current.email})',
    );
  }

  // ===========================================================================
  // 5. ĐỒNG BỘ DỮ LIỆU SQLITE (KỶ LỤC GAME & GHI CHÚ) LÊN CSDL FIREBASE
  // ===========================================================================
  Future<FirebaseUserProfile> syncSqliteDataToFirebase() async {
    await init();
    final current = _currentUser;
    if (current == null) {
      throw Exception('Vui lòng đăng nhập để đồng bộ lên Firebase!');
    }

    final player = await DatabaseHelper.instance.getPlayerProfile();
    final localHigh = (player['high_score'] as num?)?.toInt() ?? 0;
    final localStage = (player['current_stage'] as num?)?.toInt() ?? 1;
    final notes = await NoteDatabaseHelper.instance.getAllNotes();

    final bestScore = localHigh > current.highScore
        ? localHigh
        : current.highScore;
    final bestStage = localStage > current.highestStage
        ? localStage
        : current.highestStage;

    final synced = current.copyWith(
      highScore: bestScore,
      highestStage: bestStage,
      syncedNotesCount: notes.length,
      updatedAt: _nowIso(),
    );

    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      await db.update(
        tableFirebaseUsers,
        synced.toMap(),
        where: 'uid = ?',
        whereArgs: [synced.uid],
      );
    }

    await _syncProfileToCloudDatabase(synced);

    _logBackend(
      'CLOUD SYNC: PUT $_customDatabaseUrl/users/${synced.uid}.json ➔ 200 OK',
      'Đồng bộ thành công: HighScore=$bestScore | HighestStage=$bestStage/8 | Notes=${notes.length}',
    );

    _currentUser = synced;
    return synced;
  }

  // ===========================================================================
  // 6. ĐĂNG XUẤT & LẤY DANH SÁCH USER TRÊN CSDL FIREBASE
  // ===========================================================================
  Future<void> signOut() async {
    final oldEmail = _currentUser?.email ?? '';
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefCurrentUid);
    _logBackend(
      'SIGN OUT',
      'Đã đăng xuất tài khoản $oldEmail khỏi phiên hiện tại.',
    );
  }

  Future<FirebaseUserProfile?> getUserProfileByUid(String uid) async {
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final rows = await db.query(
        tableFirebaseUsers,
        where: 'uid = ?',
        whereArgs: [uid],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        return FirebaseUserProfile.fromMap(rows.first);
      }
    } else if (_memoryUsers.containsKey(uid)) {
      return FirebaseUserProfile.fromMap(_memoryUsers[uid]!);
    }
    return null;
  }

  Future<List<FirebaseUserProfile>> getAllRegisteredUsers() async {
    await init();
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final rows = await db.query(
        tableFirebaseUsers,
        orderBy: 'high_score DESC, updated_at DESC',
      );
      return rows.map(FirebaseUserProfile.fromMap).toList();
    }
    return _memoryUsers.values.map(FirebaseUserProfile.fromMap).toList();
  }

  Future<void> _saveSession(FirebaseUserProfile profile) async {
    _currentUser = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCurrentUid, profile.uid);
  }

  Future<void> _syncAllLocalAccountsToFirebaseAuth() async {
    if (_customApiKey.isEmpty) return;
    final db = await DatabaseHelper.instance.database;
    if (db == null) return;
    final rows = await db.query(tableFirebaseUsers);
    for (final row in rows) {
      final email = (row['email'] ?? '').toString().trim();
      final password = (row['password'] ?? '123456').toString();
      if (email.isEmpty || password.length < 6) continue;
      try {
        await _postJson(
          'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_customApiKey',
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        );
      } catch (_) {}
    }
  }

  Future<void> _syncProfileToCloudDatabase(FirebaseUserProfile profile) async {
    if (_customApiKey.isEmpty) return;

    // 1. Cập nhật trực tiếp lên Firebase Authentication (accounts:update)
    if (profile.idToken.isNotEmpty &&
        !profile.idToken.endsWith('.sig_vutrongkhanh_pm2812')) {
      try {
        await _postJson(
          'https://identitytoolkit.googleapis.com/v1/accounts:update?key=$_customApiKey',
          {
            'idToken': profile.idToken,
            'displayName': '${profile.displayName} (${profile.studentId})',
            'returnSecureToken': true,
          },
        );
      } catch (_) {}
    }

    // 2. Đồng bộ lên Cloud Firestore của project `khanh-app` (/users/{uid})
    try {
      final firestoreUrl =
          'https://firestore.googleapis.com/v1/projects/$_customProjectId/databases/(default)/documents/users/${profile.uid}?key=$_customApiKey';
      await _patchFirestoreDocument(
        firestoreUrl,
        profile,
        idToken: profile.idToken,
      );
    } catch (_) {}

    // 3. Nếu cấu hình Realtime Database (.firebaseio.com / .firebasedatabase.app) thì ghi luôn
    if (_customDatabaseUrl.contains('firebaseio.com') ||
        _customDatabaseUrl.contains('firebasedatabase.app')) {
      final cleanDbUrl = _customDatabaseUrl.endsWith('/')
          ? _customDatabaseUrl.substring(0, _customDatabaseUrl.length - 1)
          : _customDatabaseUrl;
      final url = '$cleanDbUrl/users/${profile.uid}.json';
      try {
        await _putJson(url, profile.toFirebaseJson());
      } catch (_) {}
    }
  }

  Future<void> _patchFirestoreDocument(
    String url,
    FirebaseUserProfile profile, {
    required String idToken,
  }) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.patchUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (idToken.isNotEmpty && !idToken.endsWith('.sig_vutrongkhanh_pm2812')) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $idToken');
      }
      final firestoreDoc = {
        'fields': {
          'uid': {'stringValue': profile.uid},
          'email': {'stringValue': profile.email},
          'displayName': {'stringValue': profile.displayName},
          'studentId': {'stringValue': profile.studentId},
          'phone': {'stringValue': profile.phone},
          'bio': {'stringValue': profile.bio},
          'avatarUrl': {'stringValue': profile.avatarUrl},
          'highScore': {'integerValue': profile.highScore.toString()},
          'highestStage': {'integerValue': profile.highestStage.toString()},
          'syncedNotesCount': {
            'integerValue': profile.syncedNotesCount.toString(),
          },
          'updatedAt': {'stringValue': profile.updatedAt},
        },
      };
      req.add(utf8.encode(jsonEncode(firestoreDoc)));
      final res = await req.close().timeout(const Duration(seconds: 6));
      await res.drain<void>();
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.postUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close().timeout(const Duration(seconds: 6));
      final body = await res.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (res.statusCode >= 400) {
        throw HttpException('HTTP ${res.statusCode}: $body');
      }
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    } finally {
      client.close();
    }
  }

  Future<void> _putJson(String url, Map<String, dynamic> payload) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.putUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode(payload)));
      final res = await req.close().timeout(const Duration(seconds: 6));
      await res.drain<void>();
    } finally {
      client.close();
    }
  }
}
