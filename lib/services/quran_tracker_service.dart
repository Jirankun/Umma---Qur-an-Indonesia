import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Quran reading tracker — track reading duration per day
class QuranTrackerService {
  static final QuranTrackerService _instance = QuranTrackerService._internal();
  factory QuranTrackerService() => _instance;
  QuranTrackerService._internal();

  // ─── Storage helpers ─────────────────────────────────────

  Future<File> _getStorageFile(String key) async {
    final dir = await getApplicationDocumentsDirectory();
    final ummaDir = Directory('${dir.path}/umma_data');
    if (!await ummaDir.exists()) await ummaDir.create(recursive: true);
    return File('${ummaDir.path}/$key.json');
  }

  Future<Map<String, dynamic>> _loadJson(String key) async {
    try {
      final file = await _getStorageFile(key);
      if (await file.exists()) {
        return jsonDecode(await file.readAsString());
      }
    } catch (_) {}
    return {};
  }

  Future<void> _saveJson(String key, Map<String, dynamic> data) async {
    try {
      final file = await _getStorageFile(key);
      await file.writeAsString(jsonEncode(data));
    } catch (_) {}
  }

  // ─── Reading History ─────────────────────────────────────

  static const String _historyKey = 'quran_reading_history';
  static const int totalQuranVerses = 6236;

  /// Add reading duration for a specific date
  Future<void> addReadingDuration(String date, int seconds) async {
    final data = await _loadJson(_historyKey);
    final current = (data[date] ?? 0) as int;
    data[date] = current + seconds;
    await _saveJson(_historyKey, data);
  }

  /// Get reading history (date -> seconds)
  Future<Map<String, int>> getReadingHistory() async {
    final data = await _loadJson(_historyKey);
    return data.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Get total reading time for a date range
  Future<int> getTotalReadingDuration(int daysBack) async {
    final history = await getReadingHistory();
    final today = DateTime.now();
    int total = 0;
    for (int i = 0; i < daysBack; i++) {
      final d = DateTime(today.year, today.month, today.day - i);
      final dateStr =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      total += history[dateStr] ?? 0;
    }
    return total;
  }

  // ─── Khatam Plan ─────────────────────────────────────────

  static const String _khatamKey = 'quran_khatam_plan';

  Future<Map<String, dynamic>?> getKhatamPlan() async {
    final data = await _loadJson(_khatamKey);
    return data.isNotEmpty ? data : null;
  }

  Future<void> saveKhatamPlan(Map<String, dynamic> plan) async {
    await _saveJson(_khatamKey, plan);
  }

  Future<void> clearKhatamPlan() async {
    try {
      final file = await _getStorageFile(_khatamKey);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ─── Calculate absolute ayah number ──────────────────────

  /// Calculate absolute ayah number across all surahs
  static int calculateAbsoluteAyah(int surahId, int ayahNumber) {
    // Total ayah per surah (114 surah)
    const List<int> ayahCounts = [
      7,
      286,
      200,
      176,
      120,
      165,
      206,
      75,
      129,
      109,
      123,
      111,
      43,
      52,
      99,
      128,
      111,
      110,
      98,
      135,
      112,
      78,
      118,
      64,
      77,
      227,
      93,
      88,
      69,
      60,
      34,
      30,
      73,
      54,
      45,
      83,
      182,
      88,
      75,
      85,
      54,
      53,
      89,
      59,
      37,
      35,
      38,
      29,
      18,
      45,
      60,
      49,
      62,
      55,
      78,
      96,
      29,
      22,
      24,
      13,
      14,
      11,
      11,
      18,
      12,
      12,
      30,
      52,
      52,
      44,
      28,
      28,
      20,
      56,
      40,
      31,
      50,
      40,
      46,
      42,
      29,
      19,
      36,
      25,
      22,
      17,
      19,
      26,
      30,
      20,
      15,
      21,
      11,
      8,
      8,
      19,
      5,
      8,
      8,
      11,
      11,
      8,
      3,
      9,
      5,
      4,
      7,
      3,
      6,
      3,
      5,
      4,
      5,
      6,
    ];

    int total = 0;
    for (int i = 0; i < surahId - 1 && i < ayahCounts.length; i++) {
      total += ayahCounts[i];
    }
    total += ayahNumber;
    return total;
  }

  // ─── Format helpers ──────────────────────────────────────

  static String formatDuration(int seconds) {
    if (seconds < 60) return '$seconds detik';
    if (seconds < 3600) {
      final m = seconds ~/ 60;
      return '$m menit';
    }
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '$h jam $m menit';
  }
}
