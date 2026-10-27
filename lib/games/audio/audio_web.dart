import 'dart:js_interop';

@JS('playFlappySound')
external void _playFlappySound(JSString sound);

void playPlatformSound(String sound) {
  try {
    _playFlappySound(sound.toJS);
  } catch (_) {}
}
