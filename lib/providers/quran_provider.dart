import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import '../config/api_config.dart';
import '../models/quran.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';
import '../services/quran_download_service.dart';

// Audio player singleton — one global player prevents overlapping recitation
final AudioPlayer _audioPlayer = AudioPlayer();
StreamSubscription? _audioCompletionSub;

/// Download progress for a specific surah
class SurahDownloadProgress {
  final int surahNumber;
  final bool jsonDone;
  final int audioDownloaded;
  final int audioTotal;
  final bool isDownloading;
  final String? error;

  const SurahDownloadProgress({
    required this.surahNumber,
    this.jsonDone = false,
    this.audioDownloaded = 0,
    this.audioTotal = 0,
    this.isDownloading = false,
    this.error,
  });

  double get audioProgress => audioTotal > 0 ? audioDownloaded / audioTotal : 0;
  bool get isComplete => jsonDone && audioDownloaded >= audioTotal;
}

/// Task untuk audio download queue — simpan audioUrls agar gak berubah
/// saat user ganti surah selagi queue menunggu
class _AudioDownloadTask {
  final int surahNumber;
  final List<String> audioUrls;
  final int totalAyat;

  const _AudioDownloadTask({
    required this.surahNumber,
    required this.audioUrls,
    required this.totalAyat,
  });
}

class QuranProvider extends ChangeNotifier {
  final QuranDownloadService _downloadService = QuranDownloadService();

  List<Surah> _surahs = [];
  List<Ayat> _currentAyat = [];
  Surah? _selectedSurah;
  List<QuranBookmark> _bookmarks = [];
  LastRead? _lastRead;
  bool _loading = false;
  bool _loadingAyat = false;
  String? _error;

  // Qari selection
  String _selectedQariId = ApiConfig.quranDefaultQariId;

  String get selectedQariId => _selectedQariId;
  String get selectedQariName => ApiConfig.getQariName(_selectedQariId);

  Future<void> setSelectedQari(String qariId) async {
    _selectedQariId = qariId;

    // Hentikan audio yang sedang diputar
    await stopAudio();

    // Ambil progress audio dari Qari baru
    if (_selectedSurah != null && _currentAyat.isNotEmpty) {
      final surahName = _getSurahName(_selectedSurah!.nomor);
      final downloaded = await _downloadService.countDownloadedAudio(
        _selectedSurah!.nomor,
        qariId: qariId,
        surahName: surahName,
      );
      _currentProgress = SurahDownloadProgress(
        surahNumber: _selectedSurah!.nomor,
        jsonDone: _downloadedSurahs.contains(_selectedSurah!.nomor),
        audioDownloaded: downloaded,
        audioTotal: _currentAyat.length,
        isDownloading: downloaded < _currentAyat.length,
      );

      // Download audio untuk Qari baru jika belum lengkap
      if (downloaded < _currentAyat.length) {
        _downloadAyatAudioInBackground(_selectedSurah!.nomor);
      }
    }

    notifyListeners();
  }

  /// Get audio URL for a specific ayat based on selected Qari
  /// API menyediakan per-ayat URL untuk semua Qari (01-06).
  String? getAyatAudioUrlForQari(Ayat ayat) {
    return ayat.audio.urlForQari(_selectedQariId);
  }

  /// Helper: cari nama surah dari nomor surah
  String? _getSurahName(int surahNumber) {
    if (_selectedSurah?.nomor == surahNumber) return _selectedSurah!.namaLatin;
    try {
      return _surahs.firstWhere((s) => s.nomor == surahNumber).namaLatin;
    } catch (_) {
      return null;
    }
  }

  /// Get local audio path for specific qari
  Future<String?> getLocalAudioPathForQari(
    int surahNumber,
    int ayahNumber, {
    String? qariId,
  }) async {
    final qari = qariId ?? _selectedQariId;
    try {
      final surahName = _getSurahName(surahNumber);
      final dir = await _downloadService.getAudioDir(
        surahNumber,
        qariId: qari,
        surahName: surahName,
      );
      final file = File(
        '${dir.path}/${ayahNumber.toString().padLeft(3, '0')}.mp3',
      );
      if (await file.exists()) return file.path;
      return null;
    } catch (_) {
      return null;
    }
  }

  // Download tracking
  final Set<int> _downloadedSurahs = {}; // surah numbers with JSON downloaded
  final Set<String> _audioCompleted = {}; // "surahNumber_ayahNumber" pairs
  SurahDownloadProgress? _currentProgress;
  bool _downloadAllMode = false;
  bool _waitingForInternet = false;
  int _downloadAllProgress = 0;
  int _downloadAllTotal = 114;
  int _currentlyPlayingAyah = -1;
  bool _isPlaying = false;

  // Getters
  List<Surah> get surahs => _surahs;
  List<Ayat> get currentAyat => _currentAyat;
  Surah? get selectedSurah => _selectedSurah;
  List<QuranBookmark> get bookmarks => _bookmarks;
  LastRead? get lastRead => _lastRead;
  bool get loading => _loading;
  bool get loadingAyat => _loadingAyat;
  String? get error => _error;
  SurahDownloadProgress? get currentProgress => _currentProgress;
  bool get downloadAllMode => _downloadAllMode;
  bool get waitingForInternet => _waitingForInternet;
  int get downloadAllProgress => _downloadAllProgress;
  int get downloadAllTotal => _downloadAllTotal;
  double get downloadAllProgressFraction =>
      _downloadAllTotal > 0 ? _downloadAllProgress / _downloadAllTotal : 0.0;
  int get currentlyPlayingAyah => _currentlyPlayingAyah;
  bool get isPlaying => _isPlaying;

  /// Check if a surah has JSON downloaded
  bool isSurahDownloaded(int surahNumber) =>
      _downloadedSurahs.contains(surahNumber);

  /// Check if a specific ayat audio is downloaded (for current qari)
  bool isAyatAudioDownloaded(int surahNumber, int ayahNumber) =>
      _audioCompleted.contains('${_selectedQariId}_${surahNumber}_$ayahNumber');

  /// Check if a surah has ALL audio downloaded for current Qari
  Future<bool> isSurahAudioDownloaded(int surahNumber) async {
    if (_surahs.isEmpty) return false;

    // Cari surah, jika tidak ditemukan return false — jangan fallback ke surah lain
    Surah? surah;
    try {
      surah = _surahs.firstWhere((s) => s.nomor == surahNumber);
    } catch (_) {
      return false;
    }

    final totalAyat = surah.jumlahAyat;

    // Check from _audioCompleted first
    int completed = 0;
    for (int i = 1; i <= totalAyat; i++) {
      if (_audioCompleted.contains('${_selectedQariId}_${surahNumber}_$i')) {
        completed++;
      }
    }
    if (completed >= totalAyat) {
      return true;
    }

    // Fallback: check filesystem
    final surahName = _getSurahName(surahNumber);
    final downloaded = await _downloadService.countDownloadedAudio(
      surahNumber,
      qariId: _selectedQariId,
      surahName: surahName,
    );
    return downloaded >= totalAyat;
  }

  /// Get total downloaded surah count
  int get downloadedSurahCount => _downloadedSurahs.length;

  List<Surah> get filteredSurahs => _surahs;

  // ─── LOAD SURAHS (Offline-first) ─────────────────────────
  Future<void> loadSurahs() async {
    _loading = true;
    notifyListeners();

    try {
      // 1. Try local first
      final localData = await _downloadService.getLocalSurahs();
      if (localData != null) {
        _surahs = localData.map((s) => Surah.fromJson(s)).toList();
      }

      // 2. Also fetch from API for freshness (but don't block)
      try {
        final data = await ApiService().getSurahs();
        _surahs = data.map((s) => Surah.fromJson(s)).toList();
      } catch (_) {
        if (_surahs.isEmpty) rethrow;
      }

      // 3. Save API result locally in background
      if (!(await _downloadService.hasSurahsList())) {
        await _downloadService.downloadSurahsList();
      }

      // 4. Check which surahs have local JSON data
      for (final surah in _surahs) {
        if (await _downloadService.hasSurahJson(surah.nomor)) {
          _downloadedSurahs.add(surah.nomor);
        }
      }

      _error = null;
    } catch (e) {
      _error = 'Gagal memuat daftar surah';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ─── LOAD SURAH DETAIL (Offline-first with download trigger) ─
  Future<void> loadSurahDetail(int number) async {
    _loadingAyat = true;
    _currentProgress = SurahDownloadProgress(
      surahNumber: number,
      isDownloading: true,
    );
    notifyListeners();

    try {
      // 1. Try local JSON first
      final localData = await _downloadService.getLocalSurahDetail(number);
      if (localData != null) {
        _selectedSurah = Surah.fromJson(localData);
        _currentAyat = (localData['ayat'] as List? ?? [])
            .map((a) => Ayat.fromJson(a))
            .toList();
        _downloadedSurahs.add(number);
        _currentProgress = SurahDownloadProgress(
          surahNumber: number,
          jsonDone: true,
          audioDownloaded: await _downloadService.countDownloadedAudio(
            number,
            surahName: _selectedSurah?.namaLatin,
          ),
          audioTotal: _currentAyat.length,
          isDownloading: true,
        );
        _loadingAyat = false;
        notifyListeners();

        // 2. Start background audio download
        _downloadAyatAudioInBackground(number);
        _error = null;
        return;
      }

      // 3. Download from API if not local
      final data = await ApiService().getSurahDetail(number);
      _selectedSurah = Surah.fromJson(data);
      _currentAyat = (data['ayat'] as List? ?? [])
          .map((a) => Ayat.fromJson(a))
          .toList();

      // 4. Save JSON locally
      await _downloadSurahJson(number, data);

      _downloadedSurahs.add(number);
      _currentProgress = SurahDownloadProgress(
        surahNumber: number,
        jsonDone: true,
        audioDownloaded: 0,
        audioTotal: _currentAyat.length,
        isDownloading: true,
      );
      _error = null;
      _loadingAyat = false;
      notifyListeners();

      // 5. Start background audio download
      _downloadAyatAudioInBackground(number);
    } catch (e) {
      _error = 'Gagal memuat surah';
      // Bersihkan data surah sebelumnya agar tidak tampil surah lain saat error
      _selectedSurah = null;
      _currentAyat = [];
      _currentProgress = SurahDownloadProgress(
        surahNumber: number,
        error: e.toString(),
      );
      _loadingAyat = false;
      notifyListeners();
    }
  }

  // ─── SAVE SURAH JSON TO LOCAL ────────────────────────────
  Future<void> _downloadSurahJson(int number, Map<String, dynamic> data) async {
    try {
      final jsonDir = await _downloadService.jsonDir;
      final jsonFile = File('${jsonDir.path}/surah_$number.json');
      await jsonFile.writeAsString(jsonEncode({'data': data}));
    } catch (_) {}
  }

  // ─── BACKGROUND AUDIO DOWNLOAD (per Qari) — Pakai Queue ──
  bool _isDownloadingAudio = false;
  final List<_AudioDownloadTask> _audioDownloadQueue = [];

  Future<void> _downloadAyatAudioInBackground(int surahNumber) async {
    // Tangkap audioUrls SEKARANG, bukan nanti (biar gak berubah kalo user ganti surah)
    final audioUrls = _currentAyat
        .map((a) => getAyatAudioUrlForQari(a) ?? '')
        .toList();
    final totalAyat = _currentAyat.length;

    if (audioUrls.isEmpty || audioUrls.every((u) => u.isEmpty)) {
      _currentProgress = SurahDownloadProgress(
        surahNumber: surahNumber,
        jsonDone: true,
        audioDownloaded: 0,
        audioTotal: 0,
        isDownloading: false,
      );
      notifyListeners();
      return;
    }

    final task = _AudioDownloadTask(
      surahNumber: surahNumber,
      audioUrls: List.from(audioUrls),
      totalAyat: totalAyat,
    );

    // Queue: jangan duplikat, jangan tumpuk
    if (_isDownloadingAudio) {
      final alreadyQueued = _audioDownloadQueue.any((t) => t.surahNumber == surahNumber);
      if (!alreadyQueued) {
        _audioDownloadQueue.add(task);
      }
      return;
    }

    _isDownloadingAudio = true;
    await _processAudioDownload(task);
    _isDownloadingAudio = false;

    // Proses queue berikutnya
    while (_audioDownloadQueue.isNotEmpty) {
      final nextTask = _audioDownloadQueue.removeAt(0);
      _isDownloadingAudio = true;
      await _processAudioDownload(nextTask);
      _isDownloadingAudio = false;
    }
  }

  Future<void> _processAudioDownload(_AudioDownloadTask task) async {
    final surahNumber = task.surahNumber;
    final audioUrls = task.audioUrls;
    final totalAyat = task.totalAyat;
    final currentQari = _selectedQariId;
    final surahName = _getSurahName(surahNumber);

    if (audioUrls.isEmpty || audioUrls.every((u) => u.isEmpty)) {
      _currentProgress = SurahDownloadProgress(
        surahNumber: surahNumber,
        jsonDone: true,
        audioDownloaded: 0,
        audioTotal: 0,
        isDownloading: false,
      );
      notifyListeners();
      return;
    }

    try {
      await _downloadService.downloadAllAyatAudio(
        surahNumber: surahNumber,
        totalAyat: totalAyat,
        audioUrls: audioUrls,
        qariId: currentQari,
        surahName: surahName,
        onProgress: (downloaded, total) {
          for (int i = 1; i <= downloaded; i++) {
            _audioCompleted.add('${currentQari}_${surahNumber}_$i');
          }
          _currentProgress = SurahDownloadProgress(
            surahNumber: surahNumber,
            jsonDone: true,
            audioDownloaded: downloaded,
            audioTotal: total,
            isDownloading: downloaded < total,
          );
          notifyListeners();
        },
      );

      _currentProgress = SurahDownloadProgress(
        surahNumber: surahNumber,
        jsonDone: true,
        audioDownloaded: totalAyat,
        audioTotal: totalAyat,
        isDownloading: false,
      );
      notifyListeners();
    } catch (_) {
      _currentProgress = SurahDownloadProgress(
        surahNumber: surahNumber,
        jsonDone: true,
        audioDownloaded: _currentProgress?.audioDownloaded ?? 0,
        audioTotal: totalAyat,
        isDownloading: false,
      );
      notifyListeners();
    }
  }

  // ─── DOWNLOAD ALL SURAHS ─────────────────────────────────
  Future<void> downloadAllSurahs() async {
    _waitingForInternet = false;
    _downloadAllMode = true;
    _downloadAllProgress = 0;
    _downloadAllTotal = _surahs.length;
    notifyListeners();

    try {
      // Check internet connectivity first
      try {
        final result = await InternetAddress.lookup(
          'equran.id',
        ).timeout(const Duration(seconds: 3));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception('Tidak ada koneksi internet');
        }
      } catch (_) {
        _downloadAllMode = false;
        _waitingForInternet = true;
        notifyListeners();
        return;
      }

      // Download surah list first
      if (!await _downloadService.hasSurahsList()) {
        await _downloadService.downloadSurahsList();
      }

      // Download each surah JSON one by one
      for (int i = 0; i < _surahs.length; i++) {
        final surah = _surahs[i];
        if (!_downloadedSurahs.contains(surah.nomor)) {
          try {
            final data = await ApiService().getSurahDetail(surah.nomor);
            await _downloadSurahJson(surah.nomor, data);
            _downloadedSurahs.add(surah.nomor);
          } catch (_) {}
        }
        _downloadAllProgress = i + 1;
        notifyListeners();
      }
    } catch (_) {
      _waitingForInternet = true;
    }

    _downloadAllMode = false;
    _downloadAllProgress = _downloadedSurahs.length;
    _downloadAllTotal = _surahs.length;
    notifyListeners();
  }

  // ─── GET LOCAL AUDIO PATH ────────────────────────────────
  Future<String?> getLocalAudioPath(int surahNumber, int ayahNumber) async {
    // Try current qari first, then fall back to other qari
    final path = await getLocalAudioPathForQari(surahNumber, ayahNumber);
    if (path != null) return path;

    // Fallback: try default qari (05)
    return getLocalAudioPathForQari(surahNumber, ayahNumber, qariId: '05');
  }

  /// Get the audio URL from API data or local (backward compat)
  String? getAyatAudioUrl(Ayat ayat) {
    return getAyatAudioUrlForQari(ayat);
  }

  // ─── PLAYBACK STATE ──────────────────────────────────────
  void setPlayingAyah(int ayahNumber, bool playing) {
    _currentlyPlayingAyah = playing ? ayahNumber : -1;
    _isPlaying = playing;
    notifyListeners();
  }

  /// Play audio untuk ayat tertentu — dari local file atau streaming
  /// Semua Qari (01-06) punya per-ayat URL dari API.
  Future<void> playAyatAudio(int surahNumber, Ayat ayat) async {
    final ayahNumber = ayat.nomorAyat;

    // Stop previous playback
    await stopAudio();

    // Cancel previous completion listener to avoid stacking
    _audioCompletionSub?.cancel();

    // Set up completion listener once
    _audioCompletionSub = _audioPlayer.onPlayerComplete.listen((_) {
      _currentlyPlayingAyah = -1;
      _isPlaying = false;
      notifyListeners();
    });

    // Coba local file dulu (sudah pakai folder qariName/surahName)
    final localPath = await getLocalAudioPathForQari(surahNumber, ayahNumber);
    if (localPath != null && await File(localPath).exists()) {
      try {
        await _audioPlayer.play(DeviceFileSource(localPath));
        _currentlyPlayingAyah = ayahNumber;
        _isPlaying = true;
        notifyListeners();
        return;
      } catch (_) {}
    }

    // Stream dari URL per-ayat (semua Qari didukung)
    final audioUrl = getAyatAudioUrlForQari(ayat);
    if (audioUrl != null && audioUrl.isNotEmpty) {
      try {
        await _audioPlayer.play(UrlSource(audioUrl));
        _currentlyPlayingAyah = ayahNumber;
        _isPlaying = true;
        notifyListeners();
      } catch (e) {
        debugPrint('❌ Gagal play audio ayat $ayahNumber: $e');
      }
    }
  }

  /// Stop audio playback
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentlyPlayingAyah = -1;
      _isPlaying = false;
      notifyListeners();
    } catch (_) {}
  }

  /// Pause audio playback
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (_) {}
  }

  /// Resume audio playback
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      notifyListeners();
    } catch (_) {}
  }

  /// Clean up audio (call when leaving surah reader)
  Future<void> disposeAudio() async {
    try {
      _audioCompletionSub?.cancel();
      _audioCompletionSub = null;
      await _audioPlayer.stop();
      _currentlyPlayingAyah = -1;
      _isPlaying = false;
    } catch (_) {}
  }

  // ─── STORED DATA (Bookmarks, Last Read) ──────────────────
  Future<void> loadStoredData() async {
    final storage = LocalStorage();
    final bookmarksJson = await storage.getJson(
      ApiConfig.storageKeyQuranBookmarks,
    );
    if (bookmarksJson != null) {
      _bookmarks = (bookmarksJson as List)
          .map((b) => QuranBookmark.fromJson(b))
          .toList();
    }

    final lastReadJson = await storage.getJson(
      ApiConfig.storageKeyQuranLastRead,
    );
    if (lastReadJson != null) {
      _lastRead = LastRead.fromJson(lastReadJson);
    }
    notifyListeners();
  }

  Future<void> addBookmark(QuranBookmark bookmark) async {
    _bookmarks.add(bookmark);
    await _saveBookmarks();
    notifyListeners();
  }

  Future<void> removeBookmark(int surahId, int ayahNumber) async {
    _bookmarks.removeWhere(
      (b) => b.surahId == surahId && b.ayahNumber == ayahNumber,
    );
    await _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(int surahId, int ayahNumber) {
    return _bookmarks.any(
      (b) => b.surahId == surahId && b.ayahNumber == ayahNumber,
    );
  }

  Future<void> saveLastRead(LastRead read) async {
    _lastRead = read;
    await LocalStorage().saveJson(
      ApiConfig.storageKeyQuranLastRead,
      read.toJson(),
    );
    notifyListeners();
  }

  Future<void> clearLastRead() async {
    _lastRead = null;
    await LocalStorage().remove(ApiConfig.storageKeyQuranLastRead);
    notifyListeners();
  }

  Future<void> _saveBookmarks() async {
    await LocalStorage().saveJson(
      ApiConfig.storageKeyQuranBookmarks,
      _bookmarks.map((b) => b.toJson()).toList(),
    );
  }

  /// Get storage info string
  Future<String> getStorageInfo() => _downloadService.getStorageInfo();

  /// Clear all Quran offline data
  Future<void> clearOfflineData() async {
    await _downloadService.clearAll();
    _downloadedSurahs.clear();
    _audioCompleted.clear();
    _currentProgress = null;
    notifyListeners();
  }
}
