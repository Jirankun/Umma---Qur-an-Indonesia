import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../config/api_config.dart';
import '../services/local_storage.dart';

class TasbihProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _count = 0;
  bool _isCompleted = false;
  bool _soundEnabled = true;

  int get currentIndex => _currentIndex;
  int get count => _count;
  bool get isCompleted => _isCompleted;
  bool get soundEnabled => _soundEnabled;

  static const List<Map<String, dynamic>> dzikirPresets = [
    {
      'id': 1,
      'title': 'Tasbih',
      'arabic': 'سُبْحَانَ اللَّهِ',
      'latin': 'Subhanallah',
      'target': 33,
    },
    {
      'id': 2,
      'title': 'Tahmid',
      'arabic': 'الْحَمْدُ لِلَّهِ',
      'latin': 'Alhamdulillah',
      'target': 33,
    },
    {
      'id': 3,
      'title': 'Takbir',
      'arabic': 'اللّهُ أَكْبَرُ',
      'latin': 'Allahu Akbar',
      'target': 33,
    },
    {
      'id': 4,
      'title': 'Penutup',
      'arabic':
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'latin':
          'Laa ilaha illallah wahdahu laa syarika lah, lahul mulku wa lahul hamdu wa huwa \'ala kulli syai-in qadir',
      'target': 1,
    },
  ];

  Map<String, dynamic> get currentDzikir => dzikirPresets[_currentIndex];
  double get progress {
    final target = (currentDzikir['target'] as int).toDouble();
    if (target <= 0) return 1.0;
    return min(_count / target, 1.0);
  }

  bool get isLastDzikir => _currentIndex == dzikirPresets.length - 1;

  /// Increment and auto-advance to next dzikir when target reached
  bool incrementAndAutoAdvance() {
    if (_isCompleted) return true;

    _count++;

    final target = currentDzikir['target'] as int;
    if (_count >= target) {
      // Mark current as completed
      _isCompleted = true;

      // Auto-advance to next dzikir if not the last one
      if (!isLastDzikir) {
        _currentIndex++;
        _count = 0;
        _isCompleted = false;
      }

      notifyListeners();
      saveSettings();
      return true; // Target reached
    }

    notifyListeners();
    return false; // Still counting
  }

  void reset() {
    _count = 0;
    _isCompleted = false;
    notifyListeners();
    saveSettings();
  }

  void changeDzikir(int direction) {
    int newIndex = (_currentIndex + direction) % dzikirPresets.length;
    if (newIndex < 0) newIndex = dzikirPresets.length - 1;
    _currentIndex = newIndex;
    reset(); // reset() already calls saveSettings()
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
    saveSettings();
  }

  // ─── PERSISTENCE ──────────────────────────────────────────────
  /// Save current tasbih state to local storage
  Future<void> saveSettings() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyTasbih, {
      'currentIndex': _currentIndex,
      'count': _count,
      'isCompleted': _isCompleted,
      'soundEnabled': _soundEnabled,
    });
  }

  /// Load saved tasbih state from local storage
  Future<void> loadSettings() async {
    final data = await LocalStorage().getJson(ApiConfig.storageKeyTasbih);
    if (data is Map) {
      _currentIndex = (data['currentIndex'] as num?)?.toInt() ?? 0;
      _count = (data['count'] as num?)?.toInt() ?? 0;
      _isCompleted = (data['isCompleted'] as bool?) ?? false;
      _soundEnabled = (data['soundEnabled'] as bool?) ?? true;
      notifyListeners();
    }
  }
}
