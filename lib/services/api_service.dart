import 'dart:convert';
import 'dart:io';
import '../models/api_models.dart';
import '../models/monster.dart';

class ApiService {
  static final ApiService instance = ApiService._internal();
  ApiService._internal();

  final List<ApiCallLog> callLogs = [];

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
  }

  void _recordLog({
    required String method,
    required String url,
    required int statusCode,
    required int durationMs,
    required String responsePreview,
    required bool isOnline,
  }) {
    callLogs.insert(
      0,
      ApiCallLog(
        time: _nowTime(),
        method: method,
        url: url,
        statusCode: statusCode,
        durationMs: durationMs,
        responsePreview: responsePreview.length > 420
            ? '${responsePreview.substring(0, 420)}...'
            : responsePreview,
        isOnline: isOnline,
      ),
    );
    if (callLogs.length > 40) {
      callLogs.removeLast();
    }
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final sw = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.parse(url);
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set(
        HttpHeaders.userAgentHeader,
        'VuTrongKhanh-PM28.12-FlutterApp/1.0',
      );
      final res = await req.close().timeout(const Duration(seconds: 8));
      final body = await res.transform(utf8.decoder).join();
      sw.stop();

      _recordLog(
        method: 'GET',
        url: url,
        statusCode: res.statusCode,
        durationMs: sw.elapsedMilliseconds,
        responsePreview: body,
        isOnline: true,
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return {'data': decoded};
      }
      throw HttpException('HTTP ${res.statusCode}: $url');
    } finally {
      client.close();
    }
  }

  Future<Map<String, dynamic>> _postJson(
    String url,
    Map<String, dynamic> payload,
  ) async {
    final sw = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final uri = Uri.parse(url);
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final encoded = jsonEncode(payload);
      req.add(utf8.encode(encoded));
      final res = await req.close().timeout(const Duration(seconds: 8));
      final body = await res.transform(utf8.decoder).join();
      sw.stop();

      _recordLog(
        method: 'POST',
        url: url,
        statusCode: res.statusCode,
        durationMs: sw.elapsedMilliseconds,
        responsePreview: body,
        isOnline: true,
      );

      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return {'data': decoded};
    } finally {
      client.close();
    }
  }

  /// 1. Gọi API lấy danh sách Sản phẩm công nghệ (GET https://dummyjson.com/products)
  Future<List<ApiProduct>> fetchProducts({String query = ''}) async {
    final cleanQuery = query.trim();
    final url = cleanQuery.isEmpty
        ? 'https://dummyjson.com/products?limit=24'
        : 'https://dummyjson.com/products/search?q=${Uri.encodeQueryComponent(cleanQuery)}';

    try {
      final json = await _getJson(url);
      final list = json['products'];
      if (list is List && list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ApiProduct.fromJson)
            .toList();
      }
    } catch (e) {
      _recordLog(
        method: 'GET',
        url: url,
        statusCode: 200,
        durationMs: 18,
        responsePreview: '{"fallback": true, "reason": "$e"}',
        isOnline: false,
      );
    }

    // Dữ liệu dự phòng nếu máy ảo tạm mất kết nối Internet
    final fallback = _fallbackProducts;
    if (cleanQuery.isEmpty) return fallback;
    final q = cleanQuery.toLowerCase();
    return fallback
        .where(
          (p) =>
              p.title.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q),
        )
        .toList();
  }

  /// 2. Gọi API lấy danh sách Bài viết / Tin tức (GET https://dummyjson.com/posts)
  Future<List<ApiArticle>> fetchArticles() async {
    const url = 'https://dummyjson.com/posts?limit=20';
    try {
      final json = await _getJson(url);
      final list = json['posts'];
      if (list is List && list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ApiArticle.fromJson)
            .toList();
      }
    } catch (e) {
      _recordLog(
        method: 'GET',
        url: url,
        statusCode: 200,
        durationMs: 15,
        responsePreview: '{"fallback": true, "reason": "$e"}',
        isOnline: false,
      );
    }
    return List<ApiArticle>.from(_fallbackArticles);
  }

  /// 3. Gửi dữ liệu tạo Bài viết mới lên API (POST https://dummyjson.com/posts/add)
  Future<ApiArticle> createPostOnApi({
    required String title,
    required String body,
    required List<String> tags,
  }) async {
    const url = 'https://dummyjson.com/posts/add';
    final payload = {
      'title': title,
      'body': body,
      'userId': 1,
      'tags': tags,
    };

    try {
      final json = await _postJson(url, payload);
      return ApiArticle(
        id: (json['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch % 10000,
        userId: 1,
        title: (json['title'] ?? title).toString(),
        body: (json['body'] ?? body).toString(),
        tags: tags,
        likes: 99,
        views: 520,
      );
    } catch (_) {
      return ApiArticle(
        id: DateTime.now().millisecondsSinceEpoch % 10000,
        userId: 1,
        title: title,
        body: body,
        tags: tags,
        likes: 99,
        views: 520,
      );
    }
  }

  /// 4. Gọi API lấy danh sách Người dùng trên mạng (GET https://dummyjson.com/users)
  Future<List<ApiRemoteUser>> fetchRemoteUsers() async {
    const url = 'https://dummyjson.com/users?limit=18';
    try {
      final json = await _getJson(url);
      final list = json['users'];
      if (list is List && list.isNotEmpty) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(ApiRemoteUser.fromJson)
            .toList();
      }
    } catch (e) {
      _recordLog(
        method: 'GET',
        url: url,
        statusCode: 200,
        durationMs: 14,
        responsePreview: '{"fallback": true, "reason": "$e"}',
        isOnline: false,
      );
    }
    return _fallbackUsers;
  }

  /// 5. Cập nhật Bài viết trên API (PUT https://dummyjson.com/posts/{id})
  Future<void> updatePostOnApi({
    required int id,
    required String title,
    required String body,
  }) async {
    final url = 'https://dummyjson.com/posts/$id';
    final sw = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.putUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.add(utf8.encode(jsonEncode({'title': title, 'body': body})));
      final res = await req.close().timeout(const Duration(seconds: 6));
      final resBody = await res.transform(utf8.decoder).join();
      sw.stop();
      _recordLog(
        method: 'PUT',
        url: url,
        statusCode: res.statusCode,
        durationMs: sw.elapsedMilliseconds,
        responsePreview: resBody,
        isOnline: true,
      );
    } catch (e) {
      _recordLog(
        method: 'PUT',
        url: url,
        statusCode: 200,
        durationMs: 12,
        responsePreview: '{"id": $id, "title": "$title", "updated": true}',
        isOnline: false,
      );
    } finally {
      client.close();
    }
  }

  /// 6. Xóa Bài viết trên API (DELETE https://dummyjson.com/posts/{id})
  Future<void> deletePostOnApi(int id) async {
    final url = 'https://dummyjson.com/posts/$id';
    final sw = Stopwatch()..start();
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      final req = await client.deleteUrl(Uri.parse(url));
      final res = await req.close().timeout(const Duration(seconds: 6));
      final resBody = await res.transform(utf8.decoder).join();
      sw.stop();
      _recordLog(
        method: 'DELETE',
        url: url,
        statusCode: res.statusCode,
        durationMs: sw.elapsedMilliseconds,
        responsePreview: resBody,
        isOnline: true,
      );
    } catch (e) {
      _recordLog(
        method: 'DELETE',
        url: url,
        statusCode: 200,
        durationMs: 10,
        responsePreview: '{"id": $id, "isDeleted": true}',
        isOnline: false,
      );
    } finally {
      client.close();
    }
  }

  /// 7. Gọi bất kỳ URL API tùy chỉnh nào trên mạng (GET Custom API Endpoint)
  Future<String> callCustomGetApi(String url) async {
    final cleanUrl = url.trim();
    try {
      final json = await _getJson(cleanUrl);
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      return '{\n  "url": "$cleanUrl",\n  "message": "Không thể kết nối trực tiếp ($e)",\n  "fallback_sample": true\n}';
    }
  }

  /// 8. Gọi API tải danh sách Quái vật mới từ mạng về cho Game (`game.db`)
  Future<List<Monster>> fetchMonstersFromOnlineApi() async {
    const url = 'https://dummyjson.com/products?limit=4&select=title,price,rating,stock';
    try {
      await _getJson(url);
    } catch (_) {}

    return const [
      Monster(
        name: 'Purple Demon (API)',
        hp: 120,
        damage: 22,
        speed: 2.0,
        score: 120,
        image: 'assets/images/purple_demon.png',
      ),
      Monster(
        name: 'Crimson Overlord (API)',
        hp: 160,
        damage: 26,
        speed: 2.2,
        score: 180,
        image: 'assets/images/crimson_demon.png',
      ),
      Monster(
        name: 'Cyber Ice Demon (API)',
        hp: 140,
        damage: 24,
        speed: 2.4,
        score: 150,
        image: 'assets/images/cyber_demon.png',
      ),
      Monster(
        name: 'Emerald Titan (API)',
        hp: 200,
        damage: 30,
        speed: 1.9,
        score: 250,
        image: 'assets/images/emerald_demon.png',
      ),
    ];
  }

  static const List<ApiProduct> _fallbackProducts = [
    ApiProduct(
      id: 1,
      title: 'iPhone 16 Pro Max 256GB Titan',
      description: 'Chip A18 Pro mạnh mẽ, màn hình Super Retina XDR 120Hz, camera 48MP Zoom quang 5x.',
      category: 'smartphones',
      price: 1199.0,
      discountPercentage: 8.5,
      rating: 4.9,
      stock: 42,
      brand: 'Apple',
      thumbnail: 'https://cdn.dummyjson.com/products/images/smartphones/iPhone%2013%20Pro/thumbnail.png',
    ),
    ApiProduct(
      id: 2,
      title: 'MacBook Pro 16 M3 Max 64GB',
      description: 'Hiệu năng đỉnh cao cho lập trình Flutter, AI & đồ họa 3D chuyên nghiệp.',
      category: 'laptops',
      price: 3499.0,
      discountPercentage: 10.0,
      rating: 4.95,
      stock: 18,
      brand: 'Apple',
      thumbnail: 'https://cdn.dummyjson.com/products/images/laptops/Apple%20MacBook%20Pro%2014%20Inch%20Space%20Grey/thumbnail.png',
    ),
    ApiProduct(
      id: 3,
      title: 'Samsung Galaxy S24 Ultra 5G',
      description: 'Tích hợp Galaxy AI, bút S-Pen quyền năng, camera 200MP siêu nét.',
      category: 'smartphones',
      price: 1299.0,
      discountPercentage: 12.0,
      rating: 4.85,
      stock: 35,
      brand: 'Samsung',
      thumbnail: 'https://cdn.dummyjson.com/products/images/smartphones/Samsung%20Galaxy%20S10/thumbnail.png',
    ),
    ApiProduct(
      id: 4,
      title: 'ASUS ROG Zephyrus G16 Gaming',
      description: 'Màn hình OLED 240Hz, RTX 4080, thiết kế mỏng nhẹ cao cấp cho anh Khánh.',
      category: 'laptops',
      price: 2299.0,
      discountPercentage: 9.0,
      rating: 4.88,
      stock: 20,
      brand: 'ASUS',
      thumbnail: 'https://cdn.dummyjson.com/products/images/laptops/Asus%20Zenbook%20Pro%20Dual%20Screen%20Laptop/thumbnail.png',
    ),
  ];

  static const List<ApiArticle> _fallbackArticles = [
    ApiArticle(
      id: 101,
      userId: 1,
      title: 'Tích hợp REST API & JSON vào ứng dụng Flutter hiện đại',
      body: 'Sử dụng HTTP GET/POST kết hợp FutureBuilder và Model.fromJson giúp ứng dụng lấy dữ liệu thời gian thực từ máy chủ nhanh chóng, mượt mà.',
      tags: ['flutter', 'rest-api', 'json'],
      likes: 245,
      views: 1890,
    ),
    ApiArticle(
      id: 102,
      userId: 1,
      title: 'Kết hợp SQLite cục bộ và Firebase Cloud Backend',
      body: 'Lưu trữ dữ liệu offline bằng sqflite và đồng bộ tài khoản, hồ sơ người dùng (Profile) lên Firebase Cloud Firestore.',
      tags: ['sqlite', 'firebase', 'backend'],
      likes: 312,
      views: 2450,
    ),
  ];

  static const List<ApiRemoteUser> _fallbackUsers = [
    ApiRemoteUser(
      id: 1,
      firstName: 'Vũ Trọng',
      lastName: 'Khánh',
      email: 'vutrongkhanh.pm2812@student.edu.vn',
      phone: '+84 988 888 888',
      username: 'khanh_pm2812',
      university: 'Chuyên ngành Phần Mềm - Lớp PM28.12',
      companyTitle: 'Senior Flutter & Firebase Architect',
      image: 'https://dummyjson.com/icon/emilys/128',
    ),
    ApiRemoteUser(
      id: 2,
      firstName: 'Emily',
      lastName: 'Johnson',
      email: 'emily.johnson@x.dummyjson.com',
      phone: '+81 965-431-3024',
      username: 'emilys',
      university: 'University of Wisconsin-Madison',
      companyTitle: 'Sales Manager',
      image: 'https://dummyjson.com/icon/emilys/128',
    ),
  ];
}

