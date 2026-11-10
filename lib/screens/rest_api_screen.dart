import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../models/monster.dart';
import '../models/note_model.dart';
import '../repositories/monster_repository.dart';
import '../services/api_service.dart';
import '../services/note_database_helper.dart';

class RestApiScreen extends StatefulWidget {
  const RestApiScreen({super.key});

  @override
  State<RestApiScreen> createState() => _RestApiScreenState();
}

class _RestApiScreenState extends State<RestApiScreen> {
  final ApiService _apiService = ApiService.instance;
  final MonsterRepository _monsterRepository = MonsterRepository();
  final TextEditingController _searchCtrl = TextEditingController();

  int _selectedEndpoint = 0; // 0: Products, 1: Posts, 2: Users, 3: Monsters API
  bool _isLoading = true;
  bool _showJsonConsole = false;

  List<ApiProduct> _products = [];
  List<ApiArticle> _articles = [];
  List<ApiRemoteUser> _users = [];
  List<Monster> _apiMonsters = [];

  @override
  void initState() {
    super.initState();
    _fetchAllApiData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAllApiData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _apiService.fetchProducts(query: _searchCtrl.text),
      _apiService.fetchArticles(),
      _apiService.fetchRemoteUsers(),
      _apiService.fetchMonstersFromOnlineApi(),
    ]);
    if (!mounted) return;
    setState(() {
      _products = results[0] as List<ApiProduct>;
      _articles = results[1] as List<ApiArticle>;
      _users = results[2] as List<ApiRemoteUser>;
      _apiMonsters = results[3] as List<Monster>;
      _isLoading = false;
    });
  }

  Future<void> _searchProductsOnApi() async {
    setState(() => _isLoading = true);
    final products = await _apiService.fetchProducts(query: _searchCtrl.text);
    if (!mounted) return;
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _saveApiItemToSqlite({
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final createdAt =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    await NoteDatabaseHelper.instance.insertNote(
      NoteItem(
        title: '[API] $title',
        content: content,
        category: 'Dự án Flutter',
        priority: 3,
        isCompleted: false,
        createdAt: createdAt,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã lưu "$title" từ REST API vào SQLite!'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _importMonsterToGameDb(Monster monster) async {
    await _monsterRepository.addMonster(monster);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '👾 Đã nạp quái "${monster.name}" từ API vào SQLite (game.db)!',
        ),
        backgroundColor: const Color(0xFF9333EA),
      ),
    );
  }

  Future<void> _importAllMonstersToGameDb() async {
    for (final m in _apiMonsters) {
      await _monsterRepository.addMonster(m);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🚀 Đã nạp toàn bộ ${_apiMonsters.length} Quái vật từ API vào SQLite game.db!',
        ),
        backgroundColor: const Color(0xFF9333EA),
      ),
    );
  }

  Future<void> _showCustomUrlTesterDialog() async {
    final urlCtrl = TextEditingController(
      text: 'https://dummyjson.com/products/1',
    );
    String jsonResult =
        '// Chọn hoặc nhập URL API bất kỳ rồi bấm "GỌI GET API" để xem dữ liệu JSON thực tế trả về...';
    bool calling = false;

    const sampleUrls = [
      ('Sản phẩm #1', 'https://dummyjson.com/products/1'),
      ('Danh ngôn ngẫu nhiên', 'https://dummyjson.com/quotes/random'),
      ('Bài viết #1', 'https://dummyjson.com/posts/1'),
      ('JSONPlaceholder', 'https://jsonplaceholder.typicode.com/todos/1'),
    ];

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.http_rounded, color: Color(0xFF2563EB)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Test Gọi REST API Trực Tuyến',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chọn nhanh Endpoint mẫu hoặc tự nhập URL:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: sampleUrls.map((item) {
                          return ActionChip(
                            label: Text(
                              item.$1,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              setDialogState(() {
                                urlCtrl.text = item.$2;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Endpoint URL (HTTP GET)',
                          prefixIcon: Icon(Icons.link_rounded),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: calling
                              ? null
                              : () async {
                                  setDialogState(() => calling = true);
                                  final res = await _apiService.callCustomGetApi(
                                    urlCtrl.text,
                                  );
                                  setDialogState(() {
                                    jsonResult = res;
                                    calling = false;
                                  });
                                  if (mounted) setState(() {});
                                },
                          icon: calling
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            calling
                                ? 'ĐANG GỌI API TRÊN MẠNG...'
                                : 'GỌI GET API & XEM JSON',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 210,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            jsonResult,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11.5,
                              color: Color(0xFFA7F3D0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ĐÓNG'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showCreatePostDialog() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    final tagsCtrl = TextEditingController(text: 'flutter, rest-api, pm28.12');

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            '📤 Gửi POST Request tạo Bài viết lên API',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề bài viết (title)',
                    hintText: 'VD: Báo cáo REST API - Vũ Trọng Khánh',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung (body)',
                    hintText:
                        'Nhập nội dung gửi lên POST https://dummyjson.com/posts/add',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: tagsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Thẻ (tags cách nhau dấu phẩy)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('HỦY'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final title = titleCtrl.text.trim().isEmpty
                    ? 'Bài viết mới từ App Vũ Trọng Khánh PM28.12'
                    : titleCtrl.text.trim();
                final body = bodyCtrl.text.trim().isEmpty
                    ? 'Gửi dữ liệu thành công qua phương thức HTTP POST lên REST API.'
                    : bodyCtrl.text.trim();
                final tags = tagsCtrl.text
                    .split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList();

                if (ctx.mounted) Navigator.pop(ctx);
                setState(() => _isLoading = true);
                final created = await _apiService.createPostOnApi(
                  title: title,
                  body: body,
                  tags: tags.isEmpty ? ['flutter', 'api'] : tags,
                );
                if (!mounted) return;
                setState(() {
                  _articles.insert(0, created);
                  _selectedEndpoint = 1;
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      '🚀 Đã gửi POST https://dummyjson.com/posts/add thành công!',
                    ),
                    backgroundColor: Color(0xFF2563EB),
                  ),
                );
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('GỬI POST API'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditPostDialog(int index, ApiArticle article) async {
    final titleCtrl = TextEditingController(text: article.title);
    final bodyCtrl = TextEditingController(text: article.body);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            '✏️ PUT Cập nhật Bài viết #${article.id}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề bài viết (title)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung (body)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('HỦY'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final newTitle = titleCtrl.text.trim().isEmpty
                    ? article.title
                    : titleCtrl.text.trim();
                final newBody = bodyCtrl.text.trim().isEmpty
                    ? article.body
                    : bodyCtrl.text.trim();
                if (ctx.mounted) Navigator.pop(ctx);
                await _apiService.updatePostOnApi(
                  id: article.id,
                  title: newTitle,
                  body: newBody,
                );
                if (!mounted) return;
                setState(() {
                  _articles[index] = ApiArticle(
                    id: article.id,
                    userId: article.userId,
                    title: newTitle,
                    body: newBody,
                    tags: article.tags,
                    likes: article.likes + 1,
                    views: article.views + 5,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ Đã gửi PUT https://dummyjson.com/posts/${article.id} thành công!',
                    ),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('GỬI PUT API'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePostFromApi(int index, ApiArticle article) async {
    await _apiService.deletePostOnApi(article.id);
    if (!mounted) return;
    setState(() {
      _articles.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🗑️ Đã gửi DELETE https://dummyjson.com/posts/${article.id} thành công!',
        ),
        backgroundColor: const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final latestLog = _apiService.callLogs.isNotEmpty
        ? _apiService.callLogs.first
        : null;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kỹ thuật 2: Gọi REST API & JSON',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              'GET / POST / PUT / DELETE • Vũ Trọng Khánh PM28.12',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Test gọi URL API bất kỳ',
            onPressed: _showCustomUrlTesterDialog,
            icon: const Icon(Icons.http_rounded, color: Color(0xFF2563EB)),
          ),
          IconButton(
            tooltip: 'Xem Nhật ký HTTP & JSON trả về',
            onPressed: () =>
                setState(() => _showJsonConsole = !_showJsonConsole),
            icon: Icon(
              Icons.data_object_rounded,
              color: _showJsonConsole
                  ? const Color(0xFF10B981)
                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
            ),
          ),
          IconButton(
            tooltip: 'Tải lại dữ liệu từ API',
            onPressed: _fetchAllApiData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0284C7),
        onPressed: _showCreatePostDialog,
        icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
        label: const Text(
          'POST Bài Viết Lên API',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. Banner trạng thái kết nối API thời gian thực
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.public_rounded, color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestLog != null
                            ? '${latestLog.method} ${latestLog.url}'
                            : 'Đang kết nối tới REST API https://dummyjson.com...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latestLog != null
                            ? 'HTTP ${latestLog.statusCode} OK • ${latestLog.durationMs}ms • SP: ${_products.length} | Posts: ${_articles.length} | Users: ${_users.length} | Quái: ${_apiMonsters.length}'
                            : 'Tải dữ liệu JSON trực tuyến và hiển thị lên giao diện',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: _showCustomUrlTesterDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Test URL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. JSON & HTTP Console (Bật/tắt để kiểm tra gói tin mạng)
          if (_showJsonConsole)
            Container(
              height: 155,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.terminal_rounded,
                        color: Color(0xFF38BDF8),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'NHẬT KÝ GỌI REST API & PHẢN HỒI JSON (LIVE NETWORK LOG)',
                        style: TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _apiService.callLogs.length,
                      itemBuilder: (context, idx) {
                        final log = _apiService.callLogs[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '[${log.time}] ${log.method} ${log.url} ➔ HTTP ${log.statusCode} (${log.durationMs}ms)\nJSON: ${log.responsePreview}',
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10.5,
                              color: Color(0xFFA7F3D0),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // 3. Bộ chuyển đổi 4 Endpoint API
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildEndpointTab(
                  index: 0,
                  icon: Icons.devices_other_rounded,
                  label: 'SP (${_products.length})',
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildEndpointTab(
                  index: 1,
                  icon: Icons.article_rounded,
                  label: 'Posts (${_articles.length})',
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildEndpointTab(
                  index: 2,
                  icon: Icons.people_alt_rounded,
                  label: 'Users (${_users.length})',
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildEndpointTab(
                  index: 3,
                  icon: Icons.pest_control_rodent_rounded,
                  label: 'Quái API (${_apiMonsters.length})',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          // 4. Thanh tìm kiếm trực tiếp trên API (cho tab Sản phẩm)
          if (_selectedEndpoint == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: (_) => _searchProductsOnApi(),
                decoration: InputDecoration(
                  hintText:
                      'Tìm trên API (/products/search?q=phone, laptop...)',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    onPressed: _searchProductsOnApi,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
            ),

          // 5. Danh sách dữ liệu lấy từ API
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchAllApiData,
                    child: _buildSelectedEndpointList(isDark),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointTab({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final selected = _selectedEndpoint == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedEndpoint = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF2563EB)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF2563EB)
                  : (isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF475569)),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: selected
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedEndpointList(bool isDark) {
    if (_selectedEndpoint == 0) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final p = _products[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      p.thumbnail,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 72,
                        height: 72,
                        color: const Color(0xFFDBEAFE),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          color: Color(0xFF2563EB),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF2563EB,
                                ).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 15,
                            ),
                            Text(
                              ' ${p.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          p.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${p.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kho: ${p.stock}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: () => _saveApiItemToSqlite(
                                title: p.title,
                                content:
                                    'Giá: \$${p.price} | Hãng: ${p.brand} | Đánh giá: ${p.rating}⭐\nMô tả: ${p.description}',
                              ),
                              icon: const Icon(
                                Icons.save_alt_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Lưu SQLite',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_selectedEndpoint == 1) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final a = _articles[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'POST #${a.id}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...a.tags.take(3).map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(
                                '#$t',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'PUT cập nhật bài viết trên API',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _showEditPostDialog(index, a),
                        icon: const Icon(
                          Icons.edit_note_rounded,
                          size: 19,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      IconButton(
                        tooltip: 'DELETE xóa bài viết trên API',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _deletePostFromApi(index, a),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.body,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.thumb_up_alt_outlined,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      Text(
                        ' ${a.likes} lượt thích   ',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Icon(
                        Icons.visibility_outlined,
                        size: 15,
                        color: Colors.grey,
                      ),
                      Text(
                        ' ${a.views} lượt xem',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => _saveApiItemToSqlite(
                          title: a.title,
                          content: a.body,
                        ),
                        icon: const Icon(Icons.save_alt_rounded, size: 16),
                        label: const Text(
                          'Lưu SQLite',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    if (_selectedEndpoint == 2) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final u = _users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFFDBEAFE),
                backgroundImage: u.image.isNotEmpty
                    ? NetworkImage(u.image)
                    : null,
                child: u.image.isEmpty
                    ? Text(
                        u.firstName.isNotEmpty ? u.firstName[0] : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                '${u.fullName} (@${u.username})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    '📧 ${u.email} • 📞 ${u.phone}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  Text(
                    '🎓 ${u.university} • 💼 ${u.companyTitle}',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ],
              ),
              trailing: IconButton(
                tooltip: 'Lưu hồ sơ này vào SQLite',
                onPressed: () => _saveApiItemToSqlite(
                  title: 'User: ${u.fullName}',
                  content:
                      'Email: ${u.email}\nSĐT: ${u.phone}\nTrường: ${u.university}',
                ),
                icon: const Icon(
                  Icons.bookmark_add_outlined,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          );
        },
      );
    }

    // Tab 3: Quái Vật tải từ API về cho Game (`game.db`)
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF9333EA).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF9333EA).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF9333EA),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Dữ liệu Quái vật lấy từ REST API trực tuyến. Bấm nạp để thêm trực tiếp vào bảng monsters trong SQLite (game.db)!',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onPressed: _importAllMonstersToGameDb,
                icon: const Icon(Icons.download_done_rounded, size: 16),
                label: const Text(
                  'Nạp cả 4',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ..._apiMonsters.map((m) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFF1A092B),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(
                    m.image,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.bug_report_rounded,
                      color: Color(0xFFE040FB),
                    ),
                  ),
                ),
              ),
              title: Text(
                m.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.5,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '❤️ HP: ${m.hp}  |  ⚔️ DMG: ${m.damage}  |  ⚡ Speed: ${m.speed}x  |  🏆 Score: ${m.score}\n📁 Asset: ${m.image}',
                  style: const TextStyle(fontSize: 11.5),
                ),
              ),
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => _importMonsterToGameDb(m),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 15),
                label: const Text(
                  'Nạp Game',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
