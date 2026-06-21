import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../models/quran.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_storage.dart';
import '../../services/quran_tracker_service.dart';
import '../../services/api_service.dart';
import '../../services/quran_download_service.dart';

class SurahReaderScreen extends StatefulWidget {
  final int surahId;
  final int? ayahNumber;
  final int? referenceAyahNumber; // dari AI — highlight kuning

  const SurahReaderScreen({
    super.key,
    required this.surahId,
    this.ayahNumber,
    this.referenceAyahNumber,
  });

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  bool _showArab = true;
  bool _showLatin = true;
  bool _showTerjemahan = true;
  double _arabFontSize = 24;
  bool _hafalanMode = false;
  final Set<String> _revealedAyatIds = {};
  List<QuranBookmark> _bookmarks = [];
  final Map<int, Map<int, String>> _tafsirCache = {};

  // Scroll & highlight
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToTarget = false;
  int? _targetAyahNumber;
  int _scrollRetries = 0;
  bool _scrollInitiated = false;
  GlobalKey? _targetAyatKey;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _targetAyahNumber = widget.referenceAyahNumber ?? widget.ayahNumber;
    _loadSettings();
    _loadBookmarks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahDetail(widget.surahId);
    });
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
    final json = await LocalStorage().getJson(
      ApiConfig.storageKeyQuranBookmarks,
    );
    if (json != null) {
      _bookmarks = (json as List)
          .map((b) => QuranBookmark.fromJson(b))
          .toList();
    }
  }

  Future<void> _saveBookmarks() async {
    await LocalStorage().saveJson(
      ApiConfig.storageKeyQuranBookmarks,
      _bookmarks.map((b) => b.toJson()).toList(),
    );
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    Future.microtask(() {
      if (mounted) {
        context.read<QuranProvider>().disposeAudio();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<QuranProvider>(context);
    final surah = provider.selectedSurah;
    final progress = provider.currentProgress;
    final isDownloading = progress?.isDownloading ?? false;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text(surah?.namaLatin ?? 'Memuat...'),
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
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showQariPicker(context, provider),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.person_fill,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.selectedQariName.split(' ').last,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            if (progress?.isComplete == true)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  CupertinoIcons.cloud_download_fill,
                  size: 16,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
      child: SafeArea(
        child: _buildBody(context, isDark, provider, progress, isDownloading),
      ),
    );
  }

  void _showQariPicker(BuildContext context, QuranProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _QariPickerSheet(
        currentQariId: provider.selectedQariId,
        onSelect: (qariId) => provider.setSelectedQari(qariId),
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

  Widget _buildBody(
    BuildContext context,
    bool isDark,
    QuranProvider provider,
    SurahDownloadProgress? progress,
    bool isDownloading,
  ) {
    if (provider.loadingAyat && progress?.jsonDone != true) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    final surah = provider.selectedSurah;
    if (surah == null) {
      if (provider.error != null) {
        final isNetworkError =
            provider.error!.toLowerCase().contains('gagal') ||
            provider.error!.toLowerCase().contains('koneksi') ||
            provider.error!.toLowerCase().contains('internet') ||
            provider.error!.toLowerCase().contains('timeout') ||
            provider.error!.toLowerCase().contains('host');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isNetworkError
                      ? CupertinoIcons.wifi_slash
                      : CupertinoIcons.exclamationmark_triangle_fill,
                  size: 48,
                  color: isNetworkError
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemRed,
                ),
                const SizedBox(height: 16),
                Text(
                  isNetworkError ? 'Internet Tidak Tersedia' : 'Gagal Memuat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isNetworkError
                      ? 'Aktifkan internet untuk memuat Surah "${_getSurahNameFallback()}" dari server'
                      : provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 20),
                CupertinoButton.filled(
                  child: Text(AppStrings.retry),
                  onPressed: () => provider.loadSurahDetail(widget.surahId),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox();
    }

    // ─── Initiate scroll ke ayat target (sekali, saat data siap) ───
    if (_targetAyahNumber != null &&
        !_scrollInitiated &&
        !provider.loadingAyat &&
        provider.currentAyat.any((a) => a.nomorAyat == _targetAyahNumber)) {
      _scrollInitiated = true;
      _targetAyatKey = GlobalKey();
      _scrollRetries = 0;

      // Lompat ke posisi estimasi — hardcoded height (aggressive, langsung dekat target)
      final targetIndex = provider.currentAyat.indexWhere(
        (a) => a.nomorAyat == _targetAyahNumber,
      );
      if (targetIndex >= 0 && _scrollController.hasClients) {
        const ayahHeight = 220.0;
        const headerHeight = 180.0;
        final estimatedOffset = (headerHeight + targetIndex * ayahHeight)
            .clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.jumpTo(estimatedOffset);
      }

      // ensureVisible tiap frame sampai berhasil (max 60 frame)
      _tryScrollToTarget();
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // ─── Download All Audio button / progress ───
        SliverToBoxAdapter(
          child: _buildAudioSection(progress, isDownloading, isDark, surah, provider),
        ),
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
        SliverToBoxAdapter(child: _buildHeader(surah, isDark, provider)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= provider.currentAyat.length) return null;
              final ayat = provider.currentAyat[index];
              final isAudioReady = provider.isAyatAudioDownloaded(
                widget.surahId,
                ayat.nomorAyat,
              );
              final isPlaying =
                  provider.currentlyPlayingAyah == ayat.nomorAyat &&
                  provider.isPlaying;
              return _buildAyatItem(
                ayat,
                isDark,
                isAudioReady,
                isPlaying,
                provider,
                surah,
              );
            }, childCount: provider.currentAyat.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildAudioSection(
    SurahDownloadProgress? progress,
    bool isDownloading,
    bool isDark,
    Surah surah,
    QuranProvider provider,
  ) {
    final isComplete = progress?.isComplete ?? false;

    // Saat sedang mendownload — tampilkan progress bar
    if (isDownloading && progress != null) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CupertinoActivityIndicator(radius: 8),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mengunduh audio...',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ),
                Text(
                  '${progress.audioDownloaded}/${progress.audioTotal}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey5,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.audioProgress.clamp(0.0, 1.0),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Sudah lengkap — tampilkan badge hijau
    if (isComplete) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.heat4.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.heat4.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.check_mark_circled_solid,
              size: 20,
              color: AppColors.heat4,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Semua audio siap offline (${surah.jumlahAyat})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.heat4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Belum lengkap — tampilkan tombol Download All Audio
    return GestureDetector(
      onTap: () => provider.downloadAllAyatAudioForCurrentSurah(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.cloud_download_fill,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Download Semua Audio (${progress?.audioDownloaded ?? 0}/${surah.jumlahAyat})',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Surah surah, bool isDark, QuranProvider provider) {
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
          Text(
            surah.nama,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            surah.namaLatin,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${surah.arti} \u2022 ${surah.tempatTurun} \u2022 ${surah.jumlahAyat} Ayat',
            style: const TextStyle(fontSize: 12, color: CupertinoColors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.person_fill,
                  size: 12,
                  color: CupertinoColors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  'Qari: ${provider.selectedQariName}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyatItem(
    Ayat ayat,
    bool isDark,
    bool isAudioReady,
    bool isPlaying,
    QuranProvider provider,
    Surah surah,
  ) {
    final ayatId = '${widget.surahId}-${ayat.nomorAyat}';
    final isRevealed = _revealedAyatIds.contains(ayatId);
    final isBookmarked = _bookmarks.any(
      (b) => b.surahId == widget.surahId && b.ayahNumber == ayat.nomorAyat,
    );
    final isLanjutBaca =
        widget.ayahNumber != null && ayat.nomorAyat == widget.ayahNumber;
    final isAiReference =
        widget.referenceAyahNumber != null &&
        ayat.nomorAyat == widget.referenceAyahNumber;
    final isTargetAyat = isLanjutBaca || isAiReference;

    // Warna highlight: hijau untuk Lanjut Baca, kuning untuk AI reference
    final highlightBgLight = isLanjutBaca
        ? AppColors.accentBgLight
        : AppColors.warningBg;
    final highlightBgDark = isLanjutBaca
        ? AppColors.accentBgDark.withValues(alpha: 0.25)
        : AppColors.warningTextDark.withValues(alpha: 0.25);
    final highlightBorderLight = isLanjutBaca
        ? AppColors.heat4
        : AppColors.warning;
    final highlightBorderDark = isLanjutBaca
        ? AppColors.accentLight
        : AppColors.warningLight;
    final key = isTargetAyat ? _targetAyatKey : null;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTargetAyat
            ? (isDark ? highlightBgDark : highlightBgLight)
            : (isDark ? AppColors.surfaceDark : CupertinoColors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTargetAyat
              ? (isDark ? highlightBorderDark : highlightBorderLight)
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
                  if (isAudioReady ||
                      provider.getAyatAudioUrlForQari(ayat) != null)
                    GestureDetector(
                      onTap: () async {
                        if (isPlaying &&
                            provider.currentlyPlayingAyah == ayat.nomorAyat) {
                          await provider.pauseAudio();
                        } else if (provider.currentlyPlayingAyah ==
                                ayat.nomorAyat &&
                            !provider.isPlaying) {
                          await provider.resumeAudio();
                        } else {
                          await provider.playAyatAudio(widget.surahId, ayat);
                        }
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isPlaying
                              ? AppColors.heat4.withValues(alpha: 0.2)
                              : (isAudioReady
                                    ? const Color(
                                        0xFF059669,
                                      ).withValues(alpha: 0.1)
                                    : const Color(
                                        0xFF1E3A8A,
                                      ).withValues(alpha: 0.08)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isPlaying
                              ? CupertinoIcons.pause_circle_fill
                              : CupertinoIcons.play_circle_fill,
                          size: 18,
                          color: isPlaying || isAudioReady
                              ? AppColors.heat4
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _toggleBookmark(ayat, surah),
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
                    onTap: () => _showTafsir(ayat, surah),
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
                    onTap: () => _markLastRead(ayat, surah),
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

  void _toggleBookmark(Ayat ayat, Surah surah) {
    final existing = _bookmarks.any(
      (b) => b.surahId == widget.surahId && b.ayahNumber == ayat.nomorAyat,
    );
    if (existing) {
      _bookmarks.removeWhere(
        (b) => b.surahId == widget.surahId && b.ayahNumber == ayat.nomorAyat,
      );
      context.read<QuranProvider>().removeBookmark(
        widget.surahId,
        ayat.nomorAyat,
      );
    } else {
      final bookmark = QuranBookmark(
        surahId: widget.surahId,
        ayahNumber: ayat.nomorAyat,
        surahName: surah.namaLatin,
      );
      _bookmarks.add(bookmark);
      context.read<QuranProvider>().addBookmark(bookmark);
    }
    _saveBookmarks();
    setState(() {});
  }

  // ─── AUTO-SCROLL HELPER — scroll target ke tengah layar ──
  /// Scroll ke ayat target dengan retry tiap frame (max 60 frame / ~1 detik).
  /// Pakai rasio index/totalItems * maxScrollExtent agar estimasi makin akurat
  /// seiring bertambahnya item yang di-layout oleh SliverList.
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

      // Update estimasi scroll menggunakan rasio index/total * maxScrollExtent
      if (_scrollController.hasClients) {
        final provider = context.read<QuranProvider>();
        if (_targetAyahNumber != null && provider.currentAyat.isNotEmpty) {
          final idx = provider.currentAyat.indexWhere(
            (a) => a.nomorAyat == _targetAyahNumber,
          );
          if (idx >= 0) {
            final total = provider.currentAyat.length;
            final maxExt = _scrollController.position.maxScrollExtent;
            _scrollController.jumpTo(
              ((idx / total) * maxExt).clamp(0.0, maxExt),
            );
          }
        }
      }

      _tryScrollToTarget();
    });
  }

  // ─── TAFSIR ────────────────────────────────────────────────
  Future<({String tafsirText, String? sourceLabel})> _loadTafsir(
    Ayat ayat,
    Surah surah,
  ) async {
    try {
      if (!_tafsirCache.containsKey(widget.surahId)) {
        final data = await ApiService().getTafsir(widget.surahId);
        final List<dynamic> tafsirList = data['tafsir'] ?? [];
        final ayatMap = <int, String>{};
        for (final item in tafsirList) {
          final ayatNum = item['ayat'] as int? ?? 0;
          final teks = (item['teks'] as String? ?? '').trim();
          if (ayatNum > 0 && teks.isNotEmpty) {
            ayatMap[ayatNum] = teks;
          }
        }
        _tafsirCache[widget.surahId] = ayatMap;
      }

      final text = _tafsirCache[widget.surahId]?[ayat.nomorAyat] ?? '';
      return (
        tafsirText: text,
        sourceLabel: 'Tafsir ${surah.namaLatin} \u2014 Kemenag RI',
      );
    } catch (_) {
      return (tafsirText: '', sourceLabel: null);
    }
  }

  void _showTafsir(Ayat ayat, Surah surah) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    bool loading = true;
    String tafsirText = '';
    String? sourceLabel;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          if (loading) {
            _loadTafsir(ayat, surah).then((r) {
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
              surah: surah,
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
    required Surah surah,
    required String tafsirText,
    required String? sourceLabel,
  }) {
    if (loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    // Content state
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
                '${surah.namaLatin} \u2014 Ayat ${ayat.nomorAyat}',
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

  static const List<String> _surahNames = [
    '',
    'Al-Fatihah',
    'Al-Baqarah',
    'Ali Imran',
    'An-Nisa',
    "Al-Ma'idah",
    "Al-An'am",
    "Al-A'raf",
    'Al-Anfal',
    'At-Taubah',
    'Yunus',
    'Hud',
    'Yusuf',
    "Ar-Ra'd",
    'Ibrahim',
    'Al-Hijr',
    'An-Nahl',
    'Al-Isra',
    'Al-Kahf',
    'Maryam',
    'Ta Ha',
    'Al-Anbiya',
    'Al-Hajj',
    "Al-Mu'minun",
    'An-Nur',
    'Al-Furqan',
    "Asy-Syu'ara",
    'An-Naml',
    'Al-Qasas',
    'Al-Ankabut',
    'Ar-Rum',
    'Luqman',
    'As-Sajdah',
    'Al-Ahzab',
    'Saba',
    'Fatir',
    'Ya Sin',
    'As-Saffat',
    'Sad',
    'Az-Zumar',
    'Ghafir',
    'Fussilat',
    'Asy-Syura',
    'Az-Zukhruf',
    'Ad-Dukhan',
    'Al-Jasiyah',
    'Al-Ahqaf',
    'Muhammad',
    'Al-Fath',
    'Al-Hujurat',
    'Qaf',
    'Az-Zariyat',
    'At-Tur',
    'An-Najm',
    'Al-Qamar',
    'Ar-Rahman',
    "Al-Waqi'ah",
    'Al-Hadid',
    'Al-Mujadilah',
    'Al-Hasyr',
    'Al-Mumtahanah',
    'As-Saff',
    "Al-Jumu'ah",
    'Al-Munafiqun',
    'At-Taghabun',
    'At-Talaq',
    'At-Tahrim',
    'Al-Mulk',
    'Al-Qalam',
    'Al-Haqqah',
    "Al-Ma'arij",
    'Nuh',
    'Al-Jinn',
    'Al-Muzzammil',
    'Al-Muddassir',
    'Al-Qiyamah',
    'Al-Insan',
    'Al-Mursalat',
    'An-Naba',
    "An-Nazi'at",
    'Abasa',
    'At-Takwir',
    'Al-Infitar',
    'Al-Mutaffifin',
    'Al-Insyiqaq',
    'Al-Buruj',
    'At-Tariq',
    "Al-A'la",
    'Al-Gasyiyah',
    'Al-Fajr',
    'Al-Balad',
    'Asy-Syams',
    'Al-Lail',
    'Ad-Duha',
    'Asy-Syarh',
    'At-Tin',
    'Al-Alaq',
    'Al-Qadr',
    'Al-Bayyinah',
    'Az-Zalzalah',
    "Al-'Adiyat",
    "Al-Qari'ah",
    'At-Takasur',
    "Al-'Asr",
    'Al-Humazah',
    'Al-Fil',
    'Quraisy',
    "Al-Ma'un",
    'Al-Kausar',
    'Al-Kafirun',
    'An-Nasr',
    'Al-Lahab',
    'Al-Ikhlas',
    'Al-Falaq',
    'An-Nas',
  ];

  /// Get surah name fallback (dari provider atau widget.surahId)
  String _getSurahNameFallback() {
    final surah = context.read<QuranProvider>().selectedSurah;
    if (surah != null) return surah.namaLatin;
    if (widget.surahId >= 1 && widget.surahId <= 114) {
      return _surahNames[widget.surahId];
    }
    return 'Surah ${widget.surahId}';
  }

  // ─── BATAS BACAAN ─────────────────────────────────────────
  void _markLastRead(Ayat ayat, Surah surah) {
    final lastRead = LastRead(
      surahId: widget.surahId,
      surahName: surah.namaLatin,
      ayahNumber: ayat.nomorAyat,
    );
    context.read<QuranProvider>().saveLastRead(lastRead);
    _showSessionEndModal(ayat, surah);
  }

  void _showSessionEndModal(Ayat ayat, Surah surah) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;
    final totalAyah = QuranTrackerService.calculateAbsoluteAyah(
      widget.surahId,
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
}

class _QariPickerSheet extends StatefulWidget {
  final String currentQariId;
  final void Function(String) onSelect;

  const _QariPickerSheet({required this.currentQariId, required this.onSelect});

  @override
  State<_QariPickerSheet> createState() => _QariPickerSheetState();
}

class _QariPickerSheetState extends State<_QariPickerSheet> {
  final Set<String> _qariWithAudio = {};
  final _downloadService = QuranDownloadService();

  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
  }

  Future<void> _checkAudioStatus() async {
    final futures = ApiConfig.qariList.map((qari) async {
      try {
        final count = await _downloadService.countAudioForQari(qari['id']!);
        if (count > 0) return qari['id']!;
      } catch (_) {}
      return null;
    }).toList();
    final results = await Future.wait(futures);
    if (mounted) {
      setState(() {
        for (final id in results) {
          if (id != null) _qariWithAudio.add(id);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Pilih Qari',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(height: 1, color: CupertinoColors.systemGrey5),
          Expanded(
            child: ListView.builder(
              itemCount: ApiConfig.qariList.length,
              itemBuilder: (context, index) {
                final qari = ApiConfig.qariList[index];
                final isSelected = qari['id'] == widget.currentQariId;
                final hasAudio = _qariWithAudio.contains(qari['id']);
                return GestureDetector(
                  onTap: () {
                    widget.onSelect(qari['id']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : null,
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.systemGrey6,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : const Color(
                                    0xFF1E3A8A,
                                  ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? CupertinoColors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    qari['name']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? CupertinoColors.white
                                          : AppColors.textLight,
                                    ),
                                  ),
                                  if (hasAudio) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF059669,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            CupertinoIcons
                                                .check_mark_circled_solid,
                                            size: 10,
                                            color: AppColors.accent,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Audio',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.heat4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                qari['nameAr']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? CupertinoColors.systemGrey
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            size: 20,
                            color: AppColors.primary,
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
