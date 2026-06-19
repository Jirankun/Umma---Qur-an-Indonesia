import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/date_helper.dart';

class _CupertinoProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _CupertinoProgressBar({
    required this.value,
    this.color = CupertinoColors.white,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

class TrackerScreen extends StatefulWidget {
  /// Optional: tanggal spesifik untuk ditampilkan.
  /// Jika null, pakai hari ini.
  final DateTime? initialDate;

  const TrackerScreen({super.key, this.initialDate});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  late String _todayStr;

  @override
  void initState() {
    super.initState();
    final baseDate = widget.initialDate ?? DateTime.now();
    _todayStr = _formatDate(baseDate);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<TrackerProvider>(context);

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
              CupertinoIcons.sportscourt_fill,
              size: 18,
              color: AppColors.toolOrange,
            ),
            SizedBox(width: 8),
            Text('Target Harian'),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark, provider),
              const SizedBox(height: 20),
              _buildTrackerItem(
                context,
                isDark,
                '🌙',
                'Puasa (Sunah/Wajib)',
                'isPuasa',
                AppColors.toolOrange,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '🌅',
                'Sholat Subuh',
                'subuh',
                AppColors.profileBlue,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '☀️',
                'Sholat Dzuhur',
                'dzuhur',
                AppColors.zakat,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '🌤️',
                'Sholat Ashar',
                'ashar',
                AppColors.toolOrange,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '🌇',
                'Sholat Maghrib',
                'maghrib',
                AppColors.toolIndigo,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '🌙',
                'Sholat Isya',
                'isya',
                AppColors.fiqihDoa,
              ),
              if (DateHelper.isRamadhanSeason(DateTime.now()))
                _buildTrackerItem(
                  context,
                  isDark,
                  '⭐',
                  'Sholat Tarawih',
                  'tarawih',
                  AppColors.toolIndigo,
                ),
              _buildTrackerItem(
                context,
                isDark,
                '📖',
                'Tilawah Qur\'an',
                'quran',
                AppColors.heat4,
              ),
              _buildTrackerItem(
                context,
                isDark,
                '❤️',
                'Sedekah Harian',
                'sedekah',
                AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, TrackerProvider provider) {
    final summary = provider.getTrackerSummary();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.toolOrange, Color(0xFFEA580C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target Ibadah Harian',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.completed} dari ${summary.total} selesai',
                  style: const TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '${summary.percentage}%',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontFamily: '.SF Mono',
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: _CupertinoProgressBar(
                    value: summary.percentage / 100,
                    color: CupertinoColors.white,
                    height: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerItem(
    BuildContext context,
    bool isDark,
    String emoji,
    String label,
    String key,
    Color color,
  ) {
    final today = _todayStr;
    final provider = Provider.of<TrackerProvider>(context, listen: false);
    final tracker = provider.getTracker(today);
    bool isDone = false;
    if (tracker != null) {
      switch (key) {
        case 'isPuasa':
          isDone = tracker.isPuasa;
          break;
        case 'subuh':
          isDone = tracker.subuh;
          break;
        case 'dzuhur':
          isDone = tracker.dzuhur;
          break;
        case 'ashar':
          isDone = tracker.ashar;
          break;
        case 'maghrib':
          isDone = tracker.maghrib;
          break;
        case 'isya':
          isDone = tracker.isya;
          break;
        case 'tarawih':
          isDone = tracker.tarawih;
          break;
        case 'quran':
          isDone = tracker.quran;
          break;
        case 'sedekah':
          isDone = tracker.sedekah;
          break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => provider.toggleTracker(today, key),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDone
                ? color.withValues(alpha: 0.1)
                : (isDark ? AppColors.surfaceDark : CupertinoColors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDone
                  ? color.withValues(alpha: 0.3)
                  : (isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6),
            ),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDone
                        ? color
                        : (isDark
                              ? CupertinoColors.white
                              : AppColors.textLight),
                  ),
                ),
              ),
              Icon(
                isDone
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: isDone ? color : CupertinoColors.systemGrey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
