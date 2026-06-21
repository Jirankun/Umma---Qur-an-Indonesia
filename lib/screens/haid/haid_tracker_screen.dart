import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../providers/haid_provider.dart';
import '../../providers/theme_provider.dart';

class HaidTrackerScreen extends StatefulWidget {
  const HaidTrackerScreen({super.key});

  @override
  State<HaidTrackerScreen> createState() => _HaidTrackerScreenState();
}

class _HaidTrackerScreenState extends State<HaidTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HaidProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final provider = Provider.of<HaidProvider>(context);
    final active = provider.activePeriod;
    final phase = provider.getCyclePhase();

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.haidBgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.haidBgLight,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.drop_fill, size: 18, color: AppColors.toolPink),
            SizedBox(width: 8),
            Text(AppStrings.haidTracker),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.toolPink, AppColors.haidDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.drop_fill,
                          color: CupertinoColors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          active != null
                              ? '${AppStrings.haidSedang} (${AppStrings.haidDay} ke-${provider.getDuration(active)})'
                              : AppStrings.haidTidak,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.haidFaseSiklus,
                      style: TextStyle(
                        fontSize: 11,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getPhaseLabel(phase),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              active != null ? AppStrings.haidAkhiri : AppStrings.haidMulai,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onPressed: () => _markDate(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats
              Row(
                children: [
                  _buildStatCard(
                    isDark,
                    '${provider.logs.length}',
                    AppStrings.haidTotalSiklus,
                    AppColors.toolPink,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    isDark,
                    '${provider.totalMissedFasting}',
                    AppStrings.haidQadha,
                    AppColors.haidDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // History
              Text(
                AppStrings.haidRiwayat,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              if (provider.logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textLight
                          : CupertinoColors.systemGrey6,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      AppStrings.haidKosong,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                )
              else
                ...provider.logs.reversed
                    .take(10)
                    .map(
                      (log) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : CupertinoColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.textLight
                                : CupertinoColors.systemGrey6,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              CupertinoIcons.drop_fill,
                              size: 18,
                              color: AppColors.toolPink,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${log.startDate.day}/${log.startDate.month}/${log.startDate.year}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (log.endDate != null)
                                    Text(
                                      '${provider.getDuration(log)} hari — Selesai ${log.endDate!.day}/${log.endDate!.month}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.systemGrey,
                                      ),
                                    )                                    else
                                    Text(
                                      AppStrings.haidBerlangsung,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.toolPink,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              '${provider.getQadhaDays(log)} hari',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.haidDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(bool isDark, String value, String label, Color color) {
    return Expanded(
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
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFamily: '.SF Mono',
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
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
    );
  }

  String _getPhaseLabel(String phase) {
    switch (phase) {
      case 'haid':
        return '🩸 Haid';
      case 'subur':
        return '🌸 Masa Subur';
      case 'luteal':
        return '🌼 Fase Luteal';
      default:
        return '🌱 Fase Folikular';
    }
  }

  void _markDate(BuildContext context) {
    final active = context.read<HaidProvider>().activePeriod;
    final now = DateTime.now();

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _DatePickerSheet(
        initialDate: now,
        isEndDate: active != null,
        onConfirm: (selectedDate) {
          context.read<HaidProvider>().saveDate(
            active != null ? 'end' : 'start',
            selectedDate,
          );
        },
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final bool isEndDate;
  final void Function(DateTime) onConfirm;

  const _DatePickerSheet({
    required this.initialDate,
    required this.isEndDate,
    required this.onConfirm,
  });

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: Text(AppStrings.cancel),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  widget.isEndDate ? 'Tanggal Selesai' : 'Tanggal Mulai',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    widget.onConfirm(_selectedDate);
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppStrings.save,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: _selectedDate,
              maximumDate: DateTime.now(),
              minimumDate: DateTime(2023, 1, 1),
              onDateTimeChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
        ],
      ),
    );
  }
}
