import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../config/ai_config.dart';

/// Local storage service.
/// - Data kecil (theme, city) → SharedPreferences
/// - Data besar (jurnal, hadits, bookmark, dll) → File JSON di appDocDir
class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  SharedPreferences? _prefs;
  Directory? _jsonDir;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Initialize JSON storage directory in appDocDir
    final appDocDir = await getApplicationDocumentsDirectory();
    _jsonDir = Directory('${appDocDir.path}/umma_data');
    if (!await _jsonDir!.exists()) {
      await _jsonDir!.create(recursive: true);
    }
  }

  /// Collect ALL export data — shared between QR sync & file backup
  Future<Map<String, dynamic>> collectAllExportData() async {
    final exportData = <String, dynamic>{};

    // 1. Collect JSON-based data from all export keys
    for (final key in ApiConfig.exportDataKeys) {
      final data = await getJson(key);
      if (data != null) exportData[key] = data;
    }

    // 2. Also include plain-string keys (theme, city, groqApiKey)
    for (final key in ApiConfig.stringStorageKeys) {
      final val = getString(key);
      if (val != null && val.isNotEmpty) exportData[key] = val;
    }    // 3. Background sound preference (stored in SharedPrefs, not in ApiConfig)
    try {
      final bgSound = getBool('umma_bg_sound_enabled');
      if (bgSound != null) exportData['umma_bg_sound_enabled'] = bgSound;
    } catch (_) {}

    // 4. Also include prayer_schedule.json (disimpan oleh PrayerTimesProvider
    //    dan background_service di path terpisah, bukan melalui saveJson())
    if (_jsonDir != null) {
      final scheduleFile = File('${_jsonDir!.path}/prayer_schedule.json');
      try {
        if (await scheduleFile.exists()) {
          final raw = await scheduleFile.readAsString();
          exportData['_prayer_schedule'] = raw;
        }
      } catch (_) {}
    }

    // Version metadata
    exportData['_version'] = 1;
    exportData['_exported_at'] = DateTime.now().toIso8601String();

    return exportData;
  }

  /// Restore data from exported map — shared between QR sync & file restore
  /// Returns the number of items restored.
  Future<int> restoreFromExport(Map<String, dynamic> data) async {
    int restored = 0;
    for (final entry in data.entries) {
      // Handle _prayer_schedule SEBELUM metadata skip (key start dengan _)
      if (entry.key == '_prayer_schedule') {
        if (_jsonDir != null && entry.value is String) {
          try {
            await File('${_jsonDir!.path}/prayer_schedule.json')
                .writeAsString(entry.value as String);
            restored++;
          } catch (_) {}
        }
        continue;
      }

      if (entry.key.startsWith('_')) {
        // Skip metadata keys (_version, _exported_at, dll)
        continue;
      }

      if (ApiConfig.stringStorageKeys.contains(entry.key) &&
          entry.value is String) {
        // String-based keys (theme, city, groqApiKey) → SharedPreferences
        await setString(entry.key, entry.value as String);

        // Apply runtime for active keys
        if (entry.key == ApiConfig.storageKeyGroqApiKey) {
          AiConfig.groqApiKey = entry.value as String;
        }
        restored++;
      } else if (entry.key == 'umma_bg_sound_enabled' &&
          entry.value is bool) {
        // Background sound (boolean) — shared prefs
        await setBool(entry.key, entry.value as bool);
        restored++;
      } else {
        // JSON-based keys → file storage
        await saveJson(entry.key, entry.value);
        restored++;
      }
    }
    return restored;
  }



  /// Path for JSON data file
  String _jsonFilePath(String key) {
    // Sanitize key for use as filename
    final sanitized = key.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    return '${_jsonDir!.path}/$sanitized.json';
  }

  // ─── GENERIC GET/SET (SharedPreferences) ────────────────
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);



  Future<void> remove(String key) async {
    // Remove from both storages
    await _prefs?.remove(key);
    final file = File(_jsonFilePath(key));
    if (await file.exists()) {
      await file.delete();
    }
  }

  // ─── JSON DATA (File-based di appDocDir) ────────────────
  Future<void> saveJson(String key, dynamic data) async {
    if (_jsonDir == null) {
      // Fallback: store in SharedPreferences if not initialized
      await _prefs?.setString(key, jsonEncode(data));
      return;
    }
    final file = File(_jsonFilePath(key));
    await file.writeAsString(jsonEncode(data));
  }

  Future<dynamic> getJson(String key) async {
    if (_jsonDir == null) {
      // Fallback: read from SharedPreferences
      final raw = _prefs?.getString(key);
      if (raw == null) return null;
      try {
        return jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }
    try {
      final file = File(_jsonFilePath(key));
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  // ─── SPECIFIC STORAGE METHODS ───────────────────────────
  Future<void> saveTracker(Map<String, dynamic> data) async {
    await saveJson(ApiConfig.storageKeyTracker, data);
  }

  Future<Map<String, dynamic>?> getTracker() async {
    final data = await getJson(ApiConfig.storageKeyTracker);
    return data as Map<String, dynamic>?;
  }

  Future<void> saveJournals(List<Map<String, dynamic>> journals) async {
    await saveJson(ApiConfig.storageKeyJournal, journals);
  }

  Future<List<Map<String, dynamic>>?> getJournals() async {
    final data = await getJson(ApiConfig.storageKeyJournal);
    return data is List ? data.cast<Map<String, dynamic>>() : null;
  }

  Future<void> saveCity(String city) async {
    await setString(ApiConfig.storageKeyCity, city);
  }

  String? getCity() => getString(ApiConfig.storageKeyCity);

  Future<void> saveTheme(String theme) async {
    await setString(ApiConfig.storageKeyTheme, theme);
  }

  String? getTheme() => getString(ApiConfig.storageKeyTheme);

  Future<void> clearAll() async {
    // Clear SharedPreferences
    final theme = getTheme();
    final city = getCity();
    await _prefs?.clear();

    // Clear file-based JSON storage (jurnal, hadits, bookmark, dll)
    if (_jsonDir != null && await _jsonDir!.exists()) {
      await _jsonDir!.delete(recursive: true);
      await _jsonDir!.create(recursive: true);
    }

    // Restore essential settings
    if (theme != null) await saveTheme(theme);
    if (city != null) await saveCity(city);
  }
}
