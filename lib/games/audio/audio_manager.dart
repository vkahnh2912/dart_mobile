import 'package:flutter/services.dart';
import 'audio_stub.dart' if (dart.library.js_interop) 'audio_web.dart';

class AudioManager {
  static void playFlap() {
    playPlatformSound('flap');
    HapticFeedback.lightImpact();
  }

  static void playPoint() {
    playPlatformSound('point');
    HapticFeedback.mediumImpact();
  }

  static void playHit() {
    playPlatformSound('hit');
    HapticFeedback.heavyImpact();
  }

  static void playDie() {
    playPlatformSound('die');
    HapticFeedback.heavyImpact();
  }
}
