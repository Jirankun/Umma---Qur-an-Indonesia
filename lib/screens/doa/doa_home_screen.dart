import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../config/api_config.dart';
import 'package:provider/provider.dart';
import '../../providers/doa_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/doa_data.dart';
import '../../models/doa.dart';
import '../../services/local_storage.dart';

class DoaHomeScreen extends StatefulWidget {
  const DoaHomeScreen({super.key});

  @override
  State<DoaHomeScreen> createState() => _DoaHomeScreenState();
}

class _DoaHomeScreenState extends State<DoaHomeScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showBookmarksOnly = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaProvider>().loadData();
    });
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _searchController.dispose();
    super.dispose();
  }

  /// Collect all bookmarked doa items from all categories + provider
  List<Map<String, dynamic>> get _allBookmarkedDoas {
    final provider = context.read<DoaProvider>();
    if (provider.bookmarks.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    for (final cat in doaCollections) {
      final doas = cat['doas'] as List<Map<String, dynamic>>? ?? [];
      for (final doa in doas) {
        final id = '${cat['title']}_${doa['title']}';
        if (provider.bookmarks.any((b) => b.id == id)) {
          result.add({
            ...doa,
            '_categoryTitle': cat['title'],
            '_categoryEmoji': cat['emoji'],
          });
        }
      }
    }
    return result;
  }

  List<Map<String, dynamic>> get _filteredCollections {
    if (_searchQuery.isEmpty) return doaCollections;

    final query = _searchQuery.toLowerCase();
    return doaCollections.where((cat) {
      final doas = cat['doas'] as List<Map<String, dynamic>>? ?? [];
      final matchesCategory = (cat['title'] as String? ?? '')
          .toLowerCase()
          .contains(query);
      final matchesDoa = doas.any(
        (d) =>
            (d['title'] as String? ?? '').toLowerCase().contains(query) ||
            (d['latin'] as String? ?? '').toLowerCase().contains(query) ||
            (d['translation'] as String? ?? '').toLowerCase().contains(query),
      );
      return matchesCategory || matchesDoa;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<DoaProvider>(context);

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
            Icon(CupertinoIcons.heart_fill, size: 18, color: AppColors.error),
            SizedBox(width: 8),
            Text(AppStrings.doaKumpulan),
          ],
        ),
        trailing: const SizedBox(),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ─── Filter chips ───
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  _DoaFilterChip(
                    label: AppStrings.doaFilterKategori,
                    isActive: !_showBookmarksOnly,
                    count: doaCollections.length,
                    isDark: isDark,
                    onTap: () => setState(() => _showBookmarksOnly = false),
                  ),
                  const SizedBox(width: 10),
                  _DoaFilterChip(
                    label: AppStrings.bookmark,
                    isActive: _showBookmarksOnly,
                    count: provider.bookmarks.length,
                    isDark: isDark,
                    onTap: () => setState(() => _showBookmarksOnly = true),
                  ),
                  const Spacer(),
                  if (provider.bookmarks.isNotEmpty && !_showBookmarksOnly)
                    Text(
                      '${provider.bookmarks.length} ${AppStrings.quranBookmarkCount}',
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
            // ─── Content ───
            Expanded(
              child: _showBookmarksOnly
                  ? _buildBookmarkList(isDark)
                  : _buildCategoryList(isDark, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.doaKumpulanDanDzikir,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.doaLengkap,
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
          placeholder: AppStrings.doaSearch,
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

  Widget _buildCategoryList(bool isDark, DoaProvider provider) {
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
              if (index >= _filteredCollections.length) return null;
              final category = _filteredCollections[index];
              return _buildCategoryCard(context, isDark, category, provider);
            }, childCount: _filteredCollections.length),
          ),
        ),
        if (_filteredCollections.isEmpty)
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
                      '${AppStrings.doaNotFound} "$_searchQuery"',
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

  Widget _buildCategoryCard(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> category,
    DoaProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _openCategory(context, category),
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
              Text(
                category['emoji'] ?? '🤲',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'] ?? '',
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
                      '${(category['doas'] as List?)?.length ?? 0} ${AppStrings.doaCount}',
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

  void _openCategory(BuildContext context, Map<String, dynamic> category) {
    final doas = category['doas'] as List<Map<String, dynamic>>? ?? [];
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (_) => DoaListScreen(
          title: category['title'] ?? '',
          emoji: category['emoji'] ?? '🤲',
          doas: doas,
          isDark: isDark,
        ),
      ),
    );
  }

  Widget _buildBookmarkList(bool isDark) {
    final provider = context.watch<DoaProvider>();
    final bookmarked = _allBookmarkedDoas;

    if (bookmarked.isEmpty) {
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
              AppStrings.doaBookmarkEmpty,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.doaBookmarkHint,
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
      itemCount: bookmarked.length,
      itemBuilder: (context, index) {
        final doa = bookmarked[index];
        final catTitle = doa['_categoryTitle'] as String? ?? '';
        final catEmoji = doa['_categoryEmoji'] as String? ?? '🤲';
        final doaId = '${catTitle}_${doa['title']}';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              final cat = doaCollections.firstWhere(
                (c) => c['title'] == catTitle,
                orElse: () => doaCollections.first,
              );
              final doas = cat['doas'] as List<Map<String, dynamic>>? ?? [];
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (_) => DoaListScreen(
                    title: catTitle,
                    emoji: catEmoji,
                    doas: doas,
                    isDark: isDark,
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
                  Text(catEmoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doa['title'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? CupertinoColors.white
                                : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          catTitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      final found = provider.bookmarks.where(
                        (b) => b.id == doaId,
                      ).firstOrNull;
                      if (found != null) {
                        provider.toggleBookmark(found);
                      }
                    },
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        CupertinoIcons.bookmark_fill,
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
      },
    );
  }
}

// ─── Filter Chip ─────────────────────────────────────────────
class _DoaFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final int count;
  final bool isDark;
  final VoidCallback onTap;

  const _DoaFilterChip({
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

class DoaListScreen extends StatefulWidget {
  final String title;
  final String emoji;
  final List<Map<String, dynamic>> doas;
  final bool isDark;

  const DoaListScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.doas,
    required this.isDark,
  });

  @override
  State<DoaListScreen> createState() => _DoaListScreenState();
}

class _DoaListScreenState extends State<DoaListScreen> {
  Set<String> _bookmarkedIds = {};
  bool _showArab = true;
  bool _showLatin = true;
  bool _showTranslation = true;
  double _arabFontSize = 24;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadBookmarks();
  }

  Future<void> _loadSettings() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyDoaSettings,
    );
    setState(() {
      _showArab = (data is Map ? data['showArab'] : null) as bool? ?? true;
      _showLatin = (data is Map ? data['showLatin'] : null) as bool? ?? true;
      _showTranslation = (data is Map ? data['showTranslation'] : null) as bool? ?? true;
      _arabFontSize = ((data is Map ? data['arabFontSize'] : null) as num?)?.toDouble() ?? 24;
    });
  }

  Future<void> _loadBookmarks() async {
    final raw = await LocalStorage().getJson(ApiConfig.storageKeyDoaBookmarks);
    if (raw != null && raw is List) {
      setState(() {
        _bookmarkedIds = raw
            .map((b) => b['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toSet();
      });
    }
  }

  Future<void> _toggleBookmark(String id, Map<String, dynamic> doa) async {
    final isNowBookmarked = !_bookmarkedIds.contains(id);
    
    // Instant local update
    setState(() {
      if (isNowBookmarked) {
        _bookmarkedIds.add(id);
      } else {
        _bookmarkedIds.remove(id);
      }
    });

    // Sync with provider and storage
    final doaItem = DoaItem(
      id: id,
      title: doa['title'] ?? '',
      arabic: doa['arabic'] ?? '',
      latin: doa['latin'] ?? '',
      translation: doa['translation'] ?? '',
      source: doa['source'] ?? '',
      categoryId: widget.title.toLowerCase().replaceAll(' ', '_'),
      categoryTitle: widget.title,
    );

    final provider = context.read<DoaProvider>();
    await provider.toggleBookmark(doaItem);
  }

  Future<void> _saveSettings() async {
    await LocalStorage().saveJson(ApiConfig.storageKeyDoaSettings, {
      'showArab': _showArab,
      'showLatin': _showLatin,
      'showTranslation': _showTranslation,
      'arabFontSize': _arabFontSize,
    });
  }

  void _showSettings(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: 340,
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
                _buildToggle(AppStrings.quranSettingArab, _showArab, isDark, (v) {
                  setState(() => _showArab = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildToggle(AppStrings.quranSettingLatin, _showLatin, isDark, (v) {
                  setState(() => _showLatin = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildToggle(AppStrings.quranSettingTerjemahan, _showTranslation, isDark, (v) {
                  setState(() => _showTranslation = v);
                  setModalState(() {});
                  _saveSettings();
                }),
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

  Widget _buildToggle(
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

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text('${widget.emoji} ${widget.title}'),
        trailing: GestureDetector(
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
      ),
      child: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: widget.doas.length,
          itemBuilder: (context, index) {
            final doa = widget.doas[index];
            return _buildDoaItem(doa);
          },
        ),
      ),
    );
  }

  Widget _buildDoaItem(Map<String, dynamic> doa) {
    final id = '${widget.title}_${doa['title']}';
    final isBookmarked = _bookmarkedIds.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark ? AppColors.textLight : CupertinoColors.systemGrey6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  doa['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _toggleBookmark(id, doa),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isBookmarked
                        ? AppColors.warning.withValues(alpha: 0.15)
                        : (widget.isDark
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
                        ? AppColors.warning
                        : CupertinoColors.systemGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showArab)
            Text(
              doa['arabic'] ?? '',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: _arabFontSize,
                fontWeight: FontWeight.w500,
                height: 1.6,
                fontFamily: 'Lateef',
                color: widget.isDark ? CupertinoColors.white : AppColors.textLight,
              ),
            ),
          if (_showArab) const SizedBox(height: 8),
          if (_showLatin)
            Text(
              doa['latin'] ?? '',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: widget.isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
          if (_showLatin) const SizedBox(height: 6),
          if (_showTranslation)
            Text(
              doa['translation'] ?? '',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: widget.isDark ? CupertinoColors.white : AppColors.textLight,
              ),
            ),
          if (doa['source'] != null &&
              (doa['source'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${AppStrings.doaSource} ${doa['source']}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: widget.isDark
                    ? CupertinoColors.systemGrey
                    : AppColors.textSubtle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
