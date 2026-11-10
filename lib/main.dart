import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'lessons_registry.dart';
import 'lesson_sources.dart';
import 'lessons/Video10_OnTap_IfElse_GiaiPTB2/vidu_17_giai_phuong_trinh_bac_2.dart' as v10_custom;
import 'models/ide_models.dart';
import 'services/ide_storage_service.dart';
import 'screens/code_editor_screen.dart';
import 'screens/ide_workspace_screen.dart';
import 'games/game_hub_screen.dart';
import 'screens/sqlite_notes_screen.dart';
import 'screens/rest_api_screen.dart';
import 'screens/firebase_backend_screen.dart';
import 'services/firebase_backend_service.dart';
import 'database/database_helper.dart';

// Quản lý Theme toàn app (Mặc định sáng theo yêu cầu của anh Khánh)
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);
// Quản lý Cỡ chữ code và kết quả
final ValueNotifier<double> appCodeFontSize = ValueNotifier(14.5);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper.instance.database.ignore();
  FirebaseBackendService.instance.init().ignore();
  runApp(const DartTITVApp());
}

class DartTITVApp extends StatelessWidget {
  const DartTITVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'VuTrongKhanh.PM28.12',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // Giao diện Sáng (Light Theme) màu sáng thanh lịch, tinh tế, font Times New Roman
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Times New Roman',
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2563EB),
              brightness: Brightness.light,
              surface: Colors.white,
              surfaceContainer: const Color(0xFFF8FAFC),
              primary: const Color(0xFF2563EB),
              secondary: const Color(0xFF4F46E5),
            ),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF0F172A),
              elevation: 0.8,
              titleTextStyle: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Times New Roman'),
              bodyMedium: TextStyle(fontFamily: 'Times New Roman'),
              titleLarge: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold),
              titleSmall: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.w600),
            ),
          ),
          // Giao diện Tối (Dark Theme) dự phòng
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Times New Roman',
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E293B),
              surfaceContainer: const Color(0xFF243044),
              primary: const Color(0xFF38BDF8),
              secondary: const Color(0xFFA855F7),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E293B),
              foregroundColor: Colors.white,
              elevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E293B),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF334155)),
              ),
            ),
          ),
          home: const MainShellScreen(),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// KHUNG ĐIỀU HƯỚNG CHÍNH CHIA LÀM 2 PHẦN THEO YÊU CẦU:
// PHẦN 1: BÀI HỌC & VÍ DỤ THỰC HÀNH (VIDEO 10 - 40)
// PHẦN 2: KHÔNG GIAN VIẾT CODE NHƯ VISUAL STUDIO CODE
// ---------------------------------------------------------
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),             // Tab 0: Bài học & Ví dụ (Video 10-46)
          SqliteNotesScreen(),      // Tab 1: Kỹ thuật 1 - SQLite Database
          RestApiScreen(),          // Tab 2: Kỹ thuật 2 - Gọi REST API trên mạng
          FirebaseBackendScreen(),  // Tab 3: Kỹ thuật 3 - Firebase Auth & CSDL
          GameHubScreen(),          // Tab 4: Chơi Game (Lưu điểm & quái game.db)
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          indicatorColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
          elevation: 2,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded, color: Color(0xFF2563EB)),
              label: 'Bài Học',
            ),
            NavigationDestination(
              icon: Icon(Icons.storage_outlined),
              selectedIcon: Icon(Icons.storage_rounded, color: Color(0xFF2563EB)),
              label: '1. SQLite',
            ),
            NavigationDestination(
              icon: Icon(Icons.public_outlined),
              selectedIcon: Icon(Icons.public_rounded, color: Color(0xFF2563EB)),
              label: '2. Gọi API',
            ),
            NavigationDestination(
              icon: Icon(Icons.cloud_done_outlined),
              selectedIcon: Icon(Icons.cloud_done_rounded, color: Color(0xFF2563EB)),
              label: '3. Firebase',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined),
              selectedIcon: Icon(Icons.sports_esports_rounded, color: Color(0xFF2563EB)),
              label: 'Chơi Game',
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// PHẦN 1: TRANG DANH SÁCH BÀI HỌC VÀ VÍ DỤ TỪ VIDEO 10 ĐẾN 30
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedVideoFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<LessonItem> get _filteredLessons {
    return allLessons.where((lesson) {
      final matchesVideo = _selectedVideoFilter == null || lesson.videoNumber == _selectedVideoFilter;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          lesson.exampleTitle.toLowerCase().contains(query) ||
          lesson.summary.toLowerCase().contains(query) ||
          lesson.videoTitle.toLowerCase().contains(query);
      return matchesVideo && matchesSearch;
    }).toList();
  }

  void _openLesson(LessonItem lesson) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(lesson: lesson),
      ),
    );
  }

  void _runAllLessonsBatch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BatchRunScreen(),
      ),
    );
  }

  void _toggleTheme() {
    if (appThemeMode.value == ThemeMode.dark) {
      appThemeMode.value = ThemeMode.light;
    } else {
      appThemeMode.value = ThemeMode.dark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredLessons;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dart & Flutter TITV • Video 10 - 46',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const Text(
              'Dành riêng cho anh Khánh đẹp trai nhất vũ trụ 🚀',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        actions: [
          // Nút mở Không Gian Code (VS Code)
          IconButton(
            tooltip: 'Mở Không Gian Code (VS Code)',
            icon: const Icon(Icons.terminal_rounded, color: Color(0xFF4F46E5)),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IdeWorkspaceScreen()),
              );
            },
          ),
          // Nút đổi giao diện Sáng / Tối
          IconButton(
            tooltip: isDark ? 'Chuyển sang giao diện Sáng' : 'Chuyển sang giao diện Tối',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF475569),
            ),
            onPressed: _toggleTheme,
          ),
          // Nút chạy toàn bộ bài tự động
          IconButton(
            tooltip: 'Chạy toàn bộ bài tự động',
            icon: const Icon(Icons.playlist_play_rounded, color: Color(0xFF2563EB), size: 28),
            onPressed: _runAllLessonsBatch,
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm phong cách sáng sủa
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài học (OOP, List, Map, Future, Stream, Widget...)',
                hintStyle: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
          ),

          // Bộ lọc danh mục Video từ 10 đến 30
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: allVideos.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedVideoFilter == null;
                  return ChoiceChip(
                    label: Text(
                      'Tất cả (${allVideos.length} Video)',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedVideoFilter = null),
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  );
                }
                final video = allVideos[index - 1];
                final isSelected = _selectedVideoFilter == video.videoNumber;
                return ChoiceChip(
                  label: Text(
                    'Video ${video.videoNumber}',
                    style: TextStyle(
                      fontFamily: 'Times New Roman',
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedVideoFilter = video.videoNumber),
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Thanh thống kê số bài
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách ví dụ & thực hành (${filtered.length})',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                ),
                Text(
                  _selectedVideoFilter == null
                      ? 'Video 10 ➔ 30'
                      : 'Video ${_selectedVideoFilter.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách bài tập
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'Không tìm thấy bài học phù hợp',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 15,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final lesson = filtered[index];
                      return _buildLessonCard(lesson, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Chạy toàn bộ (31 video)',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        onPressed: _runAllLessonsBatch,
      ),
    );
  }

  Widget _buildLessonCard(LessonItem lesson, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openLesson(lesson),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Video ${lesson.videoNumber.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 12.5,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (lesson.requiresInput)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Nhập tham số',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 11.5,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                lesson.exampleTitle,
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lesson.summary,
                style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 14,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.code_rounded, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      lesson.filePath,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontFamily: 'Courier',
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.terminal_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Xem Code & Chạy',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// MÀN HÌNH CHI TIẾT VÍ DỤ: TAB 1 LÀ MÃ NGUỒN, TAB 2 LÀ KẾT QUẢ
// ---------------------------------------------------------
class LessonDetailScreen extends StatefulWidget {
  final LessonItem lesson;
  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _consoleLogs = [];
  bool _isRunning = false;
  bool _hasRun = false;

  // Controllers cho bài giải phương trình bậc 2 (Video 10)
  final TextEditingController _aController = TextEditingController(text: '1');
  final TextEditingController _bController = TextEditingController(text: '-5');
  final TextEditingController _cController = TextEditingController(text: '6');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aController.dispose();
    _bController.dispose();
    _cController.dispose();
    super.dispose();
  }

  void _runCode() {
    setState(() {
      _consoleLogs.clear();
      _isRunning = true;
      _hasRun = true;
    });

    final logs = <String>[];
    logs.add('==================================================================');
    logs.add('  BÀI HỌC: ${widget.lesson.exampleTitle}');
    logs.add('  FILE NGUỒN: ${widget.lesson.filePath}');
    logs.add('==================================================================\n');

    runZoned(
      () {
        try {
          if (widget.lesson.id == 10) {
            // Video 10 - PTB2
            final a = double.tryParse(_aController.text.trim()) ?? 1.0;
            final b = double.tryParse(_bController.text.trim()) ?? -5.0;
            final c = double.tryParse(_cController.text.trim()) ?? 6.0;
            v10_custom.solveEquation(a, b, c);
          } else {
            widget.lesson.run();
          }
        } catch (e, stack) {
          logs.add('❌ LỖI KHI CHẠY: $e\n$stack');
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    logs.add('\n==================================================================');
    logs.add('✅ THỰC THI HOÀN TẤT!');
    logs.add('==================================================================');

    setState(() {
      _consoleLogs.addAll(logs);
      _isRunning = false;
    });

    // Chuyển sang Tab 2 (Kết Quả) để anh xem ngay sau khi nhấn Chạy
    _tabController.animateTo(1);
  }

  void _copyText(String content, String message) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Times New Roman')),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  void _zoomIn() {
    if (appCodeFontSize.value < 24.0) {
      appCodeFontSize.value += 1.5;
    }
  }

  void _zoomOut() {
    if (appCodeFontSize.value > 11.0) {
      appCodeFontSize.value -= 1.5;
    }
  }

  Future<void> _cloneToWorkspace(String sourceCode) async {
    final projects = await IdeStorageService.loadProjects();
    if (!mounted) return;
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có Project nào trong Không Gian Code!', style: TextStyle(fontFamily: 'Times New Roman'))),
      );
      return;
    }

    UserProject selectedProject = projects.first;
    final defaultFileName = 'bai_${widget.lesson.videoNumber}_vd${widget.lesson.id}.dart';
    final nameController = TextEditingController(text: defaultFileName);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.drive_file_move_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Expanded(
                child: Text('Sao Chép Sang Không Gian Code', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn Project lưu trữ:', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              DropdownButtonFormField<UserProject>(
                initialValue: selectedProject,
                isExpanded: true,
                items: projects.map((p) => DropdownMenuItem(value: p, child: Text(p.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Times New Roman')))).toList(),
                onChanged: (p) {
                  if (p != null) setDialogState(() => selectedProject = p);
                },
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              ),
              const SizedBox(height: 12),
              const Text('Tên file .dart mới:', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(fontFamily: 'Times New Roman'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
              onPressed: () async {
                var fName = nameController.text.trim();
                if (fName.isEmpty) return;
                if (!fName.endsWith('.dart')) fName = '$fName.dart';

                final newFile = UserFile(
                  id: 'file_${DateTime.now().millisecondsSinceEpoch}',
                  name: fName,
                  content: sourceCode,
                  updatedAt: DateTime.now(),
                );

                selectedProject.files.add(newFile);
                await IdeStorageService.saveProjects(projects);
                if (!mounted) return;
                Navigator.pop(ctx);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CodeEditorScreen(
                      project: selectedProject,
                      file: newFile,
                      onSave: (newContent) async {
                        newFile.content = newContent;
                        newFile.updatedAt = DateTime.now();
                        await IdeStorageService.saveProjects(projects);
                      },
                    ),
                  ),
                );
              },
              child: const Text('Sao chép & Mở sửa ngay', style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sourceCode = lessonSources[lesson.id] ?? '// Không tìm thấy mã nguồn bài này';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video ${lesson.videoNumber.toString().padLeft(2, '0')}: ${lesson.exampleTitle.split(':').first}',
          style: const TextStyle(fontFamily: 'Times New Roman', fontSize: 16.5, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Nút sao chép sang Không Gian Code để sửa
          IconButton(
            tooltip: 'Sao chép sang Không Gian Code để sửa',
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF10B981), size: 24),
            onPressed: () => _cloneToWorkspace(sourceCode),
          ),
          // Nút giảm cỡ chữ
          IconButton(
            tooltip: 'Giảm cỡ chữ (A-)',
            icon: const Icon(Icons.text_decrease_rounded, size: 20),
            onPressed: _zoomOut,
          ),
          // Nút tăng cỡ chữ
          IconButton(
            tooltip: 'Tăng cỡ chữ (A+)',
            icon: const Icon(Icons.text_increase_rounded, size: 22),
            onPressed: _zoomIn,
          ),
          // Nút sao chép
          IconButton(
            tooltip: 'Sao chép nội dung đang xem',
            icon: const Icon(Icons.copy_rounded, size: 20),
            onPressed: () {
              if (_tabController.index == 0) {
                _copyText(sourceCode, 'Đã sao chép toàn bộ Mã Nguồn Dart!');
              } else {
                _copyText(_consoleLogs.join('\n'), 'Đã sao chép Kết Quả Terminal!');
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2563EB),
          unselectedLabelColor: isDark ? Colors.white60 : Colors.black45,
          indicatorColor: const Color(0xFF2563EB),
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.code_rounded, size: 20),
              child: Text('MÃ NGUỒN DART', style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold, fontSize: 13.5)),
            ),
            Tab(
              icon: Icon(Icons.terminal_rounded, size: 20),
              child: Text('KẾT QUẢ THỰC THI', style: TextStyle(fontFamily: 'Times New Roman', fontWeight: FontWeight.bold, fontSize: 13.5)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Thẻ tóm tắt bài với font Times New Roman
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.exampleTitle,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.summary,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 13.5,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),

          // Tùy chỉnh input nếu là bài phương trình bậc 2 (Video 10)
          if (lesson.id == 10) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _aController,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      decoration: const InputDecoration(labelText: 'Hệ số a', isDense: true, border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _bController,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      decoration: const InputDecoration(labelText: 'Hệ số b', isDense: true, border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: _cController,
                      keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                      decoration: const InputDecoration(labelText: 'Hệ số c', isDense: true, border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Vùng nội dung TabView
          Expanded(
            child: ValueListenableBuilder<double>(
              valueListenable: appCodeFontSize,
              builder: (context, fontSize, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: HIỂN THỊ MÃ NGUỒN DART CỰC KỲ RÕ RÀNG
                    _buildSourceCodeView(sourceCode, fontSize, isDark),

                    // TAB 2: HIỂN THỊ KẾT QUẢ TERMINAL
                    _buildConsoleOutputView(fontSize, isDark),
                  ],
                );
              },
            ),
          ),

          // Thanh công cụ nút "CHẠY CODE" ở dưới cùng
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Cỡ chữ: ${appCodeFontSize.value.toStringAsFixed(1)}px',
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _runCode,
                  icon: _isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                  label: Text(
                    _isRunning ? 'Đang thực thi...' : '▶ CHẠY VÍ DỤ NÀY',
                    style: const TextStyle(
                      fontFamily: 'Times New Roman',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 13.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị mã nguồn có số dòng và màu sắc rõ nét
  Widget _buildSourceCodeView(String code, double fontSize, bool isDark) {
    final lines = code.split('\n');
    final bgColor = isDark ? const Color(0xFF181F2C) : const Color(0xFFF8FAFC);
    final gutterColor = isDark ? const Color(0xFF131924) : const Color(0xFFEDF2F7);
    final borderColor = isDark ? const Color(0xFF283344) : const Color(0xFFE2E8F0);

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cột số thứ tự dòng code (Line numbers)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: gutterColor,
                  border: Border(right: BorderSide(color: borderColor)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(
                    lines.length,
                    (i) => Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: fontSize,
                        height: 1.5,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Cột nội dung mã code được tô màu
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lines.map((line) => _buildCodeLine(line, fontSize, isDark)).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tô màu thông minh cho từng dòng code Dart
  Widget _buildCodeLine(String line, double fontSize, bool isDark) {
    final trimmed = line.trim();

    Color textColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

    // Ghi chú (Comments)
    if (trimmed.startsWith('//') || trimmed.startsWith('/*') || trimmed.startsWith('*') || trimmed.startsWith('///')) {
      textColor = isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    }
    // Import
    else if (trimmed.startsWith('import ') || trimmed.startsWith('export ')) {
      textColor = const Color(0xFFA855F7);
    }
    // Khai báo hàm main, class
    else if (trimmed.contains('void main(') || trimmed.contains('class ')) {
      textColor = const Color(0xFF2563EB);
    }

    return Text(
      line.isEmpty ? ' ' : line,
      style: TextStyle(
        fontFamily: 'Courier',
        fontSize: fontSize,
        height: 1.5,
        color: textColor,
        fontWeight: trimmed.startsWith('//') ? FontWeight.w500 : FontWeight.w600,
      ),
    );
  }

  // Widget hiển thị kết quả Terminal
  Widget _buildConsoleOutputView(double fontSize, bool isDark) {
    if (!_hasRun && _consoleLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: 64,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có kết quả thực thi',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bấm nút "▶ CHẠY VÍ DỤ NÀY" ở bên dưới để xem kết quả in ra màn hình.',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    final terminalBg = isDark ? const Color(0xFF0B101B) : const Color(0xFF1E293B);
    const terminalText = Color(0xFF38BDF8);

    return Container(
      color: terminalBg,
      padding: const EdgeInsets.all(14),
      child: SingleChildScrollView(
        child: SelectableText(
          _consoleLogs.join('\n'),
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: fontSize,
            height: 1.5,
            color: terminalText,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// MÀN HÌNH CHẠY BATCH TOÀN BỘ 31 BÀI TỰ ĐỘNG (VIDEO 10 - 40)
// ---------------------------------------------------------
class BatchRunScreen extends StatefulWidget {
  const BatchRunScreen({super.key});

  @override
  State<BatchRunScreen> createState() => _BatchRunScreenState();
}

class _BatchRunScreenState extends State<BatchRunScreen> {
  final List<String> _logs = [];
  bool _isRunning = false;
  int _completedCount = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _startBatchRun();
  }

  Future<void> _startBatchRun() async {
    setState(() {
      _logs.clear();
      _isRunning = true;
      _completedCount = 0;
    });

    final autoLessons = allLessons.where((l) => !l.requiresInput).toList();

    _appendLog('╔══════════════════════════════════════════════════════════════════╗');
    _appendLog('║   CHẠY TỰ ĐỘNG TOÀN BỘ ${autoLessons.length} BÀI THỰC HÀNH DART (VIDEO 10 -> 30) ║');
    _appendLog('║   Dành riêng cho: Anh Khánh đẹp trai nhất vũ trụ 🚀              ║');
    _appendLog('╚══════════════════════════════════════════════════════════════════╝\n');

    for (int i = 0; i < autoLessons.length; i++) {
      final lesson = autoLessons[i];
      _appendLog('------------------------------------------------------------------');
      _appendLog('▶ [BÀI ${(i + 1).toString().padLeft(2, '0')}/${autoLessons.length}] Video ${lesson.videoNumber}: ${lesson.exampleTitle}');
      _appendLog('📁 File: ${lesson.filePath}');
      _appendLog('------------------------------------------------------------------');

      final captured = <String>[];
      runZoned(
        () {
          try {
            lesson.run();
          } catch (e, stack) {
            captured.add('❌ LỖI: $e\n$stack');
          }
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) {
            captured.add(line);
          },
        ),
      );

      for (final line in captured) {
        _appendLog(line);
      }
      _appendLog('');

      setState(() {
        _completedCount = i + 1;
      });

      await Future.delayed(const Duration(milliseconds: 50));
    }

    _appendLog('==================================================================');
    _appendLog('🎉 HOÀN THÀNH TẤT CẢ ${autoLessons.length} BÀI THỰC HÀNH TỰ ĐỘNG!');
    _appendLog('==================================================================');

    setState(() {
      _isRunning = false;
    });
  }

  void _appendLog(String text) {
    setState(() {
      _logs.add(text);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final autoLessons = allLessons.where((l) => !l.requiresInput).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chạy Batch 31 Bài Tự Động (10-40)', style: TextStyle(fontFamily: 'Times New Roman', fontSize: 16.5, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Chạy lại từ đầu',
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB)),
            onPressed: _isRunning ? null : _startBatchRun,
          ),
          IconButton(
            tooltip: 'Sao chép tất cả kết quả',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _logs.join('\n')));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã sao chép toàn bộ kết quả!', style: TextStyle(fontFamily: 'Times New Roman'))),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isRunning ? 'Đang chạy: $_completedCount / ${autoLessons.length} bài' : 'Đã hoàn tất toàn bộ!',
                      style: TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      '${((_completedCount / autoLessons.length) * 100).toInt()}%',
                      style: const TextStyle(fontFamily: 'Times New Roman', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: autoLessons.isEmpty ? 0 : _completedCount / autoLessons.length,
                    minHeight: 7,
                    backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
              padding: const EdgeInsets.all(12),
              child: SelectionArea(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final line = _logs[index];
                    Color textColor = const Color(0xFF38BDF8);
                    if (line.startsWith('▶') || line.startsWith('╔') || line.startsWith('╚') || line.startsWith('║')) {
                      textColor = const Color(0xFF818CF8);
                    } else if (line.startsWith('❌')) {
                      textColor = Colors.redAccent;
                    } else if (line.startsWith('🎉')) {
                      textColor = const Color(0xFFFBBF24);
                    }
                    return Text(
                      line,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
