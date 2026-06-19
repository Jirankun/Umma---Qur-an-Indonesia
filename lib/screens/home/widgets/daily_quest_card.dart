import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../services/ai_content_service.dart';

/// Daily Quest Card — menampilkan misi ibadah harian dari batch 30 quest AI.
/// Tidak bisa di-tap untuk ganti, refresh otomatis setiap hari dari cache.
class DailyQuestCard extends StatefulWidget {
  final bool isDark;

  const DailyQuestCard({super.key, required this.isDark});

  @override
  State<DailyQuestCard> createState() => _DailyQuestCardState();
}

class _DailyQuestCardState extends State<DailyQuestCard> {
  Map<String, String> _currentQuest = const {
    'title': '',
    'description': '',
    'reward': '',
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuest();
  }

  Future<void> _loadQuest() async {
    try {
      final quest = await AiContentService().getDailyQuest();
      if (mounted) {
        setState(() {
          _currentQuest = quest;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _currentQuest['title'] ?? '';
    final description = _currentQuest['description'] ?? '';
    final reward = _currentQuest['reward'] ?? '';

    if (title.isEmpty && !_isLoading) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [AppColors.surfaceDark, AppColors.questBgDark]
                : [AppColors.warningBgLight, AppColors.warningBorder],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? AppColors.textLight
                : AppColors.questAccent.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    size: 18,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MISI HARIAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: widget.isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                      if (_isLoading) ...[],
                      if (!_isLoading && title.isNotEmpty) ...[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark
                                ? CupertinoColors.white
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_isLoading) const CupertinoActivityIndicator(radius: 7),
              ],
            ),
            if (!_isLoading && description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                  color: widget.isDark
                      ? CupertinoColors.systemGrey
                      : AppColors.textSubtle,
                ),
              ),
            ],
            if (!_isLoading && reward.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.gift_fill,
                    size: 12,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Hadiah: $reward',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: widget.isDark
                            ? AppColors.warningLight
                            : AppColors.warningTextDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
