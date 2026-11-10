import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_database_helper.dart';

class SqliteNotesScreen extends StatefulWidget {
  const SqliteNotesScreen({super.key});

  @override
  State<SqliteNotesScreen> createState() => _SqliteNotesScreenState();
}

class _SqliteNotesScreenState extends State<SqliteNotesScreen> {
  final NoteDatabaseHelper _dbHelper = NoteDatabaseHelper.instance;
  final TextEditingController _searchController = TextEditingController();

  List<NoteItem> _notes = [];
  bool _isLoading = true;
  String _selectedCategory = 'Tất cả';
  int _statusFilter = 0; // 0: Tất cả, 1: Chưa xong, 2: Đã xong
  bool _showSqlConsole = false;

  static const List<String> _categories = [
    'Tất cả',
    'Dự án Flutter',
    'Học tập',
    'Công việc',
    'Cá nhân',
  ];

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshNotes() async {
    setState(() => _isLoading = true);
    bool? completedFilter;
    if (_statusFilter == 1) completedFilter = false;
    if (_statusFilter == 2) completedFilter = true;

    final data = await _dbHelper.getAllNotes(
      searchQuery: _searchController.text,
      category: _selectedCategory,
      isCompleted: completedFilter,
    );

    if (!mounted) return;
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  String _formatNow() {
    final now = DateTime.now();
    final d = now.day.toString().padLeft(2, '0');
    final m = now.month.toString().padLeft(2, '0');
    final y = now.year;
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    return '$d/$m/$y $h:$min';
  }

  Future<void> _toggleNoteStatus(NoteItem note) async {
    final updated = note.copyWith(isCompleted: !note.isCompleted);
    await _dbHelper.updateNote(updated);
    await _refreshNotes();
  }

  Future<void> _deleteNote(NoteItem note) async {
    if (note.id == null) return;
    await _dbHelper.deleteNote(note.id!);
    await _refreshNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '🗑️ Đã xóa ghi chú #${note.id} khỏi SQLite!',
          style: const TextStyle(fontFamily: 'Times New Roman'),
        ),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _resetSamples() async {
    await _dbHelper.resetSampleData();
    await _refreshNotes();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '✅ Đã khôi phục bộ dữ liệu mẫu SQLite thành công!',
          style: TextStyle(fontFamily: 'Times New Roman'),
        ),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _showNoteFormDialog({NoteItem? existingNote}) {
    final isEditing = existingNote != null;
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController(text: existingNote?.title ?? '');
    final contentCtrl = TextEditingController(
      text: existingNote?.content ?? '',
    );
    String category = existingNote?.category ?? 'Dự án Flutter';
    int priority = existingNote?.priority ?? 2;
    bool isCompleted = existingNote?.isCompleted ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_note_rounded
                                  : Icons.add_task_rounded,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Cập Nhật Ghi Chú SQLite #${existingNote.id}'
                                  : 'Thêm Ghi Chú Mới Vào SQLite',
                              style: const TextStyle(
                                fontFamily: 'Times New Roman',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tiêu đề (TextFormField + Validator chuẩn Bài 40)
                      TextFormField(
                        controller: titleCtrl,
                        style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tiêu đề công việc / ghi chú *',
                          hintText: 'VD: Ôn tập SQLite CRUD thầy Tùng TITV',
                          prefixIcon: const Icon(Icons.title_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return '⚠️ Vui lòng nhập tiêu đề ghi chú!';
                          }
                          if (val.trim().length < 3) {
                            return '⚠️ Tiêu đề phải có ít nhất 3 ký tự!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Nội dung chi tiết
                      TextFormField(
                        controller: contentCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontFamily: 'Times New Roman'),
                        decoration: InputDecoration(
                          labelText: 'Nội dung chi tiết *',
                          hintText:
                              'Nhập mô tả chi tiết công việc hoặc kiến thức cần nhớ...',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return '⚠️ Vui lòng không để trống nội dung!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Danh mục & Độ ưu tiên
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: category,
                              decoration: InputDecoration(
                                labelText: 'Danh mục',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: _categories
                                  .where((c) => c != 'Tất cả')
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          fontFamily: 'Times New Roman',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setModalState(() => category = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: priority,
                              decoration: InputDecoration(
                                labelText: 'Mức độ ưu tiên',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text(
                                    '🟢 Bình thường',
                                    style: TextStyle(
                                      fontFamily: 'Times New Roman',
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 2,
                                  child: Text(
                                    '🟠 Quan trọng',
                                    style: TextStyle(
                                      fontFamily: 'Times New Roman',
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: 3,
                                  child: Text(
                                    '🔴 Khẩn cấp',
                                    style: TextStyle(
                                      fontFamily: 'Times New Roman',
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null)
                                  setModalState(() => priority = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Đánh dấu đã hoàn thành',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: isCompleted,
                        activeThumbColor: const Color(0xFF10B981),
                        onChanged: (val) =>
                            setModalState(() => isCompleted = val),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'HỦY BỎ',
                                style: TextStyle(
                                  fontFamily: 'Times New Roman',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (!formKey.currentState!.validate()) return;

                                final note = NoteItem(
                                  id: existingNote?.id,
                                  title: titleCtrl.text.trim(),
                                  content: contentCtrl.text.trim(),
                                  category: category,
                                  priority: priority,
                                  isCompleted: isCompleted,
                                  createdAt:
                                      existingNote?.createdAt ?? _formatNow(),
                                );

                                if (isEditing) {
                                  await _dbHelper.updateNote(note);
                                } else {
                                  await _dbHelper.insertNote(note);
                                }

                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                await _refreshNotes();

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEditing
                                          ? '✅ Đã cập nhật (UPDATE) ghi chú vào SQLite!'
                                          : '🎉 Đã thêm mới (INSERT) ghi chú vào SQLite!',
                                      style: const TextStyle(
                                        fontFamily: 'Times New Roman',
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF2563EB),
                                  ),
                                );
                              },
                              icon: Icon(
                                isEditing
                                    ? Icons.save_rounded
                                    : Icons.add_circle_outline_rounded,
                              ),
                              label: Text(
                                isEditing
                                    ? 'LƯU CẬP NHẬT (UPDATE)'
                                    : 'THÊM VÀO DB (INSERT)',
                                style: const TextStyle(
                                  fontFamily: 'Times New Roman',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = _notes.where((n) => n.isCompleted).length;
    final pendingCount = _notes.length - completedCount;
    final urgentCount = _notes
        .where((n) => n.priority == 3 && !n.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SQLite (sqflite) • Quản Lý Ghi Chú CRUD',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const Text(
              'Database thật: vutrongkhanh_notes.db • Anh Khánh PM28.12 🚀',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Bật/Tắt bảng giám sát lệnh SQL trực tiếp',
            icon: Icon(
              Icons.terminal_rounded,
              color: _showSqlConsole
                  ? const Color(0xFF10B981)
                  : const Color(0xFF2563EB),
            ),
            onPressed: () => setState(() => _showSqlConsole = !_showSqlConsole),
          ),
          IconButton(
            tooltip: 'Khôi phục dữ liệu mẫu SQLite',
            icon: const Icon(Icons.restore_rounded, color: Color(0xFFF59E0B)),
            onPressed: _resetSamples,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Thẻ thống kê trực quan (Dashboard)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storage_rounded,
                      color: Color(0xFF93C5FD),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'SQLite Path: ${_dbHelper.dbFullPath}',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          setState(() => _showSqlConsole = !_showSqlConsole),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _showSqlConsole
                              ? 'Ẩn SQL Log'
                              : 'Xem SQL Log (${_dbHelper.sqlLogs.length})',
                          style: const TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatBadge(
                      'Tổng bản ghi',
                      '${_notes.length}',
                      const Color(0xFF60A5FA),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      'Chưa xong',
                      '$pendingCount',
                      const Color(0xFFFBBF24),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      'Hoàn thành',
                      '$completedCount',
                      const Color(0xFF34D399),
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      'Khẩn cấp',
                      '$urgentCount',
                      const Color(0xFFF87171),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Bảng giám sát câu lệnh SQL thực tế (SQL Query Inspector)
          if (_showSqlConsole)
            Container(
              height: 115,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                        Icons.code_rounded,
                        color: Color(0xFF38BDF8),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'NHẬT KÝ TRUY VẤN SQLITE THỰC TẾ (LIVE SQL LOG):',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _dbHelper.sqlLogs.length,
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.5),
                        child: Text(
                          _dbHelper.sqlLogs[i],
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 3. Thanh tìm kiếm (SELECT ... WHERE title LIKE '%...%')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _refreshNotes(),
              style: const TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 14.5,
              ),
              decoration: InputDecoration(
                hintText:
                    'Tìm kiếm ghi chú trong SQLite (SELECT WHERE LIKE)...',
                hintStyle: const TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 13.5,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF2563EB),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _refreshNotes();
                        },
                      )
                    : null,
                isDense: true,
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
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

          // 4. Bộ lọc Danh mục & Trạng thái
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildStatusChip('Tất cả', 0, isDark),
                const SizedBox(width: 6),
                _buildStatusChip('⏳ Chưa xong', 1, isDark),
                const SizedBox(width: 6),
                _buildStatusChip('✅ Đã xong', 2, isDark),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: VerticalDivider(width: 1),
                ),
                ..._categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 12.5,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: selected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: selected,
                      selectedColor: const Color(0xFF4F46E5),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                        _refreshNotes();
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // 5. Danh sách bản ghi từ SQLite
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 58,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Không có bản ghi nào khớp điều kiện truy vấn SQLite',
                          style: TextStyle(
                            fontFamily: 'Times New Roman',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _resetSamples,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(
                            'Nạp lại dữ liệu mẫu',
                            style: TextStyle(fontFamily: 'Times New Roman'),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 85),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return _buildNoteCard(note, isDark);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2563EB),
        onPressed: () => _showNoteFormDialog(),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm Ghi Chú (INSERT)',
          style: TextStyle(
            fontFamily: 'Times New Roman',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 11,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int value, bool isDark) {
    final selected = _statusFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Times New Roman',
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected
              ? Colors.white
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF2563EB),
      onSelected: (_) {
        setState(() => _statusFilter = value);
        _refreshNotes();
      },
    );
  }

  Widget _buildNoteCard(NoteItem note, bool isDark) {
    final Color priorityColor = note.priority == 3
        ? const Color(0xFFEF4444)
        : (note.priority == 2
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981));
    final String priorityText = note.priority == 3
        ? 'Khẩn cấp'
        : (note.priority == 2 ? 'Quan trọng' : 'Bình thường');

    return Dismissible(
      key: ValueKey('sqlite_note_${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'XÓA (DELETE)',
              style: TextStyle(
                fontFamily: 'Times New Roman',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => _deleteNote(note),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showNoteFormDialog(existingNote: note),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Primary Key Badge (#ID)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID #${note.id}',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        note.category,
                        style: const TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Priority Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priorityText,
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Checkbox hoàn thành (UPDATE)
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: note.isCompleted,
                        activeColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (_) => _toggleNoteStatus(note),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note.title,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: note.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    color: note.isCompleted
                        ? Colors.grey
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  note.content,
                  style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 13.8,
                    height: 1.35,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      note.createdAt,
                      style: const TextStyle(
                        fontFamily: 'Times New Roman',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFF2563EB),
                      ),
                      onPressed: () => _showNoteFormDialog(existingNote: note),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text(
                        'Sửa (UPDATE)',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: const Color(0xFFEF4444),
                      ),
                      onPressed: () => _deleteNote(note),
                      icon: const Icon(Icons.delete_outline_rounded, size: 16),
                      label: const Text(
                        'Xóa (DELETE)',
                        style: TextStyle(
                          fontFamily: 'Times New Roman',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
