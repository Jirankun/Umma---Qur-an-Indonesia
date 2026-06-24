import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../providers/tracker_provider.dart';

class DailyGoalTracker extends StatelessWidget {
  final TrackerSummary summary;
  final bool isDark;
  final VoidCallback onTap;

  const DailyGoalTracker({
    super.key,
    required this.summary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = summary.percentage;
    final color = percentage == 100
        ? AppColors.heat4
        : percentage >= 70
        ? AppColors.fiqihSholat
        : percentage >= 40
        ? AppColors.warning
        : percentage > 0
        ? AppColors.error
        : CupertinoColors.systemGrey;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.textLight
                  : AppColors.cupertinoSystemGrey6,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          CupertinoIcons.check_mark_circled_solid,
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.homeTargetHarian,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.cupertinoWhite
                                  : AppColors.textLight,
                            ),
                          ),
                          Text(
                            '${summary.completed}/${summary.total} selesai'.replaceFirst('selesai', AppStrings.trackerCountFormat.split('{count}').last.trim()),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.cupertinoSystemGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: '.SF Mono',
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Custom progress bar (Cupertino-compatible)
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
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
}
