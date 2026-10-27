import 'dart:async';
import 'package:dart_eval/dart_eval.dart';

class RunResult {
  final bool success;
  final List<String> logs;
  final String? errorMessage;
  final Duration executionTime;

  RunResult({
    required this.success,
    required this.logs,
    this.errorMessage,
    required this.executionTime,
  });
}

class DartRunnerService {
  /// Biên dịch và thực thi mã nguồn Dart do người dùng nhập vào
  static Future<RunResult> runCode(String sourceCode) async {
    final stopwatch = Stopwatch()..start();
    final logs = <String>[];
    String? errorMessage;
    bool success = true;

    // Chuẩn bị mã nguồn: nếu người dùng quên viết hàm main(), tự động bọc lại
    String executableCode = sourceCode.trim();
    if (!executableCode.contains('main(')) {
      executableCode = '''
void main() {
$executableCode
}
''';
    }

    await runZoned(
      () async {
        try {
          final compiler = Compiler();
          final program = compiler.compile({
            'user_workspace': {
              'main.dart': executableCode,
            }
          });

          final runtime = Runtime.ofProgram(program);
          runtime.executeLib('package:user_workspace/main.dart', 'main');
        } catch (e, stack) {
          success = false;
          errorMessage = e.toString();
          logs.add('❌ Lỗi thực thi: $e');
          // Không in full stack trace dài dòng để người dùng mobile dễ đọc
          final stackSummary = stack.toString().split('\n').take(3).join('\n');
          if (stackSummary.isNotEmpty) {
            logs.add('Chi tiết lỗi:\n$stackSummary');
          }
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (self, parent, zone, line) {
          logs.add(line);
        },
      ),
    );

    stopwatch.stop();

    return RunResult(
      success: success,
      logs: logs,
      errorMessage: errorMessage,
      executionTime: stopwatch.elapsed,
    );
  }
}
