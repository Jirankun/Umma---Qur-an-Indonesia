import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import 'package:provider/provider.dart';
import '../../models/quran.dart';
import '../../providers/quran_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/background_sound_provider.dart';
import '../../services/quran_tracker_service.dart';
import '../../utils/date_helper.dart';
import 'surah_reader_screen.dart';
import 'juz_reader_screen.dart';
import 'widgets/khatam_plan_widget.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  int _activeTab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showBookmarksOnly = false;
  bool _autoScrolled = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<QuranProvider>();
      if (provider.surahs.isEmpty) provider.loadSurahs();
      provider.loadStoredData().then((_) => _scrollToLastRead());
    });
  }

  void _scrollToLastRead() {
    if (_autoScrolled) return;
    final provider = context.read<QuranProvider>();
    final lastRead = provider.lastRead;
    if (lastRead == null) return;

    // Find the index of the last read surah in the filtered list
    final surahs = _filteredSurahs(provider.surahs);
    final index = surahs.indexWhere((s) => s.nomor == lastRead.surahId);
    if (index < 0) return;

    // Calculate approximate offset:
    // Header: ~400px (banner + search + tabs + khatam + filter chips + download)
    // Per item: ~78px (margin + padding + content)
    final headerHeight = 400.0;
    final itemHeight = 78.0;
    final offset = headerHeight + (index * itemHeight) - 100; // offset for visibility

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _autoScrolled = true;
        _scrollController.animateTo(
          offset.clamp(0.0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<QuranBookmark> get _filteredBookmarks {
    final all = context.read<QuranProvider>().bookmarks;
    if (_searchQuery.isEmpty) return all;
    return all
        .where(
          (b) =>
              b.surahName.toLowerCase().contains(_searchQuery) ||
              'ayat ${b.ayahNumber}'.contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<QuranProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.book_fill, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text("Al-Qur'an"),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _showHeatmap(context, isDark),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.chart_bar_fill,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: provider.loading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : _buildContent(context, isDark, provider),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    QuranProvider provider,
  ) {
    final lastRead = provider.lastRead;
    final bookmarks = provider.bookmarks;
    final bookmarkCount = bookmarks.length;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (lastRead != null && !_showBookmarksOnly)
          SliverToBoxAdapter(child: _buildLastReadBanner(isDark, lastRead)),
        SliverToBoxAdapter(child: _buildSearchBar(isDark)),
        if (!_showBookmarksOnly)
          SliverToBoxAdapter(child: _buildTabSelector(isDark)),
        if (!_showBookmarksOnly)
          SliverToBoxAdapter(child: _buildKhatamPlan(isDark)),
        // ─── Filter Chip: Semua vs Bookmark ───
        SliverToBoxAdapter(
          child: _buildBookmarkFilter(isDark, bookmarkCount),
        ),
        if (!_showBookmarksOnly && _activeTab == 0)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            sliver: SliverToBoxAdapter(
              child: _buildDownloadAllBanner(isDark, provider),
            ),
          ),
        // ─── Mode: Daftar Surah ───
        if (!_showBookmarksOnly && _activeTab == 0)
          _filteredSurahs(provider.surahs).isEmpty && _searchQuery.isNotEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptySearch(isDark, 'surah'),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final filtered = _filteredSurahs(provider.surahs);
                      if (index >= filtered.length) return null;
                      return _buildSurahItem(isDark, filtered[index]);
                    }, childCount: _filteredSurahs(provider.surahs).length),
                  ),
                )
        // ─── Mode: Daftar Juz ───
        else if (!_showBookmarksOnly)
          _buildJuzGrid(isDark)
        // ─── Mode: Daftar Bookmark ───
        else
          _buildBookmarkList(isDark),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildBookmarkFilter(bool isDark, int bookmarkCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          _BookmarkFilterChip(
            label: 'Semua Surah',
            isActive: !_showBookmarksOnly,
            count: context.read<QuranProvider>().surahs.length,
            isDark: isDark,
            onTap: () => setState(() => _showBookmarksOnly = false),
          ),
          const SizedBox(width: 10),
          _BookmarkFilterChip(
            label: 'Bookmark',
            isActive: _showBookmarksOnly,
            count: bookmarkCount,
            isDark: isDark,
            onTap: () => setState(() => _showBookmarksOnly = true),
          ),
          const Spacer(),
          if (bookmarkCount > 0)
            Text(
              '$bookmarkCount tersimpan',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkList(bool isDark) {
    final filtered = _filteredBookmarks;

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _searchQuery.isNotEmpty
                      ? CupertinoIcons.search
                      : CupertinoIcons.bookmark,
                  size: 48,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 12),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Bookmark tidak ditemukan'
                      : 'Belum ada ayat yang di-bookmark',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Coba kata kunci lain'
                      : 'Tap icon bookmark di setiap ayat untuk menyimpan',
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
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final b = filtered[index];
          final provider = context.read<QuranProvider>();
          final surah = provider.surahs
              .where((s) => s.nomor == b.surahId)
              .firstOrNull;
          return _buildBookmarkItem(isDark, b, surah, provider);
        }, childCount: filtered.length),
      ),
    );
  }

  Widget _buildBookmarkItem(
    bool isDark,
    QuranBookmark b,
    Surah? surah,
    QuranProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (_) => SurahReaderScreen(
                surahId: b.surahId,
                ayahNumber: b.ayahNumber,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? AppColors.textLight
                  : CupertinoColors.systemGrey6,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.heat4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.bookmark_fill,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.surahName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? CupertinoColors.white
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ayat ${b.ayahNumber} ${surah != null ? "• ${surah.jumlahAyat} Ayat" : ""}',
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
              if (surah != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    surah.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              GestureDetector(
                onTap: () async {
                  await provider.removeBookmark(b.surahId, b.ayahNumber);
                  setState(() {});
                },
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    CupertinoIcons.trash,
                    size: 16,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Surah> _filteredSurahs(List<Surah> surahs) {
    if (_searchQuery.isEmpty) return surahs;
    return surahs
        .where(
          (s) =>
              s.namaLatin.toLowerCase().contains(_searchQuery) ||
              s.arti.toLowerCase().contains(_searchQuery),
        )
        .toList();
  }

  Widget _buildEmptySearch(bool isDark, String type) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan $type untuk "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 18,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CupertinoTextField(
                controller: _searchController,
                placeholder: _showBookmarksOnly
                    ? 'Cari bookmark...'
                    : (_activeTab == 0 ? 'Cari surah...' : 'Cari Juz (1-30)...'),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? CupertinoColors.white
                      : AppColors.textLight,
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v.toLowerCase()),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                child: const Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 18,
                  color: CupertinoColors.systemGrey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(2, (i) {
            final isActive = _activeTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _activeTab = i;
                  _searchController.clear();
                  _searchQuery = '';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isDark
                              ? AppColors.surfaceDark
                              : CupertinoColors.white)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    i == 0 ? 'Surah' : 'Juz',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? AppColors.primary
                          : (isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildKhatamPlan(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: KhatamPlanWidget(isDark: isDark),
    );
  }

  Widget _buildJuzGrid(bool isDark) {
    final filteredJuz = List.generate(30, (i) => i + 1).where((j) {
      if (_searchQuery.isEmpty) return true;
      return 'juz $j'.contains(_searchQuery);
    }).toList();

    if (filteredJuz.isEmpty && _searchQuery.isNotEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptySearch(isDark, 'juz'),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final juz = filteredJuz[index];
          return GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => JuzReaderScreen(juzNumber: juz),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.textLight
                      : CupertinoColors.systemGrey6,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.book_fill,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Juz $juz',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: filteredJuz.length),
      ),
    );
  }

  Widget _buildLastReadBanner(bool isDark, LastRead lastRead) {
    final provider = context.read<QuranProvider>();
    final surah = provider.surahs
        .where((s) => s.nomor == lastRead.surahId)
        .firstOrNull;
    final totalAyat = surah?.jumlahAyat ?? 0;
    final progressText = totalAyat > 0
        ? 'Ayat ${lastRead.ayahNumber} dari $totalAyat'
        : 'Ayat ${lastRead.ayahNumber}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: GestureDetector(
        onTap: () async {
          await context.read<BackgroundSoundProvider>().stop();
          if (!mounted) return;
          final isJuz = lastRead.isJuz && lastRead.juzNumber != null;
          if (isJuz) {
            if (!mounted) return;
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => JuzReaderScreen(
                  juzNumber: lastRead.juzNumber!,
                  focusSurahId: lastRead.surahId,
                  focusAyahNumber: lastRead.ayahNumber,
                ),
              ),
            );
          } else {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => SurahReaderScreen(
                  surahId: lastRead.surahId,
                  ayahNumber: lastRead.ayahNumber,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.book_fill,
                  size: 20,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'TERAKHIR DIBACA',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: CupertinoColors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateHelper.relativeTime(lastRead.lastReadAt),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lastRead.surahName} — $progressText',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => context.read<QuranProvider>().clearLastRead(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadAllBanner(bool isDark, QuranProvider provider) {
    if (provider.surahs.isEmpty) return const SizedBox.shrink();
    final allDownloaded =
        provider.downloadedSurahCount >= provider.surahs.length;
    final isDownloading = provider.downloadAllMode;
    final isWaitingForInternet = provider.waitingForInternet;
    final progress = provider.downloadAllProgress;
    final total = provider.downloadAllTotal;
    final fraction = provider.downloadAllProgressFraction;

    return GestureDetector(
      onTap: isDownloading || allDownloaded || isWaitingForInternet
          ? null
          : () => provider.downloadAllSurahs(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: allDownloaded
              ? AppColors.heat4.withValues(alpha: 0.08)
              : (isWaitingForInternet
                    ? CupertinoColors.systemOrange.withValues(alpha: 0.08)
                    : (isDark
                          ? AppColors.surfaceDark
                          : CupertinoColors.white)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: allDownloaded
                ? AppColors.heat4.withValues(alpha: 0.3)
                : (isWaitingForInternet
                      ? CupertinoColors.systemOrange.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.15)),
          ),
        ),
        child: isWaitingForInternet
            ? Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withValues(
                        alpha: 0.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.wifi_slash,
                      size: 12,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menunggu internet...',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? CupertinoColors.white
                                : AppColors.textLight,
                          ),
                        ),
                        Text(
                          'Aktifkan koneksi untuk melanjutkan download',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: const Text(
                      'Coba Lagi',
                      style: TextStyle(fontSize: 12),
                    ),
                    onPressed: () => provider.downloadAllSurahs(),
                  ),
                ],
              )
            : (isDownloading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CupertinoActivityIndicator(radius: 8),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Mengunduh surah...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? CupertinoColors.white
                                      : AppColors.textLight,
                                ),
                              ),
                            ),
                            Text(
                              '$progress/$total',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey5,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: fraction.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          allDownloaded
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.cloud_download_fill,
                          size: 20,
                          color: allDownloaded
                              ? AppColors.heat4
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            allDownloaded
                                ? 'Semua surah tersimpan (${provider.downloadedSurahCount})'
                                : 'Download Semua Surah (${provider.downloadedSurahCount}/${provider.surahs.length})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: allDownloaded
                                  ? AppColors.heat4
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        if (!allDownloaded)
                          const Icon(
                            CupertinoIcons.chevron_forward,
                            size: 14,
                            color: AppColors.primary,
                          ),
                      ],
                    )),
      ),
    );
  }

  Widget _buildSurahItem(bool isDark, Surah surah) {
    final provider = context.read<QuranProvider>();
    final isDownloaded = provider.isSurahDownloaded(surah.nomor);

    return FutureBuilder<bool>(
      future: provider.isSurahAudioDownloaded(surah.nomor),
      initialData: false,
      builder: (ctx, snap) {
        final audioReady = snap.data ?? false;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (_) => SurahReaderScreen(surahId: surah.nomor),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppColors.textLight
                      : CupertinoColors.systemGrey6,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: audioReady
                          ? AppColors.heat4.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      audioReady
                          ? CupertinoIcons.cloud_download_fill
                          : CupertinoIcons.doc_text,
                      size: 18,
                      color: audioReady
                          ? AppColors.heat4
                          : AppColors.primary,
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
                              surah.namaLatin,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? CupertinoColors.white
                                    : AppColors.textLight,
                              ),
                            ),
                            if (audioReady) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                CupertinoIcons.cloud_download_fill,
                                size: 14,
                                color: AppColors.accent,
                              ),
                            ] else if (isDownloaded) ...[
                              const SizedBox(width: 6),
                              const Icon(
                                CupertinoIcons.doc_checkmark_fill,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${surah.arti} • ${surah.tempatTurun} • ${surah.jumlahAyat} Ayat',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        surah.nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      if (audioReady)
                        Text(
                          'Audio',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.heat4,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showHeatmap(BuildContext context, bool isDark) {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (_) => _HeatmapScreen(isDark: isDark)));
  }


}

// ─── HEATMAP SCREEN ──────────────────────────────────────────
class _HeatmapScreen extends StatefulWidget {
  final bool isDark;
  const _HeatmapScreen({required this.isDark});

  @override
  State<_HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<_HeatmapScreen> {
  Map<String, int> _history = {};
  int? _selectedDay;
  int _selectedDaySeconds = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await QuranTrackerService().getReadingHistory();
    if (mounted) {
      setState(() {
        _history = history;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final months = [
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
    final monthName = months[month - 1];

    String fmt(int s) {
      if (s < 60) return '$s detik';
      if (s < 3600) return '${s ~/ 60} menit';
      return '${s ~/ 3600} jam ${(s % 3600) ~/ 60} menit';
    }

    Color heatColor(int s) {
      if (s == 0) return CupertinoColors.systemGrey6;
      if (s < 180) return AppColors.heat1;
      if (s < 900) return AppColors.accentLight;
      if (s < 1800) return AppColors.toolTeal;
      return AppColors.heat4;
    }

    return CupertinoPageScaffold(
      backgroundColor: widget.isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: widget.isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text('Statistik Bacaan $monthName'),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator(radius: 14))
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                            ),
                        itemCount: daysInMonth,
                        itemBuilder: (context, index) {
                          final day = index + 1;
                          final ds =
                              '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          final secs = _history[ds] ?? 0;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedDay = day;
                              _selectedDaySeconds = secs;
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: heatColor(secs),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _selectedDay == day
                                      ? AppColors.primary
                                      : CupertinoColors.systemGrey5.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: _selectedDay == day ? 2 : 0.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$day',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: secs > 0
                                        ? CupertinoColors.white
                                        : CupertinoColors.systemGrey,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sedikit',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        ...[0, 1, 2, 3, 4].map(
                          (i) => Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: heatColor(i * 600),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Banyak',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: widget.isDark
                            ? AppColors.surfaceDark
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: widget.isDark
                              ? AppColors.textLight
                              : CupertinoColors.systemGrey6,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _selectedDay != null
                                ? '$_selectedDay $monthName $year'
                                : 'Ketuk kotak untuk detail',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_selectedDay != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Waktu baca: ${fmt(_selectedDaySeconds)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.isDark
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─── FILTER CHIP ─────────────────────────────────────────────
class _BookmarkFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  const _BookmarkFilterChip({
    required this.label,
    required this.isActive,
    required this.count,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark
                    ? AppColors.textLight
                    : CupertinoColors.systemGrey6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? CupertinoColors.white
                    : (isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? CupertinoColors.white.withValues(alpha: 0.25)
                      : (isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey)
                            .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? CupertinoColors.white
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
