import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class PrayerTimesProvider extends ChangeNotifier {
  PrayerTime? _todayPrayer;
  List<PrayerTime> _schedule = [];
  String _selectedCity = 'Jakarta';
  bool _loading = false;
  String? _error;

  PrayerTime? get todayPrayer => _todayPrayer;
  List<PrayerTime> get schedule => _schedule;
  String get selectedCity => _selectedCity;
  bool get loading => _loading;
  String? get error => _error;

  /// Muat kota tersimpan dari LocalStorage
  Future<void> loadSavedCity() async {
    final storage = LocalStorage();
    final savedCity = storage.getString(ApiConfig.storageKeyCity);
    if (savedCity != null &&
        ApiConfig.cityToShalatMapping.containsKey(savedCity)) {
      _selectedCity = savedCity;
      notifyListeners();
    }
  }

  Future<void> fetchPrayerTimes({String? city}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (city != null) {
        _selectedCity = city;
        await LocalStorage().saveCity(city);
        await _saveCityFile();
      }

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      List<Map<String, dynamic>> rawData = [];

      // Try loading from local storage first
      final localSchedule = await _loadLocalSchedule();
      if (localSchedule != null) {
        // Filter schedule from current month and next month
        rawData = localSchedule.where((item) {
          final date = item['tanggal_lengkap'] as String? ?? '';
          if (date.isEmpty) return false;
          final d = DateTime.tryParse(date);
          if (d == null) return false;
          // Include current month and next month
          final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
          final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
          return (d.year == currentYear && d.month == currentMonth) ||
              (d.year == nextYear && d.month == nextMonth);
        }).toList();
      }

      // If not enough local data, fetch from API
      if (rawData.length < 30) {
        try {
          final month1Data = await ApiService().getPrayerTimes(
            year: currentYear,
            month: currentMonth,
            city: _selectedCity,
          );

          final nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
          final nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
          final month2Data = await ApiService().getPrayerTimes(
            year: nextYear,
            month: nextMonth,
            city: _selectedCity,
          );

          rawData = [...month1Data, ...month2Data];

          // Save merged schedule to local storage for offline use
          await _saveLocalSchedule([...month1Data, ...month2Data]);
          await _saveCityFile();
        } catch (e) {
          // If API fails but we have local data, use it
          if (rawData.isEmpty) rethrow;
        }
      }

      final dayNames = [
        '',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final parsed = <PrayerTime>[];

      for (final item in rawData) {
        final tanggalLengkap = item['tanggal_lengkap'] ?? '';
        if (tanggalLengkap.isEmpty) continue;

        final itemDate = DateTime.tryParse(tanggalLengkap);
        if (itemDate == null) continue;

        final hari = item['hari'] as String? ?? dayNames[itemDate.weekday];
        final readable =
            '$hari, ${itemDate.day} ${monthNames[itemDate.month]} ${itemDate.year}';

        parsed.add(
          PrayerTime(
            imsak: item['imsak'] as String? ?? '--:--',
            subuh: item['subuh'] as String? ?? '--:--',
            dzuhur: item['dzuhur'] as String? ?? '--:--',
            ashar: item['ashar'] as String? ?? '--:--',
            maghrib: item['maghrib'] as String? ?? '--:--',
            isya: item['isya'] as String? ?? '--:--',
            date: readable,
            isoDate: tanggalLengkap,
          ),
        );
      }

      _schedule = parsed;

      // Set today's prayer
      final today = DateTime.now();
      _todayPrayer = parsed.where((p) {
        try {
          final pDate = DateTime.parse(p.isoDate);
          return pDate.year == today.year &&
              pDate.month == today.month &&
              pDate.day == today.day;
        } catch (_) {
          return false;
        }
      }).firstOrNull;
    } catch (e) {
      _error = e.toString();
      // Try to load from local storage as last resort
      if (_schedule.isEmpty) {
        await _loadFromLocalFallback();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Load jadwal dari file lokal (background service juga menyimpan)
  Future<List<Map<String, dynamic>>?> _loadLocalSchedule() async {
    try {
      final dir = await _getStorageDir();
      final file = File('${dir.path}/prayer_schedule.json');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final data = jsonDecode(raw) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return null;
    }
  }

  /// Save selected city to file for background service to read
  Future<void> _saveCityFile() async {
    try {
      final dir = await _getStorageDir();
      await File(
        '${dir.path}/selected_city.json',
      ).writeAsString(jsonEncode({'city': _selectedCity}));
    } catch (_) {}
  }

  /// Save jadwal ke file lokal untuk offline
  Future<void> _saveLocalSchedule(List<Map<String, dynamic>> newData) async {
    try {
      final dir = await _getStorageDir();
      final file = File('${dir.path}/prayer_schedule.json');

      // Merge with existing
      List<Map<String, dynamic>> existing = [];
      if (await file.exists()) {
        final raw = await file.readAsString();
        existing = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      }

      final existingDates = existing.map((s) => s['tanggal_lengkap']).toSet();
      for (final item in newData) {
        if (!existingDates.contains(item['tanggal_lengkap'])) {
          existing.add(item);
        }
      }

      await file.writeAsString(jsonEncode(existing));
    } catch (_) {}
  }

  /// Fallback: load dari local saat API gagal total
  Future<void> _loadFromLocalFallback() async {
    try {
      final localData = await _loadLocalSchedule();
      if (localData == null || localData.isEmpty) return;

      final dayNames = [
        '',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu',
        'Minggu',
      ];
      final monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];

      final parsed = <PrayerTime>[];
      final today = DateTime.now();

      for (final item in localData) {
        final tanggalLengkap = item['tanggal_lengkap'] ?? '';
        if (tanggalLengkap.isEmpty) continue;
        final itemDate = DateTime.tryParse(tanggalLengkap);
        if (itemDate == null) continue;

        final hari = item['hari'] as String? ?? dayNames[itemDate.weekday];
        final readable =
            '$hari, ${itemDate.day} ${monthNames[itemDate.month]} ${itemDate.year}';

        parsed.add(
          PrayerTime(
            imsak: item['imsak'] as String? ?? '--:--',
            subuh: item['subuh'] as String? ?? '--:--',
            dzuhur: item['dzuhur'] as String? ?? '--:--',
            ashar: item['ashar'] as String? ?? '--:--',
            maghrib: item['maghrib'] as String? ?? '--:--',
            isya: item['isya'] as String? ?? '--:--',
            date: readable,
            isoDate: tanggalLengkap,
          ),
        );
      }

      _schedule = parsed;
      _todayPrayer = parsed.where((p) {
        try {
          final pDate = DateTime.parse(p.isoDate);
          return pDate.year == today.year &&
              pDate.month == today.month &&
              pDate.day == today.day;
        } catch (_) {
          return false;
        }
      }).firstOrNull;

      if (_todayPrayer != null) {
        _error = null; // Clear error since we have data
      }
    } catch (_) {}
  }

  Future<Directory> _getStorageDir() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocDir.path}/umma_data');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Get up to 30 upcoming schedules
  List<PrayerTime> getUpcomingSchedule() {
    final today = DateTime.now();
    return _schedule.where((p) {
      try {
        final pDate = DateTime.parse(p.isoDate);
        return pDate.isAfter(today) || pDate.isAtSameMomentAs(today);
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
