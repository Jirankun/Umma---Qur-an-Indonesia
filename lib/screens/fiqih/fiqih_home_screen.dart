import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/fiqih_provider.dart';
import '../../providers/theme_provider.dart';

class FiqihHomeScreen extends StatelessWidget {
  const FiqihHomeScreen({super.key});

  static final Map<String, Map<String, dynamic>> _categories = {
    'thaharah': {'emoji': '💧', 'color': AppColors.fiqihThaharah},
    'sholat': {'emoji': '🕌', 'color': AppColors.fiqihSholat},
    'puasa': {'emoji': '🌙', 'color': AppColors.heat4},
    'zakat': {'emoji': '💰', 'color': AppColors.warning},
    'haid': {'emoji': '🩸', 'color': AppColors.toolPink},
    'jenazah': {'emoji': '🤍', 'color': AppColors.textSubtle},
    'doa': {'emoji': '🤲', 'color': AppColors.fiqihDoa},
    'amalan': {'emoji': '✨', 'color': AppColors.toolCyan},
    'muamalah': {'emoji': '🤝', 'color': AppColors.heat4},
    'nikah': {'emoji': '💍', 'color': AppColors.profilePink},
    'kurban': {'emoji': '🐑', 'color': AppColors.zakatDark},
    'adab': {'emoji': '🌸', 'color': AppColors.profileViolet},
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<FiqihProvider>(context);

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
              color: AppColors.warning,
            ),
            SizedBox(width: 8),
            Text('Fiqih Islam'),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(child: _buildHeader(isDark, provider)),
            ),
            // Category chips
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _buildCategoryChips(context, isDark, provider),
              ),
            ),
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              sliver: SliverToBoxAdapter(
                child: provider.activeCategory.isNotEmpty
                    ? _buildSectionTitle(
                        isDark,
                        'Kategori: ${provider.activeCategory}',
                      )
                    : _buildSectionTitle(isDark, 'SEMUA MATERI'),
              ),
            ),
            _buildFiqihList(isDark, provider),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, FiqihProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Panduan Fiqih Islam',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${provider.allItems.length} materi tentang puasa, sholat, zakat, dan lainnya',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 16),
        CupertinoSearchTextField(
          placeholder: 'Cari topik fiqih...',
          style: TextStyle(
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
          onChanged: (value) => provider.search(value),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(
    BuildContext context,
    bool isDark,
    FiqihProvider provider,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: provider.categories.map((cat) {
          final catInfo =
              _categories[cat] ??
              {'emoji': '📖', 'color': AppColors.textSubtle};
          final isActive = provider.activeCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => provider.filterByCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? (catInfo['color'] as Color).withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.surfaceDark
                            : CupertinoColors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? (catInfo['color'] as Color).withValues(alpha: 0.5)
                        : (isDark
                              ? AppColors.textLight
                              : CupertinoColors.systemGrey6),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      catInfo['emoji'] as String,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat[0].toUpperCase() + cat.substring(1),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? (catInfo['color'] as Color)
                            : (isDark
                                  ? CupertinoColors.white
                                  : AppColors.textLight),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(bool isDark, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey,
      ),
    );
  }

  Widget _buildFiqihList(bool isDark, FiqihProvider provider) {
    // When searching or filtering by category, use filteredItems
    final showFiltered = provider.activeCategory.isNotEmpty || provider.searchQuery.isNotEmpty;
    final items = showFiltered ? provider.filteredItems : provider.allItems;

    // Show empty state when searching but nothing found
    if (showFiltered && items.isEmpty && provider.searchQuery.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Center(
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
                  'Tidak ditemukan topik untuk "${provider.searchQuery}"',
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
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= items.length) return null;
            final item = items[index];
            return _buildFiqihCard(context, isDark, item);
          },
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildFiqihCard(BuildContext context, bool isDark, dynamic item) {
    final catInfo =
        _categories[item.category] ??
        {'emoji': '📖', 'color': AppColors.textSubtle};

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showDetail(context, item, catInfo, isDark),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (catInfo['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    catInfo['emoji'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
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
                      item.content.length > 100
                          ? '${item.content.substring(0, 100)}...'
                          : item.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  void _showDetail(
    BuildContext context,
    dynamic item,
    Map<String, dynamic> catInfo,
    bool isDark,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 500,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (catInfo['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${catInfo['emoji']} ${item.category[0].toUpperCase()}${item.category.substring(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: catInfo['color'] as Color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 24,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Container(
              height: 1,
              color: CupertinoColors.systemGrey5.withValues(alpha: 0.3),
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  item.content,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
