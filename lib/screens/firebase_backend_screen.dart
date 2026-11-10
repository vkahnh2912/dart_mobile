import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/firebase_backend_service.dart';

class FirebaseBackendScreen extends StatefulWidget {
  const FirebaseBackendScreen({super.key});

  @override
  State<FirebaseBackendScreen> createState() => _FirebaseBackendScreenState();
}

class _FirebaseBackendScreenState extends State<FirebaseBackendScreen> {
  final FirebaseBackendService _fbService = FirebaseBackendService.instance;

  bool _isLoginMode = true; // true: Đăng nhập, false: Đăng ký
  bool _isLoading = true;
  bool _obscurePassword = true;
  bool _showBackendConsole = false;

  // Controllers cho Form Đăng nhập / Đăng ký
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'khanh@pm2812.edu.vn',
  );
  final TextEditingController _passwordCtrl = TextEditingController(
    text: '123456',
  );
  final TextEditingController _nameCtrl = TextEditingController(
    text: 'Vũ Trọng Khánh',
  );
  final TextEditingController _studentIdCtrl = TextEditingController(
    text: 'PM28.12',
  );
  final TextEditingController _phoneCtrl = TextEditingController(
    text: '0988888888',
  );
  final TextEditingController _bioCtrl = TextEditingController(
    text: 'Anh Khánh đẹp trai nhất vũ trụ • Chuyên ngành Phần mềm PM28.12',
  );
  String _selectedAvatar = 'assets/images/purple_demon.png';

  List<FirebaseUserProfile> _allUsers = [];

  static const List<(String, String)> _avatarOptions = [
    ('Tím (Purple)', 'assets/images/purple_demon.png'),
    ('Đỏ (Crimson)', 'assets/images/crimson_demon.png'),
    ('Băng (Cyber)', 'assets/images/cyber_demon.png'),
    ('Lục (Emerald)', 'assets/images/emerald_demon.png'),
  ];

  @override
  void initState() {
    super.initState();
    _initFirebaseState();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _studentIdCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _initFirebaseState() async {
    setState(() => _isLoading = true);
    await _fbService.init();
    final users = await _fbService.getAllRegisteredUsers();
    if (!mounted) return;
    setState(() {
      _allUsers = users;
      _isLoading = false;
    });
  }

  Future<void> _handleAuthSubmit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLoginMode) {
        final profile = await _fbService.signIn(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
        );
        final users = await _fbService.getAllRegisteredUsers();
        if (!mounted) return;
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Đăng nhập Firebase thành công: Xin chào ${profile.displayName}!',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      } else {
        final profile = await _fbService.registerAccount(
          email: _emailCtrl.text,
          password: _passwordCtrl.text,
          displayName: _nameCtrl.text,
          studentId: _studentIdCtrl.text,
          phone: _phoneCtrl.text,
          bio: _bioCtrl.text,
          avatarUrl: _selectedAvatar,
        );
        final users = await _fbService.getAllRegisteredUsers();
        if (!mounted) return;
        setState(() {
          _allUsers = users;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🎉 Đăng ký tài khoản Firebase & tạo CSDL Profile thành công cho ${profile.displayName}!',
            ),
            backgroundColor: const Color(0xFF2563EB),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog(FirebaseUserProfile user) async {
    final nameCtrl = TextEditingController(text: user.displayName);
    final studentCtrl = TextEditingController(text: user.studentId);
    final phoneCtrl = TextEditingController(text: user.phone);
    final bioCtrl = TextEditingController(text: user.bio);
    String avatar = user.avatarUrl;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text(
                '✏️ Sửa Profile Người Dùng (Firebase CSDL)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                            width: 2,
                          ),
                        ),
                        child: Image.asset(
                          avatar,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Chọn Avatar đại diện:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _avatarOptions.map((opt) {
                        final selected = avatar == opt.$2;
                        return ChoiceChip(
                          label: Text(
                            opt.$1,
                            style: TextStyle(
                              fontSize: 11,
                              color: selected ? Colors.white : null,
                            ),
                          ),
                          selected: selected,
                          selectedColor: const Color(0xFFF59E0B),
                          onSelected: (_) => setDialogState(() => avatar = opt.$2),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Họ và tên (displayName)',
                        prefixIcon: Icon(Icons.badge_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: studentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Lớp / Mã SV (studentId)',
                        prefixIcon: Icon(Icons.school_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại (phone)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Giới thiệu bản thân (bio)',
                        prefixIcon: Icon(Icons.info_outline_rounded, size: 18),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await _fbService.updateProfile(
                      displayName: nameCtrl.text,
                      studentId: studentCtrl.text,
                      phone: phoneCtrl.text,
                      bio: bioCtrl.text,
                      avatarUrl: avatar,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _initFirebaseState();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '✅ Đã lưu Profile mới lên CSDL Firebase thành công!',
                        ),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_done_rounded, size: 18),
                  label: const Text('LƯU LÊN FIREBASE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            '🔒 Đổi Mật Khẩu Firebase Auth',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới (ít nhất 6 ký tự)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('HỦY'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _fbService.changePassword(
                    currentPassword: oldPassCtrl.text,
                    newPassword: newPassCtrl.text,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        '✅ Đã đổi mật khẩu trên Firebase Auth thành công!',
                      ),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '❌ ${e.toString().replaceFirst("Exception: ", "")}',
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              },
              child: const Text('CẬP NHẬT'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFirebaseConfigDialog() async {
    final projectCtrl = TextEditingController(text: _fbService.projectId);
    final dbUrlCtrl = TextEditingController(text: _fbService.databaseUrl);
    final apiKeyCtrl = TextEditingController(text: _fbService.apiKey);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text(
            '⚙️ Cấu hình Kết nối Firebase Backend',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mặc định hệ thống đã tích hợp sẵn CSDL Firebase Backend nội bộ. Nếu muốn kết nối thêm tới Project riêng trên console.firebase.google.com, anh có thể nhập Web API Key & Database URL dưới đây:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: projectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Firebase Project ID',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: dbUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Realtime Database / Firestore URL',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: apiKeyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Firebase Web API Key (Tùy chọn)',
                    hintText: 'AIzaSy...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ĐÓNG'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _fbService.saveFirebaseConfig(
                  apiKey: apiKeyCtrl.text,
                  projectId: projectCtrl.text,
                  databaseUrl: dbUrlCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('LƯU CẤU HÌNH'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = _fbService.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kỹ thuật 3: Firebase Auth & CSDL',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Đăng ký • Đăng nhập • Sửa Profile • Cloud DB (${_fbService.projectId})',
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Xem Nhật ký Gọi Firebase Backend',
            onPressed: () =>
                setState(() => _showBackendConsole = !_showBackendConsole),
            icon: Icon(
              Icons.terminal_rounded,
              color: _showBackendConsole
                  ? const Color(0xFFF59E0B)
                  : (isDark ? Colors.white70 : const Color(0xFF334155)),
            ),
          ),
          IconButton(
            tooltip: 'Cấu hình Firebase Project',
            onPressed: _showFirebaseConfigDialog,
            icon: const Icon(Icons.settings_ethernet_rounded),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Nhật ký gọi Backend Firebase (Terminal Console)
                  if (_showBackendConsole) _buildBackendConsole(),

                  // 2. Nếu đã đăng nhập -> Hiển thị Màn hình Profile & CSDL Cloud
                  //    Nếu chưa đăng nhập -> Hiển thị Form Đăng nhập / Đăng ký
                  if (currentUser != null)
                    _buildLoggedInProfileView(currentUser, isDark)
                  else
                    _buildAuthFormView(isDark),

                  const SizedBox(height: 18),

                  // 3. Bảng Danh sách Tài khoản trong CSDL Firebase (`users` collection)
                  _buildFirebaseUsersCollectionCard(isDark, currentUser),

                  const SizedBox(height: 16),

                  // 4. Cây CSDL Firebase Realtime Database (JSON Tree Explorer)
                  _buildFirebaseDatabaseTreeCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildBackendConsole() {
    return Container(
      height: 155,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_sync_rounded, color: Color(0xFFF59E0B), size: 16),
              SizedBox(width: 6),
              Text(
                'FIREBASE AUTH & REALTIME CSDL BACKEND LOGS',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _fbService.backendLogs.isEmpty
                ? const Text(
                    'Sẵn sàng nhận yêu cầu Đăng ký / Đăng nhập / Sửa Profile...',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  )
                : ListView.builder(
                    itemCount: _fbService.backendLogs.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          _fbService.backendLogs[idx],
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10.5,
                            color: Color(0xFFFDE68A),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GIAO DIỆN ĐĂNG NHẬP / ĐĂNG KÝ FIREBASE
  // ===========================================================================
  Widget _buildAuthFormView(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chuyển đổi Đăng Nhập / Đăng Ký
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _isLoginMode = true),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text(
                    'ĐĂNG NHẬP',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoginMode
                        ? const Color(0xFFF59E0B)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    foregroundColor: _isLoginMode
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    elevation: _isLoginMode ? 2 : 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() {
                    _isLoginMode = false;
                    if (_emailCtrl.text == 'khanh@pm2812.edu.vn') {
                      _emailCtrl.text =
                          'khanh_${DateTime.now().second}@pm2812.edu.vn';
                    }
                  }),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                  label: const Text(
                    'ĐĂNG KÝ MỚI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_isLoginMode
                        ? const Color(0xFF2563EB)
                        : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                    foregroundColor: !_isLoginMode
                        ? Colors.white
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    elevation: !_isLoginMode ? 2 : 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _isLoginMode
                ? '🔑 Đăng nhập vào Backend Firebase (POST /v1/accounts:signInWithPassword)'
                : '📝 Đăng ký tài khoản Firebase & khởi tạo hồ sơ CSDL (POST /v1/accounts:signUp)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email tài khoản Firebase',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu (tối thiểu 6 ký tự)',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),

          if (!_isLoginMode) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên (displayName)',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _studentIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lớp / MSSV',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại (phone)',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioCtrl,
              decoration: const InputDecoration(
                labelText: 'Giới thiệu Profile (bio)',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: _handleAuthSubmit,
              icon: Icon(
                _isLoginMode
                    ? Icons.login_rounded
                    : Icons.cloud_upload_rounded,
              ),
              label: Text(
                _isLoginMode
                    ? 'ĐĂNG NHẬP FIREBASE NGAY'
                    : 'TẠO TÀI KHOẢN & LƯU LÊN FIREBASE CSDL',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoginMode
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // GIAO DIỆN HỒ SƠ NGƯỜI DÙNG (PROFILE) & CSDL CLOUD SAU KHI ĐĂNG NHẬP
  // ===========================================================================
  Widget _buildLoggedInProfileView(FirebaseUserProfile user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981), width: 2),
                ),
                child: Image.asset(
                  user.avatarUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 34,
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
                        Flexible(
                          child: Text(
                            user.displayName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            user.studentId,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '📧 ${user.email}  •  📞 ${user.phone}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🔑 Firebase UID: ${user.uid}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '💬 Giới thiệu (Bio): ${user.bio}',
              style: const TextStyle(fontSize: 12.5, fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 12),

          // Thống kê dữ liệu người dùng trên CSDL Firebase
          Row(
            children: [
              _buildCloudStatBox(
                label: '🏆 Điểm Game',
                value: '${user.highScore}',
                color: const Color(0xFFF59E0B),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildCloudStatBox(
                label: '⭐ Bàn Max',
                value: 'Stage ${user.highestStage}/8',
                color: const Color(0xFF0284C7),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildCloudStatBox(
                label: '📝 Ghi chú Cloud',
                value: '${user.syncedNotesCount} mục',
                color: const Color(0xFF10B981),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Các nút thao tác Profile & Đồng bộ Backend
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(user),
                  icon: const Icon(Icons.edit_rounded, size: 17),
                  label: const Text(
                    'SỬA PROFILE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _fbService.syncSqliteDataToFirebase();
                    await _initFirebaseState();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '☁️ Đã đồng bộ Kỷ lục Game & Ghi chú từ SQLite lên CSDL Firebase!',
                        ),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  icon: const Icon(Icons.cloud_sync_rounded, size: 17),
                  label: const Text(
                    'ĐỒNG BỘ CLOUD',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showChangePasswordDialog,
                  icon: const Icon(Icons.password_rounded, size: 16),
                  label: const Text('Đổi Mật Khẩu', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                  ),
                  onPressed: () async {
                    await _fbService.signOut();
                    setState(() {});
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Đăng Xuất', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloudStatBox({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DANH SÁCH COLLECTION `users` TRÊN CSDL FIREBASE
  // ===========================================================================
  Widget _buildFirebaseUsersCollectionCard(
    bool isDark,
    FirebaseUserProfile? currentUser,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage_rounded, color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CSDL Firebase Collection: /users (${_allUsers.length} tài khoản)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Chạm vào tài khoản bất kỳ bên dưới để điền nhanh Email đăng nhập:',
            style: TextStyle(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          ..._allUsers.map((u) {
            final isCurrent = currentUser?.uid == u.uid;
            return InkWell(
              onTap: () {
                setState(() {
                  _isLoginMode = true;
                  _emailCtrl.text = u.email;
                  if (u.email == 'khanh@pm2812.edu.vn') {
                    _passwordCtrl.text = '123456';
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCurrent
                        ? const Color(0xFF10B981)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      u.avatarUrl,
                      width: 36,
                      height: 36,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.account_circle, size: 36),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${u.displayName} (${u.studentId})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            'Email: ${u.email} • SĐT: ${u.phone}',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ĐANG ONLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFirebaseDatabaseTreeCard() {
    final Map<String, dynamic> dbTree = {
      'users': {
        for (final u in _allUsers)
          u.uid: {
            'uid': u.uid,
            'email': u.email,
            'displayName': u.displayName,
            'studentId': u.studentId,
            'phone': u.phone,
            'bio': u.bio,
            'avatarUrl': u.avatarUrl,
            'highScore': u.highScore,
            'highestStage': u.highestStage,
            'syncedNotesCount': u.syncedNotesCount,
            'updatedAt': u.updatedAt,
          },
      },
    };
    final prettyJson = const JsonEncoder.withIndent('  ').convert(dbTree);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_tree_rounded,
                color: Color(0xFFF59E0B),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CÂY DỮ LIỆU FIREBASE REALTIME DATABASE (${_fbService.databaseUrl})',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 240),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                prettyJson,
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  color: Color(0xFFA7F3D0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

