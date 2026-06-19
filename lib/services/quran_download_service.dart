import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// Manages offline download of Al-Quran JSON data and audio files.
///
/// Storage structure (using getApplicationDocumentsDirectory):
///   {appDocDir}/quran/
///     ├── json/
///     │   ├── surahs.json          (list of 114 surah)
///     │   └── surah_{number}.json  (per-surah detail + ayat)
///     └── audio/
///         └── {qariId}/            (separated by Qari/reciter)
///             └── {surah_number}/
///                 ├── 001.mp3
///                 ├── 002.mp3
///                 └── ...
///
/// This allows switching between Qari without re-downloading.
///
class QuranDownloadService {
  static final QuranDownloadService _instance =
      QuranDownloadService._internal();
  factory QuranDownloadService() => _instance;
  QuranDownloadService._internal();

  Directory? _baseDir;

  /// Get or initialize the base storage directory
  Future<Directory> get baseDir async {
    if (_baseDir != null) return _baseDir!;
    final appDocDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory('${appDocDir.path}/${ApiConfig.quranStorageDir}');
    if (!await _baseDir!.exists()) {
      await _baseDir!.create(recursive: true);
    }
    return _baseDir!;
  }

  /// Get JSON directory path
  Future<Directory> get jsonDir async {
    final base = await baseDir;
    final dir = Directory('${base.path}/json');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Sanitize string untuk nama folder (hapus karakter berbahaya)
  String _sanitizeName(String name) {
    return name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '').trim();
  }

  /// Get audio directory for a specific surah and qari
  /// Struktur: audio/{qariName}/{surahName}/
  Future<Directory> getAudioDir(
    int surahNumber, {
    String qariId = '05',
    String? surahName,
  }) async {
    final base = await baseDir;
    final qariName =
        ApiConfig.qariCdnNames[qariId] ?? ApiConfig.quranDefaultQari;
    final safeSurahName = surahName != null
        ? _sanitizeName(surahName)
        : surahNumber.toString();
    final dir = Directory('${base.path}/audio/$qariName/$safeSurahName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // ─── JSON DOWNLOAD ───────────────────────────────────────

  /// Check if surahs list JSON exists locally
  Future<bool> hasSurahsList() async {
    final dir = await jsonDir;
    return File('${dir.path}/${ApiConfig.quranSurahsFile}').exists();
  }

  /// Read surahs list from local storage
  Future<List<dynamic>?> getLocalSurahs() async {
    try {
      final dir = await jsonDir;
      final file = File('${dir.path}/${ApiConfig.quranSurahsFile}');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      return data['data'] as List<dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Download and save the list of all 114 surahs
  Future<void> downloadSurahsList() async {
    final dir = await jsonDir;
    final response = await http.get(
      Uri.parse('${ApiConfig.eQuranBaseUrl}${ApiConfig.surahEndpoint}'),
      headers: {'User-Agent': 'UmmaApp/1.0'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal download daftar surah');
    }
    final file = File('${dir.path}/${ApiConfig.quranSurahsFile}');
    await file.writeAsString(response.body);
  }

  /// Check if a specific surah's JSON is downloaded
  Future<bool> hasSurahJson(int surahNumber) async {
    final dir = await jsonDir;
    return File('${dir.path}/surah_$surahNumber.json').exists();
  }

  /// Read surah detail from local storage
  Future<Map<String, dynamic>?> getLocalSurahDetail(int surahNumber) async {
    try {
      final dir = await jsonDir;
      final file = File('${dir.path}/surah_$surahNumber.json');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final data = jsonDecode(raw);
      return data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  /// Download and save a single surah's detail + ayat
  Future<void> downloadSurahJson(int surahNumber) async {
    final dir = await jsonDir;
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.eQuranBaseUrl}${ApiConfig.surahDetailEndpoint.replaceAll('{number}', surahNumber.toString())}',
      ),
      headers: {'User-Agent': 'UmmaApp/1.0'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal download surah $surahNumber');
    }
    final file = File('${dir.path}/surah_$surahNumber.json');
    await file.writeAsString(response.body);
  }

  // ─── AUDIO DOWNLOAD ──────────────────────────────────────

  /// Check if a specific ayat's audio is downloaded (for a specific qari)
  Future<bool> hasAyatAudio(
    int surahNumber,
    int ayahNumber, {
    String qariId = '05',
    String? surahName,
  }) async {
    final dir = await getAudioDir(
      surahNumber,
      qariId: qariId,
      surahName: surahName,
    );
    return File(
      '${dir.path}/${ayahNumber.toString().padLeft(3, '0')}.mp3',
    ).exists();
  }

  /// Get count of downloaded audio files for a surah (for a specific qari)
  Future<int> countDownloadedAudio(
    int surahNumber, {
    String qariId = '05',
    String? surahName,
  }) async {
    final dir = await getAudioDir(
      surahNumber,
      qariId: qariId,
      surahName: surahName,
    );
    if (!await dir.exists()) return 0;
    final files = await dir.list().toList();
    return files.where((f) => f.path.endsWith('.mp3')).length;
  }

  /// Download a single ayat audio file for a specific qari
  /// Returns true if download was needed, false if already exists
  Future<bool> downloadAyatAudio({
    required int surahNumber,
    required int ayahNumber,
    required String audioUrl,
    String qariId = '05',
    String? surahName,
  }) async {
    final dir = await getAudioDir(
      surahNumber,
      qariId: qariId,
      surahName: surahName,
    );
    final fileName = '${ayahNumber.toString().padLeft(3, '0')}.mp3';
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) return false; // already downloaded

    try {
      final response = await http.get(
        Uri.parse(audioUrl),
        headers: {'User-Agent': 'UmmaApp/1.0'},
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }
      await file.writeAsBytes(response.bodyBytes);
      return true;
    } catch (_) {
      // Streaming URL gagal — lemparkan exception, biarkan caller handle
      rethrow;
    }
  }

  /// Download audio for all ayat in a surah sequentially (for a specific qari)
  /// Calls [onProgress] with (downloadedCount, totalCount) after each download
  Future<void> downloadAllAyatAudio({
    required int surahNumber,
    required int totalAyat,
    required List<String> audioUrls,
    required void Function(int downloaded, int total) onProgress,
    String qariId = '05',
    String? surahName,
  }) async {
    int downloaded = 0;
    final total = totalAyat;

    for (int i = 0; i < total && i < audioUrls.length; i++) {
      if (audioUrls[i].isNotEmpty) {
        try {
          await downloadAyatAudio(
            surahNumber: surahNumber,
            ayahNumber: i + 1,
            audioUrl: audioUrls[i],
            qariId: qariId,
            surahName: surahName,
          );
        } catch (_) {
          // Continue downloading remaining ayat even if one fails
        }
      }
      downloaded++;
      onProgress(downloaded, total);
    }
  }

  // ─── STATUS ──────────────────────────────────────────────

  /// Get total local storage size for Quran data
  Future<String> getStorageInfo() async {
    try {
      final base = await baseDir;
      int totalBytes = 0;
      int fileCount = 0;
      await for (final entity in base.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
          fileCount++;
        }
      }
      final size = totalBytes > 1048576
          ? '${(totalBytes / 1048576).toStringAsFixed(1)} MB'
          : '${(totalBytes / 1024).toStringAsFixed(1)} KB';
      return '$fileCount file, $size';
    } catch (_) {
      return 'Tidak diketahui';
    }
  }

  /// Delete all downloaded Quran data
  Future<void> clearAll() async {
    final base = await baseDir;
    if (await base.exists()) {
      await base.delete(recursive: true);
    }
  }

  /// Delete audio for a specific surah and qari
  Future<void> clearSurahAudio(
    int surahNumber, {
    String qariId = '05',
    String? surahName,
  }) async {
    final dir = await getAudioDir(
      surahNumber,
      qariId: qariId,
      surahName: surahName,
    );
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Delete audio for all qari's specific surah
  Future<void> clearSurahAudioAllQari(int surahNumber) async {
    for (final qari in ApiConfig.qariList) {
      await clearSurahAudio(surahNumber, qariId: qari['id']!);
    }
  }

  /// Check if any qari has audio for a surah
  Future<bool> hasAnyQariAudio(int surahNumber) async {
    for (final qari in ApiConfig.qariList) {
      final dir = await getAudioDir(surahNumber, qariId: qari['id']!);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        if (files.any((f) => f.path.endsWith('.mp3'))) return true;
      }
    }
    return false;
  }

  /// Count total audio files across all surahs for a specific Qari
  Future<int> countAudioForQari(String qariId) async {
    int total = 0;
    try {
      final base = await baseDir;
      final qariName =
          ApiConfig.qariCdnNames[qariId] ?? ApiConfig.quranDefaultQari;
      final audioDir = Directory('${base.path}/audio/$qariName');
      if (!await audioDir.exists()) return 0;
      await for (final entity in audioDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.mp3')) total++;
      }
    } catch (_) {}
    return total;
  }
}
