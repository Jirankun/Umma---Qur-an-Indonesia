import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore_for_file: use_build_context_synchronously

import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../config/api_config.dart';
import '../../models/quran.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/quran_download_service.dart';
import '../../services/murattal_audio_handler.dart';

enum _SurahAudioStatus { unknown, downloaded, downloading, streaming }

class MurattalScreen extends StatefulWidget {
  const MurattalScreen({super.key});

  @override
  State<MurattalScreen> createState() => _MurattalScreenState();
}

class _MurattalScreenState extends State<MurattalScreen> with WidgetsBindingObserver {
  final QuranDownloadService _downloadService = QuranDownloadService();

  MurattalAudioHandler? _handler;
  List<Surah> _surahs = [];
  Surah? _currentSurah;
  String _selectedQariId = ApiConfig.quranDefaultQariId;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _loopOne = false;
  bool _loadingSurahs = true;
  bool _isOffline = false;
  String _searchQuery = '';

  final Map<int, _SurahAudioStatus> _audioStatus = {};
  final Map<int, double> _downloadProgress = {};
  final Map<int, Duration> _surahDurations = {};

  bool _downloadAllInProgress = false;
  int _downloadAllDone = 0;
  int _downloadAllTotal = 0;
  String? _errorMessage;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<void>? _completeSub;

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handler = MurattalAudioHandler.instance;
    if (_handler != null && _handler!.isActuallyPlaying) {
      _isPlaying = true;
    }
    _loadPreferences().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkConnectivity();
        _loadSurahs();
        _setupPlayerListeners();
      });
    });
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    final savedQariId = _prefs?.getString('murattal_qari_id');
    if (savedQariId != null && ApiConfig.qariList.any((q) => q['id'] == savedQariId)) {
      setState(() => _selectedQariId = savedQariId);
    }
    
    final savedLoop = _prefs?.getBool('murattal_loop_one') ?? false;
    setState(() => _loopOne = savedLoop);
    
    final savedSurahNumber = _prefs?.getInt('murattal_last_surah');
    final savedPositionSeconds = _prefs?.getInt('murattal_last_position') ?? 0;
    
    if (savedSurahNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_surahs.isNotEmpty) {
          try {
            final surah = _surahs.firstWhere((s) => s.nomor == savedSurahNumber);
            setState(() {
              _currentSurah = surah;
              _position = Duration(seconds: savedPositionSeconds);
            });
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _saveQariId(String qariId) async {
    await _prefs?.setString('murattal_qari_id', qariId);
  }

  Future<void> _saveLoopState(bool loop) async {
    await _prefs?.setBool('murattal_loop_one', loop);
  }

  Future<void> _savePlaybackState() async {
    if (_currentSurah != null) {
      await _prefs?.setInt('murattal_last_surah', _currentSurah!.nomor);
      await _prefs?.setInt('murattal_last_position', _position.inSeconds);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _savePlaybackState();
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    _completeSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Sinkronisasi ulang play state — handle kasus audio pause
      // saat lock screen, notifikasi, atau control panel atas
      _syncPlaybackState();
    } else if (state == AppLifecycleState.paused) {
      // Simpan posisi saat app di-minimize
      _savePlaybackState();
    }
  }

  void _syncPlaybackState() {
    final h = _handler;
    if (h == null || !mounted) return;
    final actualPlaying = h.isActuallyPlaying;
    if (_isPlaying != actualPlaying) {
      setState(() {
        _isPlaying = actualPlaying;
        if (!actualPlaying && _currentSurah != null && _position.inSeconds > 0) {
          // Audio ter-pause oleh system — kita simpan state
          _savePlaybackState();
        }
      });
    }
  }

  void _restoreCurrentSurah() async {
    final h = _handler;
    if (h == null || _surahs.isEmpty) return;
    final item = h.mediaItem.value;
    if (item == null || item.title.isEmpty) return;
    try {
      final matched = _surahs.firstWhere(
        (s) => item.title.contains(s.namaLatin),
      );
      if (mounted) {
        setState(() => _currentSurah = matched);
      }
    } catch (_) {}
  }

  Future<void> _checkConnectivity() async {
    try {
      final result =
          await InternetAddress.lookup('equran.id')
              .timeout(const Duration(seconds: 3));
      if (mounted) {
        setState(() =>
            _isOffline = result.isEmpty || result[0].rawAddress.isEmpty);
      }
    } catch (_) {
      if (mounted) setState(() => _isOffline = true);
    }
  }

  void _setupPlayerListeners() {
    final h = _handler;
    if (h == null) return;

    _posSub = h.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
        _savePlaybackState();
      }
    });

    _durSub = h.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() => _duration = d);
        if (_currentSurah != null) {
          _surahDurations[_currentSurah!.nomor] = d;
        }
      }
    });

    _completeSub = h.onPlayerComplete.listen((_) async {
      if (!mounted) return;
      
      if (_loopOne) {
        // Loop mode: replay dari awal
        await h.seek(Duration.zero);
        await h.play();
      } else {
        // Normal mode: next surah
        await _playNext();
      }
    });

    _stateSub = h.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });
  }

  List<Surah> get _filteredSurahs {
    if (_searchQuery.trim().isEmpty) return _surahs;
    final q = _searchQuery.trim().toLowerCase();
    return _surahs.where((s) {
      return s.namaLatin.toLowerCase().contains(q) ||
          s.arti.toLowerCase().contains(q) ||
          s.nomor.toString() == q;
    }).toList();
  }

  String get _qariName => ApiConfig.getQariName(_selectedQariId);
  String get _qariCdnName =>
      ApiConfig.qariCdnNames[_selectedQariId] ?? 'Misyari-Rasyid-Al-Afasi';

  void _showQariPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _QariPickerSheet(
        currentQariId: _selectedQariId,
        onSelect: (qariId) async {
          await _saveQariId(qariId);
          setState(() {
            _selectedQariId = qariId;
            _audioStatus.clear();
            _downloadProgress.clear();
            _surahDurations.clear();
            _currentSurah = null;
          });
          _handler?.stop();
          _checkAllAudioStatus();
        },
      ),
    );
  }

  String _getAudioUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '${ApiConfig.quranAudioCdn}/$_qariCdnName/$padded.mp3';
  }

  Future<String?> _getLocalAudioPath(int surahNumber) async {
    final surahName = _getSurahName(surahNumber);
    final dir = await _downloadService.getAudioDir(
      surahNumber,
      qariId: _selectedQariId,
      surahName: surahName,
    );
    final file = File('${dir.path}/full.mp3');
    if (await file.exists()) return file.path;
    return null;
  }

  Future<void> _loadSurahs() async {
    final provider = context.read<QuranProvider>();
    if (provider.surahs.isNotEmpty) {
      setState(() {
        _surahs = provider.surahs;
        _loadingSurahs = false;
      });
      _checkAllAudioStatus();
      _restoreCurrentSurah();
      return;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.loadSurahs();
      if (mounted) {
        setState(() {
          _surahs = provider.surahs;
          _loadingSurahs = false;
        });
        _checkAllAudioStatus();
        _restoreCurrentSurah();
      }
    });
  }

  String _getSurahName(int surahNumber) {
    try {
      return _surahs.firstWhere((s) => s.nomor == surahNumber).namaLatin;
    } catch (_) {
      return surahNumber.toString();
    }
  }

  Future<Duration> _probeFileDuration(String filePath) async {
    try {
      final player = AudioPlayer();
      await player.setSource(DeviceFileSource(filePath));
      final dur = await player.getDuration();
      await player.dispose();
      return dur ?? Duration.zero;
    } catch (_) {
      return Duration.zero;
    }
  }

  Future<void> _checkAllAudioStatus() async {
    final futures = _surahs.map((s) async {
      final local = await _getLocalAudioPath(s.nomor);
      if (mounted) {
        setState(() {
          _audioStatus[s.nomor] = local != null
              ? _SurahAudioStatus.downloaded
              : _SurahAudioStatus.unknown;
        });
      }
      return MapEntry(s.nomor, local);
    });
    final results = await Future.wait(futures);

    for (final entry in results) {
      if (entry.value != null && mounted) {
        final dur = await _probeFileDuration(entry.value!);
        if (mounted && dur > Duration.zero) {
          setState(() {
            _surahDurations[entry.key] = dur;
          });
        }
      }
    }
  }

  Future<void> _playSurah(Surah surah) async {
    final h = _handler;
    if (h == null) return;

    final status = _audioStatus[surah.nomor] ?? _SurahAudioStatus.unknown;

    if (_currentSurah?.nomor == surah.nomor && _isPlaying) {
      await h.pause();
      return;
    }
    if (_currentSurah?.nomor == surah.nomor && !_isPlaying) {
      await h.play();
      return;
    }

    setState(() {
      _currentSurah = surah;
      _position = Duration.zero;
      _duration = Duration.zero;
    });

    if (status == _SurahAudioStatus.downloaded) {
      final localPath = await _getLocalAudioPath(surah.nomor);
      if (localPath != null) {
        await h.setSource(
          source: localPath,
          title: surah.namaLatin,
          artist: _qariName,
          isLocal: true,
        );
        return;
      }
    }

    if (status == _SurahAudioStatus.unknown && !_isOffline) {
      await _downloadAndPlay(surah);
      return;
    }

    if (!_isOffline) {
      try {
        await h.setSource(
          source: _getAudioUrl(surah.nomor),
          title: surah.namaLatin,
          artist: _qariName,
          isLocal: false,
        );
      } catch (_) {}
    }
  }

  Future<void> _playNext() async {
    if (_currentSurah == null || _filteredSurahs.isEmpty) return;
    final idx =
        _filteredSurahs.indexWhere((s) => s.nomor == _currentSurah!.nomor);
    if (idx < _filteredSurahs.length - 1) {
      await _playSurah(_filteredSurahs[idx + 1]);
    }
  }

  Future<void> _playPrevious() async {
    if (_currentSurah == null || _filteredSurahs.isEmpty) return;
    if (_position.inSeconds > 3) {
      await _handler?.seek(Duration.zero);
      return;
    }
    final idx =
        _filteredSurahs.indexWhere((s) => s.nomor == _currentSurah!.nomor);
    if (idx > 0) {
      await _playSurah(_filteredSurahs[idx - 1]);
    }
  }

  Future<void> _seekTo(double value) async {
    await _handler?.seek(Duration(seconds: value.toInt()));
    _savePlaybackState();
  }

  Future<void> _downloadAndPlay(Surah surah) async {
    setState(() {
      _errorMessage = null;
      _audioStatus[surah.nomor] = _SurahAudioStatus.downloading;
      _downloadProgress[surah.nomor] = 0.0;
    });

    final h = _handler;
    if (h == null) {
      _showError('Audio handler tidak tersedia');
      return;
    }

    try {
      final url = _getAudioUrl(surah.nomor);
      final surahName = _getSurahName(surah.nomor);
      final dir = await _downloadService.getAudioDir(
        surah.nomor,
        qariId: _selectedQariId,
        surahName: surahName,
      );

      final response =
          await http.Client().send(http.Request('GET', Uri.parse(url)));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final bytes = <int>[];
      final completer = Completer<void>();

      response.stream.listen(
        (chunk) {
          bytes.addAll(chunk);
          if (contentLength > 0 && mounted) {
            setState(() {
              _downloadProgress[surah.nomor] = bytes.length / contentLength;
            });
          }
        },
        onDone: () async {
          final file = File('${dir.path}/full.mp3');
          await file.writeAsBytes(bytes);

          final dur = await _probeFileDuration(file.path);

          if (mounted) {
            setState(() {
              _errorMessage = null;
              _audioStatus[surah.nomor] = _SurahAudioStatus.downloaded;
              _downloadProgress.remove(surah.nomor);
              if (dur > Duration.zero) {
                _surahDurations[surah.nomor] = dur;
              }
            });
            await h.setSource(
              source: file.path,
              title: surah.namaLatin,
              artist: _qariName,
              duration: dur > Duration.zero ? dur : _duration,
              isLocal: true,
            );
          }
          completer.complete();
        },
        onError: (e) {
          // Download gagal — fallback ke streaming
          if (mounted) {
            setState(() {
              _audioStatus[surah.nomor] = _SurahAudioStatus.streaming;
              _downloadProgress.remove(surah.nomor);
            });
            h.setSource(
              source: url,
              title: surah.namaLatin,
              artist: _qariName,
              isLocal: false,
            ).catchError((_) {
              // Streaming juga gagal
              _showError('Gagal memutar audio. Periksa koneksi internet Anda.');
              setState(() {
                _audioStatus[surah.nomor] = _SurahAudioStatus.unknown;
                _currentSurah = null;
              });
            });
          }
          completer.completeError(e);
        },
      );

      await completer.future;
    } catch (e) {
      if (mounted) {
        setState(() {
          _audioStatus[surah.nomor] = _SurahAudioStatus.streaming;
          _downloadProgress.remove(surah.nomor);
        });
        // Coba streaming sebagai fallback
        try {
          await h.setSource(
            source: _getAudioUrl(surah.nomor),
            title: surah.namaLatin,
            artist: _qariName,
            isLocal: false,
          );
        } catch (_) {
          _showError('Gagal memuat audio. Periksa koneksi internet Anda.');
          setState(() {
            _audioStatus[surah.nomor] = _SurahAudioStatus.unknown;
            _currentSurah = null;
          });
        }
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    // Hapus error setelah 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _errorMessage == message) {
        setState(() => _errorMessage = null);
      }
    });
  }

  Future<void> _downloadAll() async {
    setState(() {
      _downloadAllInProgress = true;
      _downloadAllDone = 0;
      _downloadAllTotal = _surahs.length;
    });

    final captureQariId = _selectedQariId;
    final captureCdnName = _qariCdnName;

    for (int i = 0; i < _surahs.length; i++) {
      final surah = _surahs[i];
      final status = _audioStatus[surah.nomor] ?? _SurahAudioStatus.unknown;

      if (status == _SurahAudioStatus.downloaded) {
        setState(() => _downloadAllDone = i + 1);
        continue;
      }

      try {
        final padded = surah.nomor.toString().padLeft(3, '0');
        final url = '${ApiConfig.quranAudioCdn}/$captureCdnName/$padded.mp3';
        final surahName = _getSurahName(surah.nomor);
        final dir = await _downloadService.getAudioDir(
          surah.nomor,
          qariId: captureQariId,
          surahName: surahName,
        );
        final file = File('${dir.path}/full.mp3');

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);

          final dur = await _probeFileDuration(file.path);

          if (mounted) {
            setState(() {
              _audioStatus[surah.nomor] = _SurahAudioStatus.downloaded;
              if (dur > Duration.zero) {
                _surahDurations[surah.nomor] = dur;
              }
              _downloadAllDone = i + 1;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _audioStatus[surah.nomor] = _SurahAudioStatus.streaming;
              _downloadAllDone = i + 1;
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _audioStatus[surah.nomor] = _SurahAudioStatus.streaming;
            _downloadAllDone = i + 1;
          });
        }
      }
    }

    if (mounted) {
      setState(() => _downloadAllInProgress = false);
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int get _downloadedCount =>
      _audioStatus.values.where((s) => s == _SurahAudioStatus.downloaded).length;

  String? _getSurahDurationText(int surahNumber) {
    final d = _surahDurations[surahNumber];
    if (d != null && d.inSeconds > 0) return _formatDuration(d);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final hasCurrent = _currentSurah != null;
    final filtered = _filteredSurahs;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cupertinoSystemBackground,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: AppColors.primary),
        ),
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.murattalTitle),
            if (_isOffline) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cupertinoSystemRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'OFFLINE',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.cupertinoSystemRed),
                ),
              ),
            ],
          ],
        ),
        trailing: GestureDetector(
          onTap: _showQariPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.person_fill, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  _qariName.split(' ').last,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(isDark),
            if (_errorMessage != null) _buildErrorBanner(isDark),
            _buildDownloadAllBanner(isDark),
            Expanded(
              child: _loadingSurahs
                  ? const Center(child: CupertinoActivityIndicator(radius: 14))
                  : filtered.isEmpty && _searchQuery.isNotEmpty
                      ? _buildSearchEmpty(isDark)
                      : ListView.builder(
                          padding: EdgeInsets.fromLTRB(16, 4, 16, hasCurrent ? 0 : 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final surah = filtered[index];
                            final isActive = _currentSurah?.nomor == surah.nomor;
                            return _buildSurahTile(surah, isActive, isDark);
                          },
                        ),
            ),
            if (hasCurrent) _buildPlayerBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: CupertinoSearchTextField(
        placeholder: 'Cari surah...',
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
        ),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.cupertinoSystemGrey6,
      ),
    );
  }

  Widget _buildDownloadAllBanner(bool isDark) {
    if (_surahs.isEmpty) return const SizedBox.shrink();

    final allDownloaded = _downloadedCount >= _surahs.length;
    if (allDownloaded && !_downloadAllInProgress) {
      return const SizedBox.shrink();
    }

    if (_downloadAllInProgress) {
      final progress = _downloadAllTotal > 0 ? _downloadAllDone / _downloadAllTotal : 0.0;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mengunduh audio...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? AppColors.borderSubtle : AppColors.cupertinoSystemGrey5,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      minHeight: 5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$_downloadAllDone/$_downloadAllTotal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                fontFamily: '.SF Mono',
                color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _isOffline ? null : _downloadAll,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.heat4],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.cupertinoWhite.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(CupertinoIcons.cloud_download_fill, color: AppColors.cupertinoWhite, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Download Semua Surah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cupertinoWhite,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_downloadedCount dari ${_surahs.length} surah tersimpan',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.cupertinoWhite.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _errorMessage = null),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cupertinoSystemRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cupertinoSystemRed.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 16,
              color: AppColors.cupertinoSystemRed,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.cupertinoSystemRed,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.clear_circled_solid,
              size: 16,
              color: AppColors.cupertinoSystemRed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.search, size: 48, color: AppColors.cupertinoSystemGrey),
          const SizedBox(height: 16),
          Text(
            'Surah tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci lain',
            style: TextStyle(fontSize: 12, color: AppColors.cupertinoSystemGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(Surah surah, bool isActive, bool isDark) {
    final status = _audioStatus[surah.nomor] ?? _SurahAudioStatus.unknown;
    final isDownloading = status == _SurahAudioStatus.downloading;
    final isDownloaded = status == _SurahAudioStatus.downloaded;
    final durText = _getSurahDurationText(surah.nomor);

    return GestureDetector(
      onTap: isDownloading ? null : () => _playSurah(surah),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.accentBgDark : AppColors.accentBgLight)
              : (isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? AppColors.accent.withValues(alpha: 0.6)
                : (isDark ? AppColors.borderSubtle.withValues(alpha: 0.4) : AppColors.cupertinoSystemGrey5),
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: AppColors.cupertinoSystemGrey4.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 42,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.accent
                      : (isDownloaded
                          ? AppColors.heat4.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surah.nomor}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontFamily: '.SF Mono',
                      color: isActive
                          ? AppColors.cupertinoWhite
                          : (isDownloading
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : isDownloaded ? AppColors.heat4 : AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      surah.namaLatin,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          surah.arti,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3, height: 3,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cupertinoSystemGrey.withValues(alpha: 0.5) : AppColors.cupertinoSystemGrey4,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${surah.jumlahAyat} Ayat',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                          ),
                        ),
                        if (durText != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 3, height: 3,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cupertinoSystemGrey.withValues(alpha: 0.5) : AppColors.cupertinoSystemGrey4,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            durText,
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: '.SF Mono',
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildSurahTrailingIcon(isActive, isDark, isDownloading, isDownloaded, surah),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerBar(bool isDark) {
    final posSec = _position.inSeconds.toDouble();
    final durSec = _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderSubtle.withValues(alpha: 0.5) : AppColors.cupertinoSystemGrey5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cupertinoBlack.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 22,
                child: CupertinoSlider(
                  value: posSec.clamp(0.0, durSec),
                  max: durSec,
                  activeColor: AppColors.accent,
                  thumbColor: AppColors.accent,
                  onChanged: _seekTo,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: '.SF Mono',
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: '.SF Mono',
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: CupertinoIcons.repeat,
                    isActive: _loopOne,
                    activeColor: AppColors.accent,
                    isDark: isDark,
                    onTap: () {
                      setState(() => _loopOne = !_loopOne);
                      _saveLoopState(_loopOne);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildControlButton(
                    icon: CupertinoIcons.backward_fill,
                    isActive: false,
                    activeColor: AppColors.primary,
                    isDark: isDark,
                    onTap: _playPrevious,
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      if (_currentSurah != null) _playSurah(_currentSurah!);
                    },
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.heat4],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                        size: 20,
                        color: AppColors.cupertinoWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: CupertinoIcons.forward_fill,
                    isActive: false,
                    activeColor: AppColors.primary,
                    isDark: isDark,
                    onTap: _playNext,
                  ),
                  const SizedBox(width: 16),
                  const SizedBox(width: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahTrailingIcon(
    bool isActive,
    bool isDark,
    bool isDownloading,
    bool isDownloaded,
    Surah surah,
  ) {
    // Download progress: tampilkan progress bar melingkar
    if (isDownloading) {
      final progress = _downloadProgress[surah.nomor] ?? 0.0;
      return SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress > 0.0 ? progress : null,
              strokeWidth: 3,
              color: AppColors.accent,
              backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            ),
            Icon(
              CupertinoIcons.arrow_down_doc_fill,
              size: 12,
              color: AppColors.accent,
            ),
          ],
        ),
      );
    }

    // Downloaded: centang hijau
    if (isDownloaded) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.heat4.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          CupertinoIcons.check_mark_circled_solid,
          size: 18,
          color: AppColors.heat4,
        ),
      );
    }

    // Default: play/pause button
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent
            : (isDark
                ? AppColors.borderSubtle.withValues(alpha: 0.4)
                : AppColors.cupertinoSystemGrey6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isActive && _isPlaying
            ? CupertinoIcons.pause_fill
            : CupertinoIcons.play_fill,
        size: 16,
        color: isActive
            ? AppColors.cupertinoWhite
            : (isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.all(6),
      onPressed: onTap,
      child: Icon(
        icon,
        size: 20,
        color: isActive ? activeColor : (isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey2),
      ),
    );
  }
}

class _QariPickerSheet extends StatefulWidget {
  final String currentQariId;
  final void Function(String) onSelect;

  const _QariPickerSheet({
    required this.currentQariId,
    required this.onSelect,
  });

  @override
  State<_QariPickerSheet> createState() => _QariPickerSheetState();
}

class _QariPickerSheetState extends State<_QariPickerSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final qaris = ApiConfig.qariList;

    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cupertinoSystemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cupertinoSystemGrey.withValues(alpha: 0.4) : AppColors.cupertinoSystemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.toolIndigo, AppColors.onboardingPurple],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(CupertinoIcons.person_fill, size: 16, color: AppColors.cupertinoWhite),
                ),
                const SizedBox(width: 12),
                Text(
                  'Pilih Qari',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? AppColors.cupertinoWhite : AppColors.textLight),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: qaris.length,
              itemBuilder: (context, index) {
                final qari = qaris[index];
                final isSelected = qari['id'] == widget.currentQariId;
                return GestureDetector(
                  onTap: () {
                    widget.onSelect(qari['id']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 35, height: 35,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(CupertinoIcons.check_mark_circled_solid, size: 18, color: AppColors.cupertinoWhite)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: '.SF Mono',
                                      color: AppColors.primary,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                qari['name']!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                qari['nameAr']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'ScheherazadeNew',
                                  color: isDark ? AppColors.cupertinoSystemGrey : AppColors.cupertinoSystemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}