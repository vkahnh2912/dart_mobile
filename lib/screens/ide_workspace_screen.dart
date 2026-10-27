import 'package:flutter/material.dart';
import '../models/ide_models.dart';
import '../services/ide_storage_service.dart';
import 'code_editor_screen.dart';

class IdeWorkspaceScreen extends StatefulWidget {
  const IdeWorkspaceScreen({super.key});

  @override
  State<IdeWorkspaceScreen> createState() => _IdeWorkspaceScreenState();
}

class _IdeWorkspaceScreenState extends State<IdeWorkspaceScreen> {
  List<UserProject> _projects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final projects = await IdeStorageService.loadProjects();
    setState(() {
      _projects = projects;
      _isLoading = false;
    });
  }

  Future<void> _saveAll() async {
    await IdeStorageService.saveProjects(_projects);
    setState(() {});
  }

  void _showNewProjectDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.create_new_folder_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8),
            Text('Tạo Project Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên Project',
                hintText: 'VD: Luyện Tập OOP, Game Mini...',
                prefixIcon: Icon(Icons.folder_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả ngắn (tùy chọn)',
                hintText: 'VD: Các bài tự luyện thêm ngoài giờ',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final newProj = UserProject(
                id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                description: descController.text.trim(),
                createdAt: DateTime.now(),
                files: [
                  UserFile(
                    id: 'file_${DateTime.now().millisecondsSinceEpoch}',
                    name: 'main.dart',
                    content: '''void main() {
  print('Xin chào từ project: $name');
}
''',
                    updatedAt: DateTime.now(),
                  ),
                ],
              );

              setState(() {
                _projects.insert(0, newProj);
              });
              _saveAll();
              Navigator.pop(ctx);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('🎉 Đã tạo project "$name" thành công!')),
              );
            },
            child: const Text('Tạo ngay'),
          ),
        ],
      ),
    );
  }

  void _showNewFileDialog(UserProject project) {
    final nameController = TextEditingController(text: 'bai_tap_${project.files.length + 1}.dart');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.note_add_rounded, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Text('Tạo File .dart Mới', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Trong project: ${project.name}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Tên File',
                hintText: 'VD: test.dart, bai_toan.dart',
                prefixIcon: Icon(Icons.code_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              var fileName = nameController.text.trim();
              if (fileName.isEmpty) return;
              if (!fileName.endsWith('.dart')) {
                fileName = '$fileName.dart';
              }

              final newFile = UserFile(
                id: 'file_${DateTime.now().millisecondsSinceEpoch}',
                name: fileName,
                content: '''void main() {
  print('=== File: $fileName ===');
  // Viết code Dart của anh vào đây nhé!
}
''',
                updatedAt: DateTime.now(),
              );

              setState(() {
                project.files.add(newFile);
              });
              _saveAll();
              Navigator.pop(ctx);

              _openEditor(project, newFile);
            },
            child: const Text('Tạo & Soạn thảo'),
          ),
        ],
      ),
    );
  }

  void _openEditor(UserProject project, UserFile file) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CodeEditorScreen(
          project: project,
          file: file,
          onSave: (newContent) {
            file.content = newContent;
            file.updatedAt = DateTime.now();
            _saveAll();
          },
        ),
      ),
    );
  }

  void _renameFile(UserProject project, UserFile file) {
    final nameController = TextEditingController(text: file.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đổi Tên File'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Tên mới'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              var newName = nameController.text.trim();
              if (newName.isEmpty) return;
              if (!newName.endsWith('.dart')) newName = '$newName.dart';
              setState(() {
                file.name = newName;
                file.updatedAt = DateTime.now();
              });
              _saveAll();
              Navigator.pop(ctx);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _deleteFile(UserProject project, UserFile file) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Anh có chắc muốn xóa file "${file.name}" không?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() {
                project.files.removeWhere((f) => f.id == file.id);
              });
              _saveAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa file ${file.name}')),
              );
            },
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  void _deleteProject(UserProject project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa Toàn Bộ Project'),
        content: Text('Anh có chắc muốn xóa project "${project.name}" cùng tất cả ${project.files.length} file bên trong?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _projects.removeWhere((p) => p.id == project.id);
              });
              _saveAll();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa project ${project.name}')),
              );
            },
            child: const Text('Xóa project'),
          ),
        ],
      ),
    );
  }

  void _duplicateFile(UserProject project, UserFile file) {
    final newFile = UserFile(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      name: file.name.replaceAll('.dart', '_copy.dart'),
      content: file.content,
      updatedAt: DateTime.now(),
    );
    setState(() {
      project.files.add(newFile);
    });
    _saveAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã nhân bản file ${newFile.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredProjects = _projects.where((p) {
      final q = _searchQuery.trim().toLowerCase();
      if (q.isEmpty) return true;
      final matchesName = p.name.toLowerCase().contains(q);
      final matchesDesc = p.description.toLowerCase().contains(q);
      final matchesFile = p.files.any((f) => f.name.toLowerCase().contains(q));
      return matchesName || matchesDesc || matchesFile;
    }).toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // AppBar với Header nổi bật
                SliverAppBar(
                  expandedHeight: 130,
                  pinned: true,
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                    title: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Không Gian Code • VuTrongKhanh.PM28.12',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Tạo mới • Soạn thảo • Xóa file • Chạy Live 🚀',
                          style: TextStyle(fontSize: 10, color: Colors.white70),
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Tạo Project mới',
                      icon: const Icon(Icons.create_new_folder_rounded, size: 24),
                      onPressed: _showNewProjectDialog,
                    ),
                    IconButton(
                      tooltip: 'Làm mới',
                      icon: const Icon(Icons.refresh_rounded, size: 22),
                      onPressed: _loadData,
                    ),
                  ],
                ),

                // Ô tìm kiếm file và project
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm file hoặc project...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                    ),
                  ),
                ),

                // Thống kê nhanh
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_projects.length} Dự án • ${_projects.fold<int>(0, (sum, p) => sum + p.files.length)} File code',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        InkWell(
                          onTap: _showNewProjectDialog,
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: Color(0xFF6366F1)),
                                SizedBox(width: 4),
                                Text(
                                  'New Project',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6366F1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Danh sách các Project
                if (filteredProjects.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 56,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'Không tìm thấy kết quả phù hợp' : 'Chưa có project nào',
                            style: TextStyle(
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Tạo Project Đầu Tiên'),
                            onPressed: _showNewProjectDialog,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final project = filteredProjects[index];
                          return _buildProjectCard(project, isDark);
                        },
                        childCount: filteredProjects.length,
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.note_add_rounded, size: 22),
        label: const Text('TẠO FILE MỚI', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          if (_projects.isEmpty) {
            _showNewProjectDialog();
          } else {
            _showNewFileDialog(_projects.first);
          }
        },
      ),
    );
  }

  Widget _buildProjectCard(UserProject project, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.folder_rounded, color: Color(0xFF6366F1), size: 24),
          ),
          title: Text(
            project.name,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          subtitle: Text(
            project.description.isNotEmpty
                ? '${project.description} • ${project.files.length} file'
                : '${project.files.length} file .dart',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Thêm file vào project',
                icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF10B981), size: 22),
                onPressed: () => _showNewFileDialog(project),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (action) {
                  if (action == 'new_file') {
                    _showNewFileDialog(project);
                  } else if (action == 'delete') {
                    _deleteProject(project);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'new_file',
                    child: Row(
                      children: [
                        Icon(Icons.add_rounded, size: 18, color: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Text('Tạo file mới'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa Project', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            if (project.files.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thư mục này chưa có file nào',
                      style: TextStyle(fontSize: 12.5, color: isDark ? Colors.white38 : Colors.black38),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Tạo file ngay'),
                      onPressed: () => _showNewFileDialog(project),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: project.files.length,
                separatorBuilder: (ctx, i) => Divider(
                  height: 1,
                  indent: 52,
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, fIndex) {
                  final file = project.files[fIndex];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.code_rounded, color: Color(0xFF0EA5E9), size: 18),
                    ),
                    title: Text(
                      file.name,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(
                      'Cập nhật: ${file.updatedAt.hour}:${file.updatedAt.minute.toString().padLeft(2, '0')} ngày ${file.updatedAt.day}/${file.updatedAt.month}',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black45),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Chạy nhanh / Soạn thảo',
                          icon: const Icon(Icons.edit_note_rounded, color: Color(0xFF6366F1)),
                          onPressed: () => _openEditor(project, file),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz_rounded, size: 18),
                          onSelected: (act) {
                            if (act == 'rename') {
                              _renameFile(project, file);
                            } else if (act == 'duplicate') {
                              _duplicateFile(project, file);
                            } else if (act == 'delete') {
                              _deleteFile(project, file);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 16),
                                  SizedBox(width: 8),
                                  Text('Đổi tên file'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'duplicate',
                              child: Row(
                                children: [
                                  Icon(Icons.copy_rounded, size: 16),
                                  SizedBox(width: 8),
                                  Text('Nhân bản file'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa file', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _openEditor(project, file),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
