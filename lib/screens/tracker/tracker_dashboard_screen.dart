import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/haid_provider.dart';
import '../../services/quran_tracker_service.dart';
import '../../utils/date_helper.dart';
import 'tracker_screen.dart';

/// Aggregated data for a single calendar day
class _DayData {
  final DateTime date;
  final String dateStr; // YYYY-MM-DD
  final DailyTracker? tracker;
  final int readingSeconds;
  final bool isHaid;
  final bool isHaidOngoing;

  _DayData({
    required this.date,
    required this.dateStr,
    this.tracker,
    this.readingSeconds = 0,
    this.isHaid = false,
    this.isHaidOngoing = false,
  });

  int get completedCount => tracker?.completedCount ?? 0;
  int get totalCount => tracker?.totalCount ?? 0;
  int get percentage => tracker?.percentage ?? 0;
  bool get isComplete => tracker?.isComplete ?? false;
  bool get hasTrackerData => tracker != null;
  bool get hasReading => readingSeconds > 0;
  bool get isPuasa => tracker?.isPuasa ?? false;
}

class TrackerDashboardScreen extends StatefulWidget {
  const TrackerDashboardScreen({super.key});

  @override
  State<TrackerDashboardScreen> createState() =>
      _TrackerDashboardScreenState();
}

class _TrackerDashboardScreenState extends State<TrackerDashboardScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DateTime? _selectedDate;
  Map<String, int> _readingHistory = {};

  @override
  void initState() {
    super.initState();
    _loadReadingData();
  }

  Future<void> _loadReadingData() async {
    final history = await QuranTrackerService().getReadingHistory();
    if (mounted) {
      setState(() => _readingHistory = history);
    }
  }

  void _goToPrevMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _selectedDate = null;
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
      _selectedDate = null;
    });
  }

  void _goToToday() {
    setState(() {
      _selectedYear = DateTime.now().year;
      _selectedMonth = DateTime.now().month;
      _selectedDate = DateTime.now();
    });
  }

  /// Generate all DayData for the current month
  List<_DayData> _buildMonthData(
    TrackerProvider trackerProvider,
    HaidProvider haidProvider,
  ) {
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final result = <_DayData>[];
    final haidLogs = haidProvider.logs;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_selectedYear, _selectedMonth, day);
      final dateStr =
          '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      final tracker = trackerProvider.getTracker(dateStr);
      final readingSeconds = _readingHistory[dateStr] ?? 0;

      // Check haid — safe null handling
      bool isHaid = false;
      bool isHaidOngoing = false;
      for (final log in haidLogs) {
        final start = DateTime(
            log.startDate.year, log.startDate.month, log.startDate.day);

        if (date.isAtSameMomentAs(start)) {
          isHaid = true;
          if (log.endDate == null) isHaidOngoing = true;
          break;
        }

        if (log.endDate != null) {
          final end = DateTime(
              log.endDate!.year, log.endDate!.month, log.endDate!.day);
          if (date.isAtSameMomentAs(end) ||
              (date.isAfter(start) && date.isBefore(end))) {
            isHaid = true;
            break;
          }
        } else {
          // Ongoing period — date is after start but not the same as start (handled above)
          if (date.isAfter(start)) {
            isHaid = true;
            isHaidOngoing = true;
            break;
          }
        }
      }

      result.add(_DayData(
        date: date,
        dateStr: dateStr,
        tracker: tracker,
        readingSeconds: readingSeconds,
        isHaid: isHaid,
        isHaidOngoing: isHaidOngoing,
      ));
    }
    return result;
  }

  /// Calculate monthly statistics
  Map<String, dynamic> _calcMonthStats(List<_DayData> days) {
    int trackedDays = 0;
    int completedDays = 0;
    int totalCompleted = 0;
    int totalItems = 0;
    int totalReadingSecs = 0;
    int puasaDays = 0;

    for (final day in days) {
      if (day.hasTrackerData) {
        trackedDays++;
        totalCompleted += day.completedCount;
        totalItems += day.totalCount;
        if (day.isComplete) completedDays++;
      }
      totalReadingSecs += day.readingSeconds;
      if (day.isPuasa) puasaDays++;
    }

    final avgPercentage =
        trackedDays > 0 ? (totalCompleted / math.max(1, totalItems) * 100).round() : 0;

    return {
      'trackedDays': trackedDays,
      'completedDays': completedDays,
      'avgPercentage': avgPercentage,
      'totalReadingSecs': totalReadingSecs,
      'puasaDays': puasaDays,
    };
  }

  String _fmtDuration(int secs) {
    if (secs < 60) return '$secs detik';
    if (secs < 3600) return '${secs ~/ 60} menit';
    final h = secs ~/ 3600;
    final m = (secs % 3600) ~/ 60;
    return '$h jam $m menit';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final trackerProvider = Provider.of<TrackerProvider>(context);
    final haidProvider = Provider.of<HaidProvider>(context);

    final monthDays = _buildMonthData(trackerProvider, haidProvider);
    final stats = _calcMonthStats(monthDays);

    final months = [
      '', AppStrings.monthJanuari, AppStrings.monthFebruari, AppStrings.monthMaret, AppStrings.monthApril, AppStrings.monthMei, AppStrings.monthJuni,
      AppStrings.monthJuli, AppStrings.monthAgustus, AppStrings.monthSeptember, AppStrings.monthOktober, AppStrings.monthNovember, AppStrings.monthDesember,
    ];
    final daysOfWeek = [AppStrings.dayMinPendek, AppStrings.daySenPendek, AppStrings.daySelPendek, AppStrings.dayRabPendek, AppStrings.dayKamPendek, AppStrings.dayJumPendek, AppStrings.daySabPendek];
    final monthName = months[_selectedMonth];

    // First day offset (0 = Sunday)
    final firstDay = DateTime(_selectedYear, _selectedMonth, 1);
    final startOffset = firstDay.weekday % 7; // Sunday = 0

    // Selected day data
    final selectedDayData = _selectedDate != null
        ? monthDays.where((d) =>
                d.date.year == _selectedDate!.year &&
                d.date.month == _selectedDate!.month &&
                d.date.day == _selectedDate!.day)
            .firstOrNull
        : null;

    return CupertinoPageScaffold(
      backgroundColor:
          isDark ? AppColors.bgDark : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor:
            isDark ? AppColors.surfaceDark : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.sportscourt_fill,
                size: 18, color: AppColors.toolOrange),
            SizedBox(width: 8),
            Text(AppStrings.trackerDashboard),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthNav(isDark, monthName),
              const SizedBox(height: 12),
              _buildStatsRow(isDark, stats),
              const SizedBox(height: 16),
              _buildCalendar(isDark, monthDays, startOffset, daysOfWeek),
              const SizedBox(height: 16),
              if (selectedDayData != null)
                _buildDayDetail(isDark, selectedDayData, trackerProvider),
              const SizedBox(height: 12),
              _buildLegend(isDark),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── MONTH NAV ──────────────────────────────────────────────
  Widget _buildMonthNav(bool isDark, String monthName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goToPrevMonth,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.toolOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.chevron_left,
                size: 16,
                color: AppColors.toolOrange,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _goToToday,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$monthName $_selectedYear',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),

              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _goToNextMonth,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.toolOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: AppColors.toolOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── STATS ROW ──────────────────────────────────────────────
  Widget _buildStatsRow(bool isDark, Map<String, dynamic> stats) {
    final avg = stats['avgPercentage'] as int;
    final avgColor = avg >= 80
        ? AppColors.heat4
        : avg >= 50
            ? AppColors.warning
            : CupertinoColors.systemGrey;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            isDark: isDark,
            value: '${stats['trackedDays']}',
            label: AppStrings.trackerHariTerisi,
            color: AppColors.toolIndigo,
            icon: CupertinoIcons.check_mark_circled_solid,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            isDark: isDark,
            value: '$avg%',
            label: AppStrings.trackerRataRata,
            color: avgColor,
            icon: CupertinoIcons.chart_bar_fill,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            isDark: isDark,
            value: _fmtDuration(stats['totalReadingSecs'] as int),
            label: AppStrings.trackerBacaQuran,
            color: AppColors.heat4,
            icon: CupertinoIcons.book_fill,
          ),
        ),
      ],
    );
  }

  // ─── CALENDAR GRID ──────────────────────────────────────────
  Widget _buildCalendar(
    bool isDark,
    List<_DayData> days,
    int startOffset,
    List<String> dow,
  ) {
    // Available width = screen width - SingleChildScrollView padding(16x2)
    // - Container padding(12x2) - Container border
    final availableWidth = MediaQuery.of(context).size.width - 32 - 24;
    final double cellSize = availableWidth / 7;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (i) {
              final isWeekend = i == 0 || i == 6;
              return SizedBox(
                width: cellSize,
                child: Center(
                  child: Text(
                    dow[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isWeekend
                          ? AppColors.toolPink.withValues(alpha: 0.7)
                          : (isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          ...List.generate(
            ((startOffset + days.length) / 7).ceil(),
            (weekIdx) {
              final cells = <Widget>[];
              for (int d = 0; d < 7; d++) {
                final dayIdx = weekIdx * 7 + d - startOffset;
                if (dayIdx < 0 || dayIdx >= days.length) {
                  cells.add(SizedBox(width: cellSize, height: cellSize));
                } else {
                  final day = days[dayIdx];
                  final isToday = day.date.isAtSameMomentAs(today);
                  final isSelected = _selectedDate != null &&
                      day.date.isAtSameMomentAs(_selectedDate!);

                  cells.add(
                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = day.date),
                      child: _DayCell(
                        day: day,
                        cellSize: cellSize,
                        isToday: isToday,
                        isSelected: isSelected,
                        isDark: isDark,
                      ),
                    ),
                  );
                }
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: cells,
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── DAY DETAIL PANEL ──────────────────────────────────────
  Widget _buildDayDetail(
    bool isDark,
    _DayData day,
    TrackerProvider trackerProvider,
  ) {
    final dayNames = [
      AppStrings.dayMinggu, AppStrings.daySenin, AppStrings.daySelasa, AppStrings.dayRabu, AppStrings.dayKamis, AppStrings.dayJumat, AppStrings.daySabtu
    ];
    final months = [
      '', AppStrings.monthJanuari, AppStrings.monthFebruari, AppStrings.monthMaret, AppStrings.monthApril, AppStrings.monthMei, AppStrings.monthJuni,
      AppStrings.monthJuli, AppStrings.monthAgustus, AppStrings.monthSeptember, AppStrings.monthOktober, AppStrings.monthNovember, AppStrings.monthDesember,
    ];
    final hijri = DateHelper.getHijriDate(day.date);
    final hijriStr = hijri != null
        ? '${hijri.hDay} ${DateHelper.getHijriMonthName(day.date)} ${hijri.hYear} H'
        : '';
    final dayName = dayNames[day.date.weekday % 7];
    final isToday = day.date.isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    final progress = day.totalCount > 0
        ? day.completedCount / day.totalCount
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: day.isComplete
              ? [AppColors.heat4, AppColors.accent]
              : [AppColors.toolOrange, AppColors.trackerOrangeDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (day.isComplete ? AppColors.heat4 : AppColors.toolOrange)
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${day.date.day} ${months[day.date.month]} ${day.date.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: CupertinoColors.white,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              AppStrings.trackerHariIni,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$dayName • $hijriStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Progress ring — custom painter
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(52, 52),
                      painter: _ProgressRingPainter(
                        progress: progress,
                        backgroundColor:
                            CupertinoColors.white.withValues(alpha: 0.2),
                        progressColor: CupertinoColors.white,
                        strokeWidth: 4,
                      ),
                    ),
                    Text(
                      '${day.percentage}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontFamily: '.SF Mono',
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (day.isPuasa)
                _Badge(
                  emoji: '🌙',
                  label: AppStrings.trackerPuasaLabel,
                  bgColor: CupertinoColors.white.withValues(alpha: 0.2),
                ),
              if (day.hasReading)
                _Badge(
                  emoji: '📖',
                  label: 'Quran ${_fmtDuration(day.readingSeconds)}',
                  bgColor: CupertinoColors.white.withValues(alpha: 0.2),
                ),
              if (day.isHaid)
                _Badge(
                  emoji: '🩸',
                  label: day.isHaidOngoing ? 'Haid (berlangsung)' : AppStrings.trackerHaidLabel,
                  bgColor: CupertinoColors.white.withValues(alpha: 0.2),
                ),
              if (day.isComplete)
                _Badge(
                  emoji: '✅',
                  label: AppStrings.trackerTargetSelesai,
                  bgColor: CupertinoColors.white.withValues(alpha: 0.2),
                ),
              if (day.hasTrackerData && !day.isComplete)
                _Badge(
                  emoji: '🔄',
                  label: '${day.completedCount}/${day.totalCount}',
                  bgColor: CupertinoColors.white.withValues(alpha: 0.2),
                ),
              if (!day.hasTrackerData && !day.isHaid)
                _Badge(
                  emoji: '⬜',
                  label: AppStrings.trackerBelumDicatat,
                  bgColor: CupertinoColors.white.withValues(alpha: 0.15),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (isToday || day.hasTrackerData)
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  isToday ? AppStrings.trackerCatatHarian : AppStrings.trackerLihatDetail,
                  style: const TextStyle(fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => TrackerScreen(initialDate: day.date),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          _LegendItem(color: AppColors.heat4, label: AppStrings.trackerSelesai),
          _LegendItem(color: AppColors.warning, label: AppStrings.trackerSebagian),
          _LegendItem(color: AppColors.profileBlue, label: AppStrings.trackerTerisi),
          _LegendItem(color: AppColors.toolPink, label: AppStrings.trackerHaidLabel),
          _LegendItem(color: AppColors.accent, label: AppStrings.trackerBacaQuranLegend),
        ],
      ),
    );
  }
}

/// Custom painter for progress ring (Cupertino-compatible)
class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ProgressRingPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      progress * 2 * math.pi, // Clockwise
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
//  DAY CELL
// ═══════════════════════════════════════════════════════════════
class _DayCell extends StatelessWidget {
  final _DayData day;
  final double cellSize;
  final bool isToday;
  final bool isSelected;
  final bool isDark;

  const _DayCell({
    required this.day,
    required this.cellSize,
    required this.isToday,
    required this.isSelected,
    required this.isDark,
  });

  Color _bgColor() {
    if (day.isComplete) return AppColors.heat4.withValues(alpha: 0.25);
    if (day.hasTrackerData && day.percentage > 0) {
      return AppColors.warning.withValues(alpha: 0.2);
    }
    if (day.hasTrackerData) return AppColors.profileBlue.withValues(alpha: 0.1);
    return CupertinoColors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final hasActivity = day.hasTrackerData || day.hasReading || day.isHaid;
    final isFuture = day.date.isAfter(DateTime.now());

    return Container(
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.toolOrange.withValues(alpha: 0.25)
            : isToday
                ? AppColors.toolIndigo.withValues(alpha: 0.12)
                : _bgColor(),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday
              ? AppColors.toolIndigo
              : isSelected
                  ? AppColors.toolOrange
                  : CupertinoColors.transparent,
          width: isToday || isSelected ? 2 : 0,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.date.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isToday || isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isFuture
                    ? (isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey4)
                    : (isToday || isSelected
                        ? (isToday
                              ? AppColors.toolIndigo
                              : AppColors.toolOrange)
                        : (isDark
                              ? CupertinoColors.white
                              : AppColors.textLight)),
              ),
            ),
          ),
          if (hasActivity && !isFuture)
            Positioned(
              bottom: 2,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (day.isPuasa)
                    _Dot(color: AppColors.accent),
                  if (day.isHaid) ...[
                    const SizedBox(width: 2),
                    _Dot(color: AppColors.toolPink),
                  ],
                  if (day.hasReading) ...[
                    const SizedBox(width: 2),
                    _Dot(color: AppColors.heat4),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  DOT
// ═══════════════════════════════════════════════════════════════
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  STAT CARD
// ═══════════════════════════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final bool isDark;
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.isDark,
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFamily: '.SF Mono',
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  BADGE
// ═══════════════════════════════════════════════════════════════
class _Badge extends StatelessWidget {
  final String emoji;
  final String label;
  final Color bgColor;

  const _Badge({
    required this.emoji,
    required this.label,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LEGEND ITEM
// ═══════════════════════════════════════════════════════════════
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }
}
