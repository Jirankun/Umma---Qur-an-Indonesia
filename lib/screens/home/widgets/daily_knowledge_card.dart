import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../services/ai_content_service.dart';
import '../../../utils/date_helper.dart';
import '../../../data/hadits_data.dart';

class DailyKnowledgeCard extends StatefulWidget {
  final bool isDark;

  const DailyKnowledgeCard({super.key, required this.isDark});

  @override
  State<DailyKnowledgeCard> createState() => _DailyKnowledgeCardState();
}

class _DailyKnowledgeCardState extends State<DailyKnowledgeCard> {
  List<Map<String, dynamic>> _haditsPool = [];

  @override
  void initState() {
    super.initState();
    _loadHadits();
  }

  Future<void> _loadHadits() async {
    try {
      final items = await AiContentService().getDailyHadits();
      if (mounted) {
        setState(() => _haditsPool = items);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isRamadhan = DateHelper.isRamadhanSeason(now);

    Map<String, dynamic> dailyItem;
    if (_haditsPool.isNotEmpty) {
      dailyItem = _haditsPool[now.day % _haditsPool.length];
    } else {
      dailyItem = isRamadhan
          ? _ramadhanFallback[now.day % _ramadhanFallback.length]
          : _generalFallback[now.day % _generalFallback.length];
    }

    final title = dailyItem['title']?.toString() ?? '';
    final content = dailyItem['content']?.toString() ?? '';
    final source = dailyItem['source']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface(widget.isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? AppColors.textLight
                : AppColors.cupertinoSystemGrey6,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isRamadhan
                    ? AppColors.heat4.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isRamadhan
                    ? CupertinoIcons.moon_stars_fill
                    : CupertinoIcons.lightbulb_fill,
                size: 20,
                color: isRamadhan
                    ? AppColors.heat4
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isRamadhan ? AppStrings.homeHaditsRamadhan : AppStrings.homeTahukahKamu,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                      color: widget.isDark
                          ? AppColors.cupertinoSystemGrey
                          : AppColors.cupertinoSystemGrey,
                    ),
                  ),
                  if (title.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark
                            ? AppColors.cupertinoWhite
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: widget.isDark
                          ? AppColors.cupertinoSystemGrey
                          : AppColors.textSubtle,
                    ),
                  ),
                  if (source.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 2,
                          height: 12,
                          color: isRamadhan
                              ? AppColors.heat4
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '— $source',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: widget.isDark
                                ? AppColors.cupertinoSystemGrey
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, String>> _generalFallback = [
    {
      'title': 'Keutamaan Senyum',
      'content': 'Senyummu di hadapan saudaramu adalah sedekah.',
      'source': 'HR. Tirmidzi',
    },
    {
      'title': 'Bersyukur',
      'content':
          'Barangsiapa bersyukur atas nikmat, Allah akan menambah nikmat-Nya.',
      'source': 'QS. Ibrahim: 7',
    },
    {
      'title': 'Menjaga Lisan',
      'content':
          'Barangsiapa beriman kepada Allah dan hari akhir, hendaklah berkata baik atau diam.',
      'source': 'HR. Bukhari',
    },
    {
      'title': 'Keutamaan Ilmu',
      'content': 'Menuntut ilmu adalah kewajiban bagi setiap muslim.',
      'source': 'HR. Ibnu Majah',
    },
    {
      'title': 'Silaturahmi',
      'content':
          'Barangsiapa ingin dilapangkan rezekinya, hendaklah ia menyambung silaturahmi.',
      'source': 'HR. Bukhari',
    },
    {
      'title': 'Tawakal',
      'content':
          'Seandainya kalian bertawakal kepada Allah, niscaya Dia akan memberi rezeki.',
      'source': 'HR. Tirmidzi',
    },
    {
      'title': 'Keutamaan Ikhlas',
      'content': 'Sesungguhnya amal itu tergantung niatnya.',
      'source': 'HR. Bukhari & Muslim',
    },
  ];

  List<Map<String, String>> get _ramadhanFallback => haditsRamadhanData;
}
