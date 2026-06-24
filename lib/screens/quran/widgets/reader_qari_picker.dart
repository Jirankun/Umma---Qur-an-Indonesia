import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../config/api_config.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/quran_download_service.dart';

/// Sheet pemilih Qari (reciter) untuk audio Quran
class QariPickerSheet extends StatefulWidget {
  final String currentQariId;
  final void Function(String) onSelect;

  const QariPickerSheet({super.key, required this.currentQariId, required this.onSelect});

  @override
  State<QariPickerSheet> createState() => _QariPickerSheetState();
}

class _QariPickerSheetState extends State<QariPickerSheet> {
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
            : AppColors.cupertinoSystemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.quranSelectQari,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.cupertinoSystemGrey5),
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
                          color: AppColors.cupertinoSystemGrey6,
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
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? AppColors.cupertinoWhite
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
                                          ? AppColors.cupertinoWhite
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
                                        color: AppColors.accent.withValues(alpha: 0.15),
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
                                            AppStrings.quranAudio,
                                            style: const TextStyle(
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
                                      ? AppColors.cupertinoSystemGrey
                                      : AppColors.cupertinoSystemGrey,
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
