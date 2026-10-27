import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/ide_models.dart';
import '../services/dart_runner_service.dart';

class CodeEditorScreen extends StatefulWidget {
  final UserProject project;
  final UserFile file;
  final Function(String newContent) onSave;

  const CodeEditorScreen({
    super.key,
    required this.project,
    required this.file,
    required this.onSave,
  });

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  late TextEditingController _codeController;
  late ScrollController _scrollController;
  late ScrollController _lineNumScrollController;

  double _fontSize = 14.5;
  bool _isDirty = false;
  bool _isRunning = false;

  // Thanh phím tắt ký tự lập trình cho mobile
  final List<Map<String, String>> _quickSymbols = [
    {'label': '⌨ Ẩn phím', 'insert': '__HIDE_KEYBOARD__'},
    {'label': 'Tab', 'insert': '  '},
    {'label': '{ }', 'insert': '{\n  \n}'},
    {'label': '( )', 'insert': '()'},
    {'label': '[ ]', 'insert': '[]'},
    {'label': ';', 'insert': ';'},
    {'label': '" "', 'insert': '""'},
    {'label': "' '", 'insert': "''"},
    {'label': '=>', 'insert': ' => '},
    {'label': '=', 'insert': ' = '},
    {'label': '==', 'insert': ' == '},
    {'label': 'print', 'insert': "print('');"},
    {'label': 'var', 'insert': 'var '},
    {'label': 'int', 'insert': 'int '},
    {'label': 'String', 'insert': 'String '},
    {'label': 'for', 'insert': 'for (var i = 0; i < 10; i++) {\n  \n}'},
    {'label': 'if', 'insert': 'if () {\n  \n}'},
    {'label': '+', 'insert': ' + '},
    {'label': '-', 'insert': ' - '},
    {'label': '*', 'insert': ' * '},
    {'label': '/', 'insert': ' / '},
    {'label': '\$', 'insert': '\$'},
  ];

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.file.content);
    _scrollController = ScrollController();
    _lineNumScrollController = ScrollController();

    // Đồng bộ cuộn giữa số dòng và nội dung code
    _scrollController.addListener(() {
      if (_lineNumScrollController.hasClients) {
        _lineNumScrollController.jumpTo(_scrollController.offset);
      }
    });

    _codeController.addListener(() {
      if (!_isDirty && _codeController.text != widget.file.content) {
        setState(() => _isDirty = true);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scrollController.dispose();
    _lineNumScrollController.dispose();
    super.dispose();
  }

  void _saveFile() {
    widget.onSave(_codeController.text);
    setState(() => _isDirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Đã lưu file thành công!', style: TextStyle(fontFamily: 'Times New Roman')),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _insertSymbol(String textToInsert) {
    if (textToInsert == '__HIDE_KEYBOARD__') {
      FocusScope.of(context).unfocus();
      return;
    }

    final text = _codeController.text;
    final selection = _codeController.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0) {
      start = text.length;
      end = text.length;
    }

    final newText = text.replaceRange(start, end, textToInsert);
    int newCursorPosition = start + textToInsert.length;
    
    // Đặt con trỏ thông minh vào giữa ngoặc hoặc nháy
    if (textToInsert == '()' || textToInsert == '[]' || textToInsert == '""' || textToInsert == "''") {
      newCursorPosition = start + 1;
    } else if (textToInsert == '{\n  \n}') {
      newCursorPosition = start + 4;
    } else if (textToInsert == "print('');") {
      newCursorPosition = start + 7;
    }

    _codeController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }

  Future<void> _runCode() async {
    // Ẩn bàn phím trước khi chạy
    FocusScope.of(context).unfocus();
    // Tự động lưu trước khi chạy
    _saveFile();

    setState(() {
      _isRunning = true;
    });

    final result = await DartRunnerService.runCode(_codeController.text);

    setState(() {
      _isRunning = false;
    });

    if (!mounted) return;
    _showTerminalBottomSheet(result);
  }

  void _showTerminalBottomSheet(RunResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header của Terminal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: result.success
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : const Color(0xFFEF4444).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          result.success ? Icons.terminal_rounded : Icons.error_outline_rounded,
                          size: 18,
                          color: result.success ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.success ? 'Terminal - Đã Chạy Xong' : 'Terminal - Có Lỗi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Times New Roman',
                            ),
                          ),
                          Text(
                            'Thời gian: ${result.executionTime.inMilliseconds}ms | ${widget.file.name}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11, fontFamily: 'Times New Roman'),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Sao chép kết quả',
                        icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 19),
                        onPressed: () {
                          final text = result.logs.join('\n');
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã chép kết quả Terminal!')),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Nội dung Terminal
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF090D16),
                    padding: const EdgeInsets.all(14),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: SelectableText(
                        result.logs.isEmpty
                            ? '(Chương trình không in ra kết quả nào)'
                            : result.logs.join('\n'),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13.5,
                          height: 1.45,
                          letterSpacing: 0,
                          color: result.success ? const Color(0xFF38BDF8) : const Color(0xFFFCA5A5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineCount = '\n'.allMatches(_codeController.text).length + 1;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    widget.file.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Times New Roman'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isDirty) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            Text(
              '${widget.project.name} • $lineCount dòng',
              style: TextStyle(
                fontSize: 11,
                fontFamily: 'Times New Roman',
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
        actions: [
          // Nút ẩn phím ảo
          IconButton(
            tooltip: 'Ẩn bàn phím',
            icon: const Icon(Icons.keyboard_hide_rounded, size: 20),
            onPressed: () => FocusScope.of(context).unfocus(),
          ),
          // Nút giảm cỡ chữ
          IconButton(
            tooltip: 'Giảm cỡ chữ (A-)',
            icon: const Icon(Icons.text_decrease_rounded, size: 19),
            onPressed: () {
              if (_fontSize > 11) setState(() => _fontSize -= 1.0);
            },
          ),
          // Nút tăng cỡ chữ
          IconButton(
            tooltip: 'Tăng cỡ chữ (A+)',
            icon: const Icon(Icons.text_increase_rounded, size: 21),
            onPressed: () {
              if (_fontSize < 24) setState(() => _fontSize += 1.0);
            },
          ),
          // Nút lưu
          IconButton(
            tooltip: 'Lưu file',
            icon: Icon(
              Icons.save_rounded,
              color: _isDirty ? const Color(0xFFF59E0B) : (isDark ? Colors.white70 : Colors.black87),
            ),
            onPressed: _saveFile,
          ),
          const SizedBox(width: 4),
          // Nút Chạy Code đặt ngay trên AppBar cực kỳ gọn gàng
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 10, bottom: 10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                minimumSize: const Size(0, 34),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 1,
              ),
              onPressed: _isRunning ? null : _runCode,
              icon: _isRunning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow_rounded, size: 20),
              label: Text(
                _isRunning ? '...' : 'CHẠY',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Khu vực Soạn Thảo Code + Số Dòng
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cột số dòng
                Container(
                  width: 44,
                  color: isDark ? const Color(0xFF131C2E) : const Color(0xFFEDF2F7),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    controller: _lineNumScrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      children: List.generate(
                        lineCount,
                        (index) => Container(
                          height: _fontSize * 1.5,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${index + 1}',
                            strutStyle: StrutStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize,
                              height: 1.5,
                              forceStrutHeight: true,
                            ),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize * 0.85,
                              letterSpacing: 0,
                              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Vùng nhập code có cuộn ngang không bị nhảy dòng
                Expanded(
                  child: Container(
                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: ((_codeController.text.split('\n').fold<int>(0, (prev, line) => line.length > prev ? line.length : prev) + 10) * (_fontSize * 0.75)).clamp(MediaQuery.of(context).size.width - 50, 6000.0),
                          child: TextField(
                            controller: _codeController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            strutStyle: StrutStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize,
                              height: 1.5,
                              forceStrutHeight: true,
                            ),
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: _fontSize,
                              height: 1.5,
                              letterSpacing: 0,
                              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thanh bàn phím gõ nhanh ký tự lập trình
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 0.8,
                ),
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              itemCount: _quickSymbols.length,
              itemBuilder: (context, index) {
                final symbol = _quickSymbols[index];
                final isHideBtn = symbol['insert'] == '__HIDE_KEYBOARD__';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Material(
                    color: isHideBtn
                        ? (isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0))
                        : (isDark ? const Color(0xFF334155) : Colors.white),
                    borderRadius: BorderRadius.circular(6),
                    elevation: 1,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _insertSymbol(symbol['insert']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        alignment: Alignment.center,
                        child: Text(
                          symbol['label']!,
                          style: TextStyle(
                            fontFamily: isHideBtn ? 'Times New Roman' : 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isHideBtn
                                ? (isDark ? Colors.white70 : const Color(0xFF475569))
                                : (isDark ? const Color(0xFF67E8F9) : const Color(0xFF2563EB)),
                          ),
                        ),
                      ),
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
}
