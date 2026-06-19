import 'package:flutter/cupertino.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../config/colors.dart';
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
  bool _showArab = true;
  bool _showLatin = true;
  bool _showTranslation = true;
  double _arabFontSize = 24;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaProvider>().loadData();
    });
  }

  Future<void> _loadSettings() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyDoaSettings,
    );
    if (data is Map) {
      setState(() {
        _showArab = (data['showArab'] as bool?) ?? true;
        _showLatin = (data['showLatin'] as bool?) ?? true;
        _showTranslation = (data['showTranslation'] as bool?) ?? true;
        _arabFontSize = (data['arabFontSize'] as num?)?.toDouble() ?? 24;
      });
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _searchController.dispose();
    super.dispose();
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
            Text('Kumpulan Doa'),
          ],
        ),
        trailing: GestureDetector(
          onTap: () => _showBookmarks(context),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                CupertinoIcons.bookmark_fill,
                size: 20,
                color: AppColors.primary,
              ),
              if (provider.bookmarks.isNotEmpty)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${provider.bookmarks.length}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(child: _buildHeader(isDark)),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index >= _filteredCollections.length) return null;
                  final category = _filteredCollections[index];
                  return _buildCategoryCard(
                    context,
                    isDark,
                    category,
                    provider,
                  );
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
                          'Tidak ditemukan doa untuk "$_searchQuery"',
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
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kumpulan Doa & Dzikir',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Lengkap dengan Arab, Latin, dan Artinya',
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
          placeholder: 'Cari doa...',
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
                      '${(category['doas'] as List?)?.length ?? 0} doa',
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
          showArab: _showArab,
          showLatin: _showLatin,
          showTranslation: _showTranslation,
          arabFontSize: _arabFontSize,
        ),
      ),
    );
  }

  void _showBookmarks(BuildContext context) {
    final provider = Provider.of<DoaProvider>(context, listen: false);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 450,
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
                    'Doa Tersimpan',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: CupertinoColors.systemGrey5),
            if (provider.bookmarks.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.bookmark,
                        size: 32,
                        color: CupertinoColors.systemGrey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada doa tersimpan',
                        style: TextStyle(
                          fontSize: 13,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.bookmarks.length,
                  itemBuilder: (context, index) {
                    final doa = provider.bookmarks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDark
                            : CupertinoColors.systemGroupedBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.textLight
                              : CupertinoColors.systemGrey6,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doa.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? CupertinoColors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                                if (doa.categoryTitle.isNotEmpty)
                                  Text(
                                    doa.categoryTitle,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.toggleBookmark(doa),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.systemRed.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
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
                    );
                  },
                ),
              ),
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
  final bool showArab;
  final bool showLatin;
  final bool showTranslation;
  final double arabFontSize;

  const DoaListScreen({
    super.key,
    required this.title,
    required this.emoji,
    required this.doas,
    required this.isDark,
    this.showArab = true,
    this.showLatin = true,
    this.showTranslation = true,
    this.arabFontSize = 24,
  });

  @override
  State<DoaListScreen> createState() => _DoaListScreenState();
}

class _DoaListScreenState extends State<DoaListScreen> {
  late bool _showArab;
  late bool _showLatin;
  late bool _showTranslation;
  late double _arabFontSize;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await LocalStorage().getJson(
      ApiConfig.storageKeyDoaSettings,
    );
    setState(() {
      _showArab = (data is Map ? data['showArab'] : null) as bool? ?? widget.showArab;
      _showLatin = (data is Map ? data['showLatin'] : null) as bool? ?? widget.showLatin;
      _showTranslation = (data is Map ? data['showTranslation'] : null) as bool? ?? widget.showTranslation;
      _arabFontSize = ((data is Map ? data['arabFontSize'] : null) as num?)?.toDouble() ?? widget.arabFontSize;
    });
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
                _buildToggle('Teks Arab', _showArab, isDark, (v) {
                  setState(() => _showArab = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildToggle('Teks Latin', _showLatin, isDark, (v) {
                  setState(() => _showLatin = v);
                  setModalState(() {});
                  _saveSettings();
                }),
                _buildToggle('Terjemahan', _showTranslation, isDark, (v) {
                  setState(() => _showTranslation = v);
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
    return CupertinoPageScaffold(
      backgroundColor: widget.isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: widget.isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text('${widget.emoji} ${widget.title}'),
        trailing: GestureDetector(
          onTap: () => _showSettings(context, widget.isDark),
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
            return _buildDoaItem(context, doa);
          },
        ),
      ),
    );
  }

  Widget _buildDoaItem(BuildContext context, Map<String, dynamic> doa) {
    final provider = context.watch<DoaProvider>();

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
                onTap: () {
                  final doaItem = DoaItem(
                    id: '${widget.title}_${doa['title']}',
                    title: doa['title'] ?? '',
                    arabic: doa['arabic'] ?? '',
                    latin: doa['latin'] ?? '',
                    translation: doa['translation'] ?? '',
                    source: doa['source'] ?? '',
                    categoryId: widget.title.toLowerCase().replaceAll(' ', '_'),
                    categoryTitle: widget.title,
                  );
                  provider.toggleBookmark(doaItem);
                },
                child: Icon(
                  provider.isBookmarked('${widget.title}_${doa['title']}')
                      ? CupertinoIcons.bookmark_fill
                      : CupertinoIcons.bookmark,
                  size: 20,
                  color: provider.isBookmarked('${widget.title}_${doa['title']}')
                      ? AppColors.warning
                      : CupertinoColors.systemGrey,
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
              'Sumber: ${doa['source']}',
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
