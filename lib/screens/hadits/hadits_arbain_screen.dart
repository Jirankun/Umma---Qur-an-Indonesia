import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
import '../../config/api_config.dart';
import '../../data/hadits_arbain_data.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_storage.dart';
import 'package:provider/provider.dart';

class HaditsArbainScreen extends StatefulWidget {
  final int? highlightNumber;

  const HaditsArbainScreen({super.key, this.highlightNumber});

  @override
  State<HaditsArbainScreen> createState() => _HaditsArbainScreenState();
}

class _HaditsArbainScreenState extends State<HaditsArbainScreen> {
  final List<Map<String, dynamic>> _data = haditsarbainOfflineData;
  final Set<int> _bookmarks = {};
  final ScrollController _scrollController = ScrollController();
  bool _showBookmarksOnly = false;
  bool _hasScrolledToHighlight = false;
  bool _highlightScrollInitiated = false;
  GlobalKey? _highlightKey;
  int _highlightRetries = 0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadBookmarks();
  }

  void _initiateScrollToHighlight() {
    if (_highlightScrollInitiated || widget.highlightNumber == null) return;
    if (_data.isEmpty) return;

    final index = _data.indexWhere(
      (d) => d['number'] == widget.highlightNumber,
    );
    if (index < 0) return;

    _highlightScrollInitiated = true;
    _highlightKey = GlobalKey();
    _highlightRetries = 0;

    if (_scrollController.hasClients) {
      final offset = (index * 200.0) - 100;
      _scrollController.jumpTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }

    _scheduleArbainScroll();
  }

  void _scheduleArbainScroll() {
    if (!mounted || _highlightRetries >= 10) return;
    _highlightRetries++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_highlightKey?.currentContext != null) {
        Scrollable.ensureVisible(
          _highlightKey!.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.5,
        );
        setState(() => _hasScrolledToHighlight = true);
      } else if (_highlightRetries < 10) {
        _scheduleArbainScroll();
      }
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookmarks() async {
    final storage = LocalStorage();
    final raw = await storage.getJson(ApiConfig.storageKeyArbainBookmarks);
    if (raw != null && raw is List) {
      setState(() {
        _bookmarks.addAll(raw.cast<int>());
      });
    }
    // Initiate scroll ke highlight setelah data siap
    if (widget.highlightNumber != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initiateScrollToHighlight();
      });
    }
  }

  Future<void> _toggleBookmark(int number) async {
    setState(() {
      if (_bookmarks.contains(number)) {
        _bookmarks.remove(number);
      } else {
        _bookmarks.add(number);
      }
    });
    await LocalStorage().saveJson(
      ApiConfig.storageKeyArbainBookmarks,
      _bookmarks.toList(),
    );
  }

  List<Map<String, dynamic>> get _filteredData {
    if (!_showBookmarksOnly) return _data;
    return _data.where((d) => _bookmarks.contains(d['number'])).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final filtered = _filteredData;
    final bookmarkCount = _bookmarks.length;

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
            Icon(CupertinoIcons.book_fill, size: 18, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Hadits Arba\'in'),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ─── Segmented control filter ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isActive: !_showBookmarksOnly,
                    count: _data.length,
                    isDark: isDark,
                    onTap: () => setState(() => _showBookmarksOnly = false),
                  ),
                  const SizedBox(width: 10),
                  _FilterChip(
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
            ),

            // ─── Daftar hadits ───
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showBookmarksOnly
                                ? CupertinoIcons.bookmark
                                : CupertinoIcons.doc_text,
                            size: 48,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _showBookmarksOnly
                                ? 'Belum ada hadits yang di-bookmark'
                                : 'Tidak ada data',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final hadith = filtered[index];
                        final number = hadith['number'] as int;
                        final isHighlighted =
                            _hasScrolledToHighlight &&
                            widget.highlightNumber == number &&
                            !_showBookmarksOnly;
                        final isBookmarked = _bookmarks.contains(number);
                        final highlightKey =
                            isHighlighted ? _highlightKey : null;

                        return Container(
                          key: highlightKey,
                          child: _buildHadithCard(
                            isDark,
                            hadith,
                            number,
                            isHighlighted,
                            isBookmarked,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard(
    bool isDark,
    Map<String, dynamic> hadith,
    int number,
    bool isHighlighted,
    bool isBookmarked,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? (isDark ? AppColors.accentBgDark : AppColors.accentBgLight)
            : (isDark ? AppColors.surfaceDark : CupertinoColors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted
              ? AppColors.heat4.withValues(alpha: 0.6)
              : (isDark
                    ? AppColors.textLight
                    : CupertinoColors.systemGrey6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Number + Bookmark ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: Text(
                  '#$number',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                  ),
                ),
              ),
              // Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    hadith['title'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // Bookmark button
              GestureDetector(
                onTap: () => _toggleBookmark(number),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isBookmarked
                        ? AppColors.heat4.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.textLight
                              : CupertinoColors.systemGrey6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isBookmarked
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    size: 16,
                    color: isBookmarked
                        ? AppColors.heat4
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Arabic text ──
          Text(
            hadith['arab'] as String? ?? '',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.6,
              fontFamily: 'Lateef',
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 14),

          // ── Terjemahan ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.textLight.withValues(alpha: 0.5)
                  : AppColors.textOnDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              hadith['arti'] as String? ?? '',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? CupertinoColors.white : AppColors.borderSubtle,
              ),
            ),
          ),
        ],
      ),
    );
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
