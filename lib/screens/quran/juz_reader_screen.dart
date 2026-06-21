import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../data/juz_mapping.dart';
import '../../models/quran.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/quran_tracker_service.dart';
import '../../services/local_storage.dart';
import '../../services/api_service.dart';

class JuzReaderScreen extends StatefulWidget {
  final int juzNumber;
  final int? focusSurahId;
  final int? focusAyahNumber;

  const JuzReaderScreen({
    super.key,
    required this.juzNumber,
    this.focusSurahId,
    this.focusAyahNumber,
  });

  @override
  State<JuzReaderScreen> createState() => _JuzReaderScreenState();
}

class _JuzReaderScreenState extends State<JuzReaderScreen> {
  List<_JuzSurahData> _juzSurahs = [];
  bool _loading = true;
  String? _error;

  bool _showArab = true;
  bool _showLatin = true;
  bool _showTerjemahan = true;
  double _arabFontSize = 24;
  bool _hafalanMode = false;
  final Set<String> _revealedAyatIds = {};

  List<QuranBookmark> _bookmarks = [];

  final Map<int, Map<int, String>> _tafsirCache = {};

  // Scroll & highlight untuk "Lanjut Baca"
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToTarget = false;
  int _scrollRetries = 0;
  int? _targetFocusSurahId;
  int? _targetFocusAyahNumber;
  bool _scrollInitiated = false;
  GlobalKey? _targetAyatKey;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _targetFocusSurahId = widget.focusSurahId;
    _targetFocusAyahNumber = widget.focusAyahNumber;
    _loadBookmarks();
    _loadSettings();
    _fetchJuz();
  }

  Future<void> _loadSettings() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyQuranReaderSettings,
    );
    if (data is Map) {
      setState(() {
        _showArab = (data['showArab'] as bool?) ?? true;
        _showLatin = (data['showLatin'] as bool?) ?? true;
        _showTerjemahan = (data['showTerjemahan'] as bool?) ?? true;
        _arabFontSize = (data['arabFontSize'] as num?)?.toDouble() ?? 24;
        _hafalanMode = (data['hafalanMode'] as bool?) ?? false;
      });
    }
  }

  Future<void> _saveSettings() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyQuranReaderSettings, {
      'showArab': _showArab,
      'showLatin': _showLatin,
      'showTerjemahan': _showTerjemahan,
      'arabFontSize': _arabFontSize,
      'hafalanMode': _hafalanMode,
    });
  }

  Future<void> _loadBookmarks() async {
    final storage = LocalStorage();
    final json = await storage.getJson(ApiConfig.storageKeyQuranBookmarks);
    if (json != null) {
      _bookmarks = (json as List)
          .map((b) => QuranBookmark.fromJson(b))
          .toList();
    }
  }

  Future<void> _fetchJuz() async {
    setState(() => _loading = true);

    try {
      final segments = juzMapping[widget.juzNumber];
      if (segments == null) {
        setState(() {
          _error = 'Juz ${widget.juzNumber} tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final surahIds = segments.map((s) => s.surahId).toSet();
      final result = <_JuzSurahData>[];
      final quranProvider = context.read<QuranProvider>();

      for (final id in surahIds) {
        await quranProvider.loadSurahDetail(id);
        final surah = quranProvider.selectedSurah;
        final allAyat = List<Ayat>.from(quranProvider.currentAyat);
        if (surah == null) continue;
        final seg = segments.firstWhere((s) => s.surahId == id);
        final filtered = allAyat.where((a) {
          if (a.nomorAyat < seg.from) return false;
          if (seg.to != null && a.nomorAyat > seg.to!) return false;
          return true;
        }).toList();
        result.add(
          _JuzSurahData(
            surahId: id,
            namaLatin: surah.namaLatin,
            nama: surah.nama,
            ayat: filtered,
          ),
        );
      }

      setState(() {
        _juzSurahs = result;
        _loading = false;
      });
      _startTracker();
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat Juz ${widget.juzNumber}';
        _loading = false;
      });
    }
  }

  bool _trackerActive = false;
  void _startTracker() {
    if (_trackerActive) return;
    _trackerActive = true;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await QuranTrackerService().addReadingDuration(today, 5);
      return mounted;
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text('${AppStrings.quranJuz} ${widget.juzNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _showSettings(context, isDark),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  CupertinoIcons.slider_horizontal_3,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(child: _buildBody(isDark)),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.exclamationmark_triangle_fill,
                size: 40,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: _fetchJuz,
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    // ─── Initiate auto-scroll ke ayat target (Lanjut Baca) ───
    if (_targetFocusSurahId != null &&
        _targetFocusAyahNumber != null &&
        !_scrollInitiated &&
        !_loading &&
        _juzSurahs.isNotEmpty) {
      _scrollInitiated = true;
      _targetAyatKey = GlobalKey();
      _scrollRetries = 0;

      // Lompat ke estimasi posisi (pake hardcoded height — sudah paling optimal untuk Juz reader)
      double cumulativeOffset = 0;
      cumulativeOffset += 200; // hero banner
      if (_hafalanMode) cumulativeOffset += 58;
      const ayahHeight = 220.0;
      const separatorHeight = 56.0;
      const surahItemGap = 12.0;
      bool found = false;
      for (final surahData in _juzSurahs) {
        if (found) break;
        cumulativeOffset += separatorHeight;
        if (surahData.surahId == _targetFocusSurahId) {
          final targetIdx = surahData.ayat.indexWhere(
            (a) => a.nomorAyat == _targetFocusAyahNumber,
          );
          if (targetIdx >= 0) {
            cumulativeOffset += targetIdx * ayahHeight;
            found = true;
          }
        } else {
          cumulativeOffset += surahData.ayat.length * ayahHeight + surahItemGap;
        }
      }

      if (found && _scrollController.hasClients) {
        final estimatedOffset = cumulativeOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );
        _scrollController.jumpTo(estimatedOffset);
      }

      // ensureVisible tiap frame sampai berhasil (max 60 frame)
      _tryScrollToTarget();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: _buildHeroBanner(isDark)),
        if (_hafalanMode)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textLight
                    : AppColors.warningBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? AppColors.borderSubtle
                      : AppColors.warningBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.eye_slash_fill,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode Hafalan — ketuk untuk melihat ayat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? CupertinoColors.white
                            : AppColors.warningTextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ..._juzSurahs
            .map(
              (surahData) => [
                SliverToBoxAdapter(
                  child: _buildSurahSeparator(surahData, isDark),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index >= surahData.ayat.length) return null;
                      return _buildAyatItem(surahData, index, isDark);
                    }, childCount: surahData.ayat.length),
                  ),
                ),
              ],
            )
            .expand((x) => x),
        SliverToBoxAdapter(child: _buildNavigation(isDark)),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    final totalAyat = _juzSurahs.fold<int>(0, (sum, s) => sum + s.ayat.length);
    final surahNames = _juzSurahs.map((s) => s.namaLatin).join(', ');

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            CupertinoIcons.book_fill,
            size: 32,
            color: CupertinoColors.white,
          ),
          const SizedBox(height: 8),
          Text(
            'Juz',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
          Text(
            '${widget.juzNumber}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalAyat Ayat',
            style: TextStyle(
              fontSize: 12,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            surahNames,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahSeparator(_JuzSurahData surahData, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.borderSubtle
                : CupertinoColors.systemGrey4,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: isDark
                ? AppColors.borderSubtle
                : CupertinoColors.systemGrey4,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            surahData.nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 16, color: CupertinoColors.systemGrey4),
          const SizedBox(width: 12),
          Text(
            surahData.namaLatin,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatItem(_JuzSurahData surahData, int index, bool isDark) {
    final ayat = surahData.ayat[index];
    final ayatId = '${surahData.surahId}-${ayat.nomorAyat}';
    final isRevealed = _revealedAyatIds.contains(ayatId);
    final isBookmarked = _bookmarks.any(
      (b) => b.surahId == surahData.surahId && b.ayahNumber == ayat.nomorAyat,
    );
    final player = Provider.of<QuranProvider>(context);
    final isPlaying =
        player.currentlyPlayingAyah == ayat.nomorAyat && player.isPlaying;
    final isTargetAyat =
        _targetFocusSurahId == surahData.surahId &&
        _targetFocusAyahNumber == ayat.nomorAyat;

    return Container(
      key: isTargetAyat ? _targetAyatKey : null,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTargetAyat
            ? (isDark
                  ? AppColors.accentBgDark.withValues(alpha: 0.25)
                  : AppColors.accentBgLight)
            : (isDark ? AppColors.surfaceDark : CupertinoColors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTargetAyat
              ? (isDark ? AppColors.accentLight : AppColors.heat4)
              : (isDark
                    ? AppColors.textLight
                    : CupertinoColors.systemGrey6),
          width: isTargetAyat ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${ayat.nomorAyat}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (isPlaying) {
                        await player.pauseAudio();
                      } else {
                        await player.playAyatAudio(surahData.surahId, ayat);
                      }
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppColors.heat4.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isPlaying
                            ? CupertinoIcons.pause_circle_fill
                            : CupertinoIcons.play_circle_fill,
                        size: 18,
                        color: isPlaying
                            ? AppColors.heat4
                            : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _toggleBookmark(surahData, ayat),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isBookmarked
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : CupertinoColors.systemGrey5.withValues(
                                alpha: 0.3,
                              ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isBookmarked
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        size: 16,
                        color: isBookmarked
                            ? AppColors.warning
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _showTafsir(ayat, surahData),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.heat4.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _markLastRead(surahData, ayat),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.check_mark_circled,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_showArab)
            GestureDetector(
              onTap: _hafalanMode
                  ? () {
                      setState(() {
                        if (isRevealed) {
                          _revealedAyatIds.remove(ayatId);
                        } else {
                          _revealedAyatIds.add(ayatId);
                        }
                      });
                    }
                  : null,
              child: _hafalanMode && !isRevealed
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.eye_slash_fill,
                            size: 20,
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ketuk untuk lihat ayat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        ayat.teksArab,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: _arabFontSize,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          fontFamily: 'ScheherazadeNew',
                          color: isDark
                              ? CupertinoColors.white
                              : AppColors.textLight,
                        ),
                      ),
                    ),
            ),
          if (_showArab) const SizedBox(height: 8),
          if (_showLatin)
            Text(
              ayat.teksLatin,
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
          if (_showLatin) const SizedBox(height: 4),
          if (_showTerjemahan)
            Text(
              ayat.teksIndonesia,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? CupertinoColors.white : AppColors.textLight,
              ),
            ),
        ],
      ),
    );
  }

  // ─── TAFSIR ────────────────────────────────────────────────
  Future<({String tafsirText, String? sourceLabel})> _loadTafsir(
    Ayat ayat,
    _JuzSurahData surahData,
  ) async {
    try {
      if (!_tafsirCache.containsKey(surahData.surahId)) {
        final data = await ApiService().getTafsir(surahData.surahId);
        final List<dynamic> tafsirList = data['tafsir'] ?? [];
        final ayatMap = <int, String>{};
        for (final item in tafsirList) {
          final ayatNum = item['ayat'] as int? ?? 0;
          final teks = (item['teks'] as String? ?? '').trim();
          if (ayatNum > 0 && teks.isNotEmpty) {
            ayatMap[ayatNum] = teks;
          }
        }
        _tafsirCache[surahData.surahId] = ayatMap;
      }

      final text = _tafsirCache[surahData.surahId]?[ayat.nomorAyat] ?? '';
      return (
        tafsirText: text,
        sourceLabel: 'Tafsir ${surahData.namaLatin} \u2014 Kemenag RI',
      );
    } catch (_) {
      return (tafsirText: '', sourceLabel: null);
    }
  }

  void _showTafsir(Ayat ayat, _JuzSurahData surahData) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    bool loading = true;
    String tafsirText = '';
    String? sourceLabel;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          if (loading) {
            _loadTafsir(ayat, surahData).then((r) {
              if (mounted) {
                setModalState(() {
                  loading = false;
                  tafsirText = r.tafsirText;
                  sourceLabel = r.sourceLabel;
                });
              }
            });
          }

          return Container(
            height: loading ? 200 : 460,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : CupertinoColors.systemBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: _buildTafsirSheet(
              isDark: isDark,
              loading: loading,
              ayat: ayat,
              surahData: surahData,
              tafsirText: tafsirText,
              sourceLabel: sourceLabel,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTafsirSheet({
    required bool isDark,
    required bool loading,
    required Ayat ayat,
    required _JuzSurahData surahData,
    required String tafsirText,
    required String? sourceLabel,
  }) {
    if (loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    // Content state (no ayat preview)
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.heat4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TAFSIR',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${surahData.namaLatin} \u2014 Ayat ${ayat.nomorAyat}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? CupertinoColors.white
                      : AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                tafsirText,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: isDark
                      ? CupertinoColors.white
                      : AppColors.textLight,
                ),
              ),
            ),
          ),
          if (sourceLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              sourceLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── AUTO-SCROLL HELPER — scroll target ke tengah layar ──
  /// Scroll ke ayat target dengan retry tiap frame (max 60 frame /
  void _tryScrollToTarget() {
    if (!mounted || _hasScrolledToTarget || _scrollRetries >= 60) {
      _hasScrolledToTarget = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasScrolledToTarget) return;

      if (_targetAyatKey?.currentContext != null) {
        Scrollable.ensureVisible(
          _targetAyatKey!.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
        _hasScrolledToTarget = true;
        return;
      }

      _scrollRetries++;

      // Re-estimasi dan re-scroll
      if (_scrollController.hasClients) {
        double est = 200;
        if (_hafalanMode) est += 58;
        const ah = 220.0;
        bool found = false;
        for (final sd in _juzSurahs) {
          if (found) break;
          est += 56;
          if (_targetFocusSurahId != null && sd.surahId == _targetFocusSurahId) {
            final idx = sd.ayat.indexWhere(
              (a) => a.nomorAyat == _targetFocusAyahNumber,
            );
            if (idx >= 0) {
              est += idx * ah;
              found = true;
            }
          } else {
            est += sd.ayat.length * ah + 12;
          }
        }
        if (found) {
          final maxExt = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(est.clamp(0.0, maxExt));
        }
      }

      _tryScrollToTarget();
    });
  }

  // ─── BOOKMARK ─────────────────────────────────────────────
  void _toggleBookmark(_JuzSurahData surahData, Ayat ayat) {
    final existing = _bookmarks.any(
      (b) => b.surahId == surahData.surahId && b.ayahNumber == ayat.nomorAyat,
    );
    final quranProvider = context.read<QuranProvider>();
    if (existing) {
      _bookmarks.removeWhere(
        (b) => b.surahId == surahData.surahId && b.ayahNumber == ayat.nomorAyat,
      );
      quranProvider.removeBookmark(surahData.surahId, ayat.nomorAyat);
    } else {
      final bookmark = QuranBookmark(
        surahId: surahData.surahId,
        ayahNumber: ayat.nomorAyat,
        surahName: surahData.namaLatin,
        isJuz: true,
        juzNumber: widget.juzNumber,
      );
      _bookmarks.add(bookmark);
      quranProvider.addBookmark(bookmark);
    }
    _saveBookmarks();
    setState(() {});
  }

  Future<void> _saveBookmarks() async {
    await LocalStorage().saveJson(
      ApiConfig.storageKeyQuranBookmarks,
      _bookmarks.map((b) => b.toJson()).toList(),
    );
  }

  void _markLastRead(_JuzSurahData surahData, Ayat ayat) {
    final lastRead = LastRead(
      surahId: surahData.surahId,
      surahName: surahData.namaLatin,
      ayahNumber: ayat.nomorAyat,
      isJuz: true,
      juzNumber: widget.juzNumber,
    );
    context.read<QuranProvider>().saveLastRead(lastRead);
    _showSessionEndModal(surahData, ayat);
  }

  void _showSessionEndModal(_JuzSurahData surahData, Ayat ayat) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final totalAyah = QuranTrackerService.calculateAbsoluteAyah(
      surahData.surahId,
      ayat.nomorAyat,
    );
    final isKhatam = totalAyah >= 6236;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 480,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Icon(
                isKhatam
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.check_mark_circled_solid,
                size: 48,
                color: isKhatam
                    ? AppColors.warning
                    : AppColors.heat4,
              ),
              const SizedBox(height: 12),
              Text(
                isKhatam
                    ? 'Alhamdulillah, Khatam! \u{1F389}'
                    : 'Batas Bacaan Disimpan',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isKhatam)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'MasyaAllah, kamu telah menyelesaikan bacaan seluruh Al-Qur\'an.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Posisi bacaan terakhir sudah disimpan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.textLight
                      : CupertinoColors.systemGrey6.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Doa Setelah Membaca Al-Qur\'an',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\u0627\u0644\u0644\u0651\u064e\u0647\u064f\u0645\u0651\u064e \u0627\u0631\u0652\u062d\u064e\u0645\u0652\u0646\u0650\u064a \u0628\u0650\u0627\u0644\u0652\u0642\u064f\u0631\u0652\u0622\u0646\u0650 \u0648\u064e\u0627\u062c\u0652\u0639\u064e\u0644\u0652\u0647\u064f \u0644\u0650\u064a \u0625\u0650\u0645\u064e\u0627\u0645\u064b\u0627 \u0648\u064e\u0646\u064f\u0648\u0631\u064b\u0627 \u0648\u064e\u0647\u064f\u062f\u064b\u0649 \u0648\u064e\u0631\u064e\u062d\u0652\u0645\u064e\u0629\u064b',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '"Allahummarhamni bil quran, waj\'alhu li imaman wa nuran wa hudan wa rohmah."',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ya Allah, rahmatilah aku dengan Al-Qur\'an. Jadikanlah ia sebagai pemimpin, cahaya, petunjuk, dan rahmat bagiku.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoButton.filled(
                child: Text(AppStrings.done),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          if (widget.juzNumber > 1)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) =>
                          JuzReaderScreen(juzNumber: widget.juzNumber - 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderSubtle
                          : CupertinoColors.systemGrey4,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.chevron_left,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Juz ${widget.juzNumber - 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (widget.juzNumber > 1 && widget.juzNumber < 30)
            const SizedBox(width: 12),
          if (widget.juzNumber < 30)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (_) =>
                          JuzReaderScreen(juzNumber: widget.juzNumber + 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Juz ${widget.juzNumber + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: CupertinoColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 360,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark
                : CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Pengaturan Baca',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingToggle('Teks Arab', _showArab, isDark, (v) {
                  setState(() => _showArab = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildSettingToggle('Teks Latin', _showLatin, isDark, (v) {
                  setState(() => _showLatin = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildSettingToggle('Terjemahan', _showTerjemahan, isDark, (v) {
                  setState(() => _showTerjemahan = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildSettingToggle('Mode Hafalan', _hafalanMode, isDark, (v) {
                  setState(() => _hafalanMode = v);
                  if (!v) _revealedAyatIds.clear();
                  setModalState(() {});
                  _saveSettings();
                }),
                const SizedBox(height: 16),
                Text(
                  'Ukuran Arab',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final size in [18.0, 22.0, 24.0, 28.0, 32.0])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _arabFontSize = size);
                            setModalState(() {});
                            _saveSettings();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _arabFontSize == size
                                  ? AppColors.primary
                                  : const Color(
                                      0xFF1E3A8A,
                                    ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${size.toInt()}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _arabFontSize == size
                                    ? CupertinoColors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingToggle(
    String label,
    bool value,
    bool isDark,
    void Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _JuzSurahData {
  final int surahId;
  final String namaLatin;
  final String nama;
  final List<Ayat> ayat;

  _JuzSurahData({
    required this.surahId,
    required this.namaLatin,
    required this.nama,
    required this.ayat,
  });
}
