// ignore_for_file: avoid_print

import 'dart:io';
import 'lib/lessons_registry.dart';

void _printHeader(String title) {
  print('\n' + '=' * 70);
  print('  $title');
  print('=' * 70);
}

void _runSingleLesson(LessonItem lesson) {
  _printHeader('[BÀI HỌC] ${lesson.exampleTitle}');
  print('📁 File: ${lesson.filePath}');
  print('📝 Tóm tắt: ${lesson.summary}');
  print('-' * 70);
  print('--- KẾT QUẢ THỰC THI (OUTPUT) ---');

  try {
    lesson.run();
  } catch (e, stack) {
    print('❌ LỖI KHI CHẠY: $e');
    print(stack);
  }

  print('-' * 70);
  print('✅ Thực thi hoàn tất bài: ${lesson.exampleTitle}');
}

void _runAllAutomatedLessons() {
  _printHeader('CHẠY TOÀN BỘ CÁC BÀI THỰC HÀNH TỰ ĐỘNG (VIDEO 10 -> 40)');
  int count = 0;
  for (final lesson in allLessons) {
    if (!lesson.requiresInput) {
      _runSingleLesson(lesson);
      count++;
    }
  }
  _printHeader('ĐÃ HOÀN THÀNH TẤT CẢ $count BÀI TỰ ĐỘNG!');
  print('Lưu ý: Bài 10 (Giải phương trình bậc 2) có thể chạy tương tác trong menu.');
}

void _runByVideoNumber(int videoNum) {
  final videoGroup = allVideos.firstWhere(
    (v) => v.videoNumber == videoNum,
    orElse: () => const VideoGroup(videoNumber: -1, videoTitle: '', folderName: '', youtubeUrl: ''),
  );
  if (videoGroup.videoNumber == -1) {
    print('Không tìm thấy Video $videoNum trong danh sách (Video 10 đến 40)!');
    return;
  }

  final videoLessons = allLessons.where((l) => l.videoNumber == videoNum).toList();
  _printHeader('VIDEO ${videoNum.toString().padLeft(2, '0')}: ${videoGroup.videoTitle}');
  print('📁 Thư mục: ${videoGroup.folderName}');
  print('🔗 Link YouTube: ${videoGroup.youtubeUrl}');
  print('Số lượng bài ví dụ: ${videoLessons.length}\n');

  for (final lesson in videoLessons) {
    if (lesson.requiresInput) {
      print('\n[BÀI TƯƠNG TÁC] ${lesson.exampleTitle} (Cần nhập bàn phím)');
      stdout.write('👉 Bạn có muốn chạy bài này không? (y/n): ');
      final ans = stdin.readLineSync()?.trim().toLowerCase();
      if (ans == 'y' || ans == 'yes') {
        _runSingleLesson(lesson);
      }
    } else {
      _runSingleLesson(lesson);
    }
  }
}

void runAllLessons() {
  while (true) {
    print('\n╔══════════════════════════════════════════════════════════════════════════╗');
    print('║     KHÓA HỌC DART & FLUTTER TITV - TỪ VIDEO 10 ĐẾN VIDEO 40 (31 VIDEOS)   ║');
    print('║            DÀNH RIÊNG CHO: ANH KHÁNH ĐẸP TRAI NHẤT VŨ TRỤ 🚀             ║');
    print('╠══════════════════════════════════════════════════════════════════════════╣');
    print('║  [1] Chạy toàn bộ các bài thực hành tự động (Video 10 -> 40)            ║');
    print('║  [2] Chạy bài tương tác bàn phím (Video 10: Giải PT bậc 2)              ║');
    print('║  [3] Chọn chạy theo số Video (Video 10 đến Video 40)                     ║');
    print('║  [4] Danh sách chi tiết toàn bộ ${allLessons.length} bài ví dụ để chọn chạy                 ║');
    print('║  [0] Thoát                                                               ║');
    print('╚══════════════════════════════════════════════════════════════════════════╝');
    stdout.write('👉 Chọn chức năng (0-4): ');

    final input = stdin.readLineSync()?.trim();
    if (input == null || input == '0') {
      print('Tạm biệt anh Khánh đẹp trai nhất vũ trụ! Chúc anh học tập và code thật đỉnh!');
      break;
    }

    switch (input) {
      case '1':
        _runAllAutomatedLessons();
        break;

      case '2':
        print('\n--- BÀI TƯƠNG TÁC GIẢI PHƯƠNG TRÌNH BẬC 2 (VIDEO 10) ---');
        final l = allLessons.firstWhere((x) => x.id == 10);
        _runSingleLesson(l);
        break;

      case '3':
        print('\n--- DANH SÁCH CÁC VIDEO (BÀI 10 ĐẾN BÀI 40) ---');
        for (final v in allVideos) {
          final fileCount = allLessons.where((l) => l.videoNumber == v.videoNumber).length;
          print('  [Video ${v.videoNumber.toString().padLeft(2, '0')}] ${v.videoTitle} ($fileCount ví dụ)');
        }
        stdout.write('👉 Nhập số Video muốn chạy (10 - 40): ');
        final vNum = int.tryParse(stdin.readLineSync()?.trim() ?? '');
        if (vNum != null && vNum >= 10 && vNum <= 40) {
          _runByVideoNumber(vNum);
        } else {
          print('Số Video không hợp lệ! Vui lòng nhập từ 10 đến 40.');
        }
        break;

      case '4':
        print('\n--- DANH SÁCH CHI TIẾT TOÀN BỘ ${allLessons.length} VÍ DỤ (VIDEO 10 - 40) ---');
        for (int i = 0; i < allLessons.length; i++) {
          final l = allLessons[i];
          final note = l.requiresInput ? ' [Nhập phím]' : '';
          print('  [${(i + 1).toString().padLeft(2, ' ')}] [Video ${l.videoNumber.toString().padLeft(2, '0')}] ${l.exampleTitle}$note');
        }
        stdout.write('👉 Nhập số thứ tự bài muốn chạy (1-${allLessons.length}): ');
        final choiceIdx = int.tryParse(stdin.readLineSync()?.trim() ?? '');
        if (choiceIdx != null && choiceIdx >= 1 && choiceIdx <= allLessons.length) {
          final l = allLessons[choiceIdx - 1];
          _runSingleLesson(l);
        } else {
          print('Số thứ tự không hợp lệ!');
        }
        break;

      default:
        print('Lựa chọn không hợp lệ. Vui lòng chọn từ 0 đến 4.');
    }

    stdout.write('\nNhấn Enter để tiếp tục...');
    stdin.readLineSync();
  }
}

void main() {
  runAllLessons();
}
