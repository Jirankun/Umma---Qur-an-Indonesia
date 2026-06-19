import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/date_helper.dart';
import '../../data/study_data.dart';

class StudyScreen extends StatefulWidget {
  final int? day;
  const StudyScreen({super.key, this.day});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  late int _selectedDay;
  final _days = ramadhanStudyData;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.day ?? DateTime.now().day;
    if (_selectedDay < 1) _selectedDay = 1;
    if (_selectedDay > 30) _selectedDay = 30;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    // Gate: hanya tampil saat Ramadhan
    if (!DateHelper.isRamadhanSeason(DateTime.now())) {
      return CupertinoPageScaffold(
        backgroundColor: isDark
            ? AppColors.bgDark
            : AppColors.bgLight,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          middle: const Text('Studi Ramadhan'),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.moon_stars_fill,
                    size: 64,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Studi Ramadhan',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fitur ini hanya tersedia selama bulan Ramadhan.\n\nTunggu kedatangan bulan suci untuk mengakses materi studi harian selama 30 hari.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final dayData = _days.firstWhere(
      (d) => d['day'] == _selectedDay,
      orElse: () => _days[0],
    );

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: Text('Hari ke-$_selectedDay'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _selectedDay > 1
                  ? () {
                      setState(() => _selectedDay--);
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.heat4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.chevron_left,
                  size: 16,
                  color: _selectedDay > 1
                      ? AppColors.heat4
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _selectedDay < 30
                  ? () {
                      setState(() => _selectedDay++);
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.heat4.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: _selectedDay < 30
                      ? AppColors.heat4
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Day selector
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isActive = day == _selectedDay;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDay = day),
                      child: Container(
                        width: 40,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.heat4
                              : (isDark
                                    ? AppColors.surfaceDark
                                    : CupertinoColors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? AppColors.heat4
                                : (isDark
                                      ? AppColors.textLight
                                      : CupertinoColors.systemGrey5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isActive
                                  ? CupertinoColors.white
                                  : (isDark
                                        ? CupertinoColors.white
                                        : AppColors.textLight),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(child: _buildContent(context, isDark, dayData)),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    Map<String, dynamic> dayData,
  ) {
    final content = dayData['content'] as List<String>? ?? [];
    final quran = dayData['quran'] as Map<String, String>?;
    final readTime = dayData['readTime'] as String? ?? '1-2 min';
    final category = dayData['category'] as String? ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            dayData['title'] as String? ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 8),

          // Meta
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
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$readTime baca',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content paragraphs
          for (int i = 0; i < content.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Text(
              content[i],
              style: TextStyle(
                fontSize: 14,
                height: 1.7,
                color: isDark ? CupertinoColors.white : AppColors.textLight,
              ),
            ),
          ],

          // Quran reference
          if (quran != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppColors.textLight
                      : const Color(0xFFBBF7D0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.book_fill,
                        size: 16,
                        color: AppColors.accent,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Rujukan',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    quran['text'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${quran['source'] ?? ''}',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : const Color(0xFF4ADE80),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
