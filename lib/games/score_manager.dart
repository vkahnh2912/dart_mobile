import 'package:shared_preferences/shared_preferences.dart';

class ScoreManager {
  static const String _keyBestScore = 'flappy_fly_best_score';

  int currentScore = 0;
  int bestScore = 0;
  bool isNewHighScore = false;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bestScore = prefs.getInt(_keyBestScore) ?? 0;
    } catch (_) {}
  }

  void reset() {
    currentScore = 0;
    isNewHighScore = false;
  }

  void addPoint() {
    currentScore++;
    if (currentScore > bestScore) {
      bestScore = currentScore;
      isNewHighScore = true;
      _saveBest();
    }
  }

  Future<void> _saveBest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyBestScore, bestScore);
    } catch (_) {}
  }

  String getMedal() {
    if (currentScore >= 40) return 'PLATINUM';
    if (currentScore >= 25) return 'GOLD';
    if (currentScore >= 10) return 'SILVER';
    if (currentScore >= 5) return 'BRONZE';
    return 'NONE';
  }
}
