import 'package:flutter/cupertino.dart';
import '../models/models.dart';
import '../services/local_storage.dart';
import '../utils/date_helper.dart';

class TrackerProvider extends ChangeNotifier {
  Map<String, DailyTracker> _trackers = {};
  bool _loading = false;

  Map<String, DailyTracker> get trackers => _trackers;
  bool get loading => _loading;

  DailyTracker? getTracker(String date) => _trackers[date];

  Future<void> loadTrackers() async {
    _loading = true;
    notifyListeners();

    try {
      final storage = LocalStorage();
      final data = await storage.getTracker();
      if (data != null) {
        _trackers = data.map(
          (key, value) => MapEntry(key, DailyTracker.fromJson(value)),
        );
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTracker(
    String date,
    String key, {
    bool isCustom = false,
  }) async {
    final tracker = _trackers[date] ?? DailyTracker(date: date);

    if (isCustom) {
      tracker.customProgress[key] = !(tracker.customProgress[key] ?? false);
    } else {
      switch (key) {
        case 'isPuasa':
          tracker.isPuasa = !tracker.isPuasa;
          break;
        case 'subuh':
          tracker.subuh = !tracker.subuh;
          break;
        case 'dzuhur':
          tracker.dzuhur = !tracker.dzuhur;
          break;
        case 'ashar':
          tracker.ashar = !tracker.ashar;
          break;
        case 'maghrib':
          tracker.maghrib = !tracker.maghrib;
          break;
        case 'isya':
          tracker.isya = !tracker.isya;
          break;
        case 'tarawih':
          tracker.tarawih = !tracker.tarawih;
          break;
        case 'quran':
          tracker.quran = !tracker.quran;
          break;
        case 'sedekah':
          tracker.sedekah = !tracker.sedekah;
          break;
      }
    }

    _trackers[date] = tracker;
    await _saveTrackers();
    notifyListeners();
  }

  /// Get today's tracker summary
  TrackerSummary getTrackerSummary() {
    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayTracker = _trackers[dateStr];

    if (todayTracker == null) {
      // Total items: 8 default + 1 tarawih (only if Ramadhan)
      final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
      final totalItems = isRamadhan ? 9 : 8;
      return TrackerSummary(total: totalItems, completed: 0, percentage: 0);
    }

    return TrackerSummary(
      total: todayTracker.totalCount,
      completed: todayTracker.completedCount,
      percentage: todayTracker.percentage,
    );
  }

  /// Get tracker stats SELAMA Ramadhan (bukan semua data!)
  Map<String, int> getRamadhanStats() {
    int totalDays = 0;
    int perfectDays = 0;
    int totalCompleted = 0;

    _trackers.forEach((date, tracker) {
      // Hanya hitung tracker yang tanggalnya di bulan Ramadhan
      final d = DateTime.tryParse(date);
      if (d == null) return;
      if (!DateHelper.isCurrentlyRamadhan(d)) return;

      totalDays++;
      totalCompleted += tracker.completedCount;
      if (tracker.isComplete) perfectDays++;
    });

    return {
      'totalDays': totalDays,
      'perfectDays': perfectDays,
      'totalCompleted': totalCompleted,
    };
  }

  Future<void> _saveTrackers() async {
    final data = _trackers.map((key, value) => MapEntry(key, value.toJson()));
    await LocalStorage().saveTracker(data as Map<String, dynamic>);
  }
}

class TrackerSummary {
  final int total;
  final int completed;
  final int percentage;

  TrackerSummary({
    required this.total,
    required this.completed,
    required this.percentage,
  });
}
