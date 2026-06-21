import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../models/hadits.dart';
import '../../providers/hadits_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';
import '../../services/local_storage.dart';
import '../../config/api_config.dart';

class HaditsHomeScreen extends StatefulWidget {
  const HaditsHomeScreen({super.key});

  @override
  State<HaditsHomeScreen> createState() => _HaditsHomeScreenState();
}

class _HaditsHomeScreenState extends State<HaditsHomeScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showBookmarksOnly = false;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HaditsProvider>().loadBooks();
    });
  }

  Future<void> _loadBookmarks() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyHaditsBookmarks,
    );
    if (data is List) {
      setState(() => _bookmarks = data.cast<Map<String, dynamic>>());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HaditsBook> get _filteredBooks {
    final provider = context.read<HaditsProvider>();
    if (_searchQuery.isEmpty) return provider.books;
    final query = _searchQuery.toLowerCase();
    return provider.books.where((book) {
      return book.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<HaditsProvider>(context);
    final books = _filteredBooks;

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
            Icon(
              CupertinoIcons.doc_text_fill,
              size: 18,
              color: AppColors.accent,
            ),
            SizedBox(width: 8),
            Text(AppStrings.haditsPilihan),
          ],
        ),
        trailing: _bookmarks.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.heat4.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_bookmarks.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.heat4,
                    ),
                  ),
                ),
              )
            : null,
      ),
      child: SafeArea(child: _buildBody(isDark, provider, books)),
    );
  }

  Widget _buildBody(bool isDark, HaditsProvider provider, List<HaditsBook> books) {
    if (provider.loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (provider.error != null && provider.books.isEmpty && !_showBookmarksOnly) {
      return _buildOfflineView(isDark);
    }

    return Column(
      children: [
        // ─── Filter chips ───
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              _FilterChip(
                label: AppStrings.haditsKitab,
                isActive: !_showBookmarksOnly,
                count: provider.books.length,
                isDark: isDark,
                onTap: () => setState(() => _showBookmarksOnly = false),
              ),
              const SizedBox(width: 10),
              _FilterChip(
                label: AppStrings.bookmark,
                isActive: _showBookmarksOnly,
                count: _bookmarks.length,
                isDark: isDark,
                onTap: () => setState(() => _showBookmarksOnly = true),
              ),
              const Spacer(),
            ],
          ),
        ),

        // ─── Content ───
        Expanded(
          child: _showBookmarksOnly
              ? _buildBookmarkList(isDark)
              : _buildBooksList(isDark, provider, books),
        ),
      ],
    );
  }

  Widget _buildBooksList(bool isDark, HaditsProvider provider, List<HaditsBook> books) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          sliver: SliverToBoxAdapter(child: _buildHeader(isDark)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= books.length) return null;
              final book = books[index];
              return _buildBookCard(context, isDark, book);
            }, childCount: books.length),
          ),
        ),
        if (books.isEmpty && _searchQuery.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.all(40),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.search,
                      size: 40,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${AppStrings.haditsNotFoundKitab} "$_searchQuery"',
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
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildBookmarkList(bool isDark) {
    if (_bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.bookmark,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.haditsNoBookmark,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.haditsNoBookmarkHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final bm = _bookmarks[index];
        final bookId = bm['bookId'] as String? ?? '';
        final bookName = bm['bookName'] as String? ?? '';
        final hadithNumber = bm['hadithNumber']?.toString() ?? '';
        final hadithText = bm['hadithText'] as String? ?? '';

        // Cari full book data dari provider
        final provider = context.read<HaditsProvider>();
        final book = provider.books.where((b) => b.id == bookId).firstOrNull;
        final fullBook = book ?? HaditsBook(
          id: bookId,
          name: bookName,
          totalHadith: 0,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => HaditsReaderScreen(
                    book: fullBook,
                    isDark: isDark,
                    highlightNumber: hadithNumber,
                  ),
                ),
              ).then((_) => _loadBookmarks());
            },
            child: Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.heat4.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$bookName • Hadits $hadithNumber',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        CupertinoIcons.bookmark_fill,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hadithText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfflineView(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.wifi_slash,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.haditsNeedConnection,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.haditsNeedConnectionDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
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

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [          Text(
          AppStrings.haditsKumpulan,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.haditsKitabDesc,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoSearchTextField(
          controller: _searchController,
          placeholder: AppStrings.haditsSearchKitab,
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
          onSuffixTap: () {
            _searchController.clear();
            setState(() => _searchQuery = '');
          },
        ),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, bool isDark, HaditsBook book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _readBook(context, book),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.heat4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.doc_text_fill,
                  size: 22,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
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
                      '${book.totalHadith} hadits',
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
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _readBook(BuildContext context, HaditsBook book) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => HaditsReaderScreen(
          book: book,
          isDark: isDark,
        ),
      ),
    ).then((_) => _loadBookmarks());
  }
}

// ─── Filter Chip ─────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
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
              ? AppColors.heat4
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

class HaditsReaderScreen extends StatefulWidget {
  final HaditsBook book;
  final bool isDark;
  final String? highlightNumber;
  final bool showArab;
  final bool showTranslation;
  final double arabFontSize;

  const HaditsReaderScreen({
    super.key,
    required this.book,
    required this.isDark,
    this.highlightNumber,
    this.showArab = true,
    this.showTranslation = true,
    this.arabFontSize = 20,
  });

  @override
  State<HaditsReaderScreen> createState() => _HaditsReaderScreenState();
}

class _HaditsReaderScreenState extends State<HaditsReaderScreen> {
  List<HaditsItem> _hadiths = [];
  bool _loading = false;
  String? _error;
  final _scrollController = ScrollController();
  // Bookmark state
  Set<String> _bookmarkedNumbers = {};
  // Search state
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showSearch = false;
  // Reader settings (mutable — seperti Quran reader)
  bool _showArab = true;
  bool _showTranslation = true;
  double _arabFontSize = 20;
  // Scroll highlight
  bool _highlightScrollInitiated = false;
  GlobalKey? _highlightHadithKey;
  int _highlightRetries = 0;

  static const int _fetchLimit = 9999;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadReaderSettings();
    _loadBookmarks();
    _fetchHadiths();
  }

  Future<void> _loadReaderSettings() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyHaditsSettings,
    );
    if (data is Map) {
      setState(() {
        _showArab = (data['showArab'] as bool?) ?? widget.showArab;
        _showTranslation =
            (data['showTranslation'] as bool?) ?? widget.showTranslation;
        _arabFontSize =
            (data['arabFontSize'] as num?)?.toDouble() ?? widget.arabFontSize;
      });
    }
  }

  Future<void> _saveReaderSettings() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyHaditsSettings, {
      'showArab': _showArab,
      'showTranslation': _showTranslation,
      'arabFontSize': _arabFontSize,
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initiateScrollToHighlight() {
    if (_highlightScrollInitiated || widget.highlightNumber == null) return;
    if (_hadiths.isEmpty) return;

    final index = _hadiths.indexWhere(
      (h) => h.number == widget.highlightNumber,
    );
    if (index < 0) return;

    _highlightScrollInitiated = true;
    _highlightHadithKey = GlobalKey();
    _highlightRetries = 0;

    // Lompat ke estimasi posisi SEKALI saja
    // (jangan jump tiap frame — itu bikin scroll terasa stuck)
    if (_scrollController.hasClients && _hadiths.isNotEmpty) {
      final ratio = index / _hadiths.length;
      final maxExt = _scrollController.position.maxScrollExtent;
      _scrollController.jumpTo((ratio * maxExt).clamp(0.0, maxExt));
    }

    // Lanjut cek apakah widget highlight sudah ter-render
    _tryScrollToHighlight();
  }

  void _tryScrollToHighlight() {
    if (!mounted || _highlightRetries >= 30) {
      _highlightRetries = 0;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_highlightHadithKey?.currentContext != null) {
        // Ketemu! Scroll halus ke item
        Scrollable.ensureVisible(
          _highlightHadithKey!.currentContext!,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
        _highlightRetries = 0;
        return;
      }

      _highlightRetries++;

      // Jangan jump posisi tiap frame — biarkan user bisa scroll
      // Kalau item belum ter-render, ListView akan membangunnya
      // saat user scroll atau saat frame berikutnya setelah jump awal

      _tryScrollToHighlight();
    });
  }

  Future<void> _loadBookmarks() async {
    final storage = LocalStorage();
    final json = await storage.getJson(ApiConfig.storageKeyHaditsBookmarks);
    if (json != null) {
      setState(() {
        _bookmarkedNumbers = (json as List)
            .where((b) => b['bookId'] == widget.book.id)
            .map((b) => b['hadithNumber'].toString())
            .toSet();
      });
    }
  }

  Future<void> _toggleBookmark(HaditsItem hadith) async {
    final number = hadith.number;
    final wasBookmarked = _bookmarkedNumbers.contains(number);

    // Update UI IMMEDIATELY — seperti Quran reader
    setState(() {
      if (wasBookmarked) {
        _bookmarkedNumbers.remove(number);
      } else {
        _bookmarkedNumbers.add(number);
      }
    });

    // Persist ke storage (async, I/O di background)
    final storage = LocalStorage();
    final json = await storage.getJson(ApiConfig.storageKeyHaditsBookmarks);
    List bookmarks = json is List ? json : [];

    if (wasBookmarked) {
      bookmarks.removeWhere((b) =>
          b['bookId'] == widget.book.id &&
          b['hadithNumber'].toString() == number);
    } else {
      bookmarks.add({
        'bookId': widget.book.id,
        'bookName': widget.book.name,
        'hadithNumber': number,
        'hadithText': hadith.translatedId,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }

    await storage.saveJson(ApiConfig.storageKeyHaditsBookmarks, bookmarks);
  }

  Future<void> _fetchHadiths() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getHadithRange(
        book: widget.book.id,
        page: 1,
        limit: _fetchLimit,
      );
      setState(() {
        _hadiths = (data['items'] as List? ?? [])
            .map((h) => HaditsItem.fromJson(h, bookSlug: widget.book.id))
            .toList();
      });
    } catch (e) {
      setState(() => _error = AppStrings.haditsNeedConnection);
    }
    setState(() => _loading = false);

    // Initiate scroll ke highlight setelah data siap
    if (widget.highlightNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initiateScrollToHighlight();
      });
    }
  }

  @override
  void didUpdateWidget(HaditsReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightNumber != oldWidget.highlightNumber) {
      _highlightScrollInitiated = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initiateScrollToHighlight();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: widget.isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: widget.isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.book.name),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              }),
              child: Icon(
                _showSearch
                    ? CupertinoIcons.xmark_circle_fill
                    : CupertinoIcons.search,
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _showReaderSettings(context),
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
      ),
      child: SafeArea(child: _buildReaderBody()),
    );
  }

  Widget _buildReaderBody() {
    if (_loading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.wifi_slash,
                size: 48,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hadits dimuat dari server.\nPastikan terhubung ke internet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: widget.isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                onPressed: _fetchHadiths,
                child: Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    // Filter by search query
    final displayHadiths = _searchQuery.isEmpty
        ? _hadiths
        : _hadiths.where((h) {
            final q = _searchQuery.toLowerCase();
            return h.number.toLowerCase().contains(q) ||
                h.translatedId.toLowerCase().contains(q) ||
                h.arab.toLowerCase().contains(q);
          }).toList();

    return Column(
      children: [
        // Search bar (togglable)
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: AppStrings.haditsSearchHadits,
              style: TextStyle(
                color: widget.isDark ? AppColors.textDark : AppColors.textLight,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
              onSuffixTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
          ),
        // Results count
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${displayHadiths.length} hadits ditemukan',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
        Expanded(
          child: displayHadiths.isEmpty && _searchQuery.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 40,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${AppStrings.haditsNotFound} "$_searchQuery"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: displayHadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = displayHadiths[index];
                    final isHighlighted =
                        widget.highlightNumber != null &&
                        hadith.number == widget.highlightNumber;
                    final isBm = _bookmarkedNumbers.contains(hadith.number);
                    final highlightKey = isHighlighted ? _highlightHadithKey : null;
                    return Container(
                      key: highlightKey,
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? (widget.isDark
                                  ? AppColors.accentBgDark
                                  : AppColors.accentBgLight)
                            : (widget.isDark
                                  ? AppColors.surfaceDark
                                  : CupertinoColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isHighlighted
                              ? AppColors.heat4.withValues(alpha: 0.6)
                              : (widget.isDark
                                    ? AppColors.textLight
                                    : CupertinoColors.systemGrey6),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.heat4.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Hadits ${hadith.number}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _toggleBookmark(hadith),
                                child: Icon(
                                  isBm
                                      ? CupertinoIcons.bookmark_fill
                                      : CupertinoIcons.bookmark,
                                  size: 18,
                                  color: isBm
                                      ? AppColors.accent
                                      : CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                          if (_showArab) ...[
                            const SizedBox(height: 12),
                            _buildHighlightedText(
                              hadith.arab,
                              _searchQuery,
                              isArabic: true,
                              isDark: widget.isDark,
                            ),
                          ],
                          if (_showTranslation) ...[
                            const SizedBox(height: 12),
                            _buildHighlightedText(
                              hadith.translatedId,
                              _searchQuery,
                              isArabic: false,
                              isDark: widget.isDark,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showReaderSettings(BuildContext context) {
    final isDark = widget.isDark;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 300,
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
                  AppStrings.quranSettings,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.quranSettingArab,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? CupertinoColors.white : AppColors.textLight,
                        ),
                      ),
                      CupertinoSwitch(
                        value: _showArab,
                        onChanged: (v) {
                          setState(() => _showArab = v);
                          setModalState(() {});
                          _saveReaderSettings();
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.quranSettingTerjemahan,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? CupertinoColors.white : AppColors.textLight,
                        ),
                      ),
                      CupertinoSwitch(
                        value: _showTranslation,
                        onChanged: (v) {
                          setState(() => _showTranslation = v);
                          setModalState(() {});
                          _saveReaderSettings();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.quranSettingFontSize,
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
                    for (final size in [16.0, 20.0, 24.0, 28.0, 32.0])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _arabFontSize = size);
                            setModalState(() {});
                            _saveReaderSettings();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _arabFontSize == size
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.1),
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

  /// Bangun widget teks dengan highlight pada kata yang cocok dengan [_searchQuery]
  Widget _buildHighlightedText(
    String text,
    String query, {
    required bool isArabic,
    required bool isDark,
  }) {
    if (query.isEmpty) {
      // Tanpa query — pakai Text biasa (lebih ringan)
      if (isArabic) {
        return Text(
          text,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: _arabFontSize,
            fontWeight: FontWeight.w500,
            height: 1.6,
            fontFamily: 'Lateef',
            color: isDark ? CupertinoColors.white : AppColors.textLight,
          ),
        );
      }
      return Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: isDark ? CupertinoColors.white : AppColors.textLight,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    if (!lowerText.contains(lowerQuery)) {
      // Tidak ada yang cocok — tetap return Text biasa
      if (isArabic) {
        return Text(
          text,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: _arabFontSize,
            fontWeight: FontWeight.w500,
            height: 1.6,
            fontFamily: 'Lateef',
            color: isDark ? CupertinoColors.white : AppColors.textLight,
          ),
        );
      }
      return Text(
        text,
        style: TextStyle(
          fontSize: 13,
          height: 1.5,
          color: isDark ? CupertinoColors.white : AppColors.textLight,
        ),
      );
    }

    final baseStyle = isArabic
        ? TextStyle(
            fontSize: _arabFontSize,
            fontWeight: FontWeight.w500,
            height: 1.6,
            fontFamily: 'Lateef',
            color: isDark ? CupertinoColors.white : AppColors.textLight,
          )
        : TextStyle(
            fontSize: 13,
            height: 1.5,
            color: isDark ? CupertinoColors.white : AppColors.textLight,
          );

    final highlightStyle = baseStyle.copyWith(
      backgroundColor: AppColors.searchHighlight,
      color: AppColors.searchHighlightText,
    );

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        // Sisa teks tanpa highlight
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      // Teks sebelum match
      if (idx > start) {
        spans.add(TextSpan(
          text: text.substring(start, idx),
          style: baseStyle,
        ));
      }

      // Teks yang match — pakai highlight
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: highlightStyle,
      ));

      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
    );
  }

}
