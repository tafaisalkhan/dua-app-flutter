import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  static String? _currentPath;
  static String? get currentPath => _currentPath;

  static Future<void> play(String assetPath) async {
    try {
      if (_currentPath == assetPath && isPlaying.value) {
        await stop();
        return;
      }
      await stop();
      _currentPath = assetPath;
      isPlaying.value = true;
      await _player.play(AssetSource(assetPath));
      _player.onPlayerComplete.listen((_) {
        isPlaying.value = false;
        _currentPath = null;
      });
    } catch (e) {
      debugPrint('Audio play error: $e');
      isPlaying.value = false;
      _currentPath = null;
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      isPlaying.value = false;
      _currentPath = null;
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
  }

  static Future<void> dispose() async {
    await _player.dispose();
  }
}
