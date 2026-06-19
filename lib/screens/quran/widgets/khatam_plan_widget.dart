import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../services/quran_tracker_service.dart';

class KhatamPlanWidget extends StatefulWidget {
  final bool isDark;
  final VoidCallback? onResetLastRead;

  const KhatamPlanWidget({
    super.key,
    required this.isDark,
    this.onResetLastRead,
  });

  @override
  State<KhatamPlanWidget> createState() => _KhatamPlanWidgetState();
}

class _KhatamPlanWidgetState extends State<KhatamPlanWidget> {
  final _tracker = QuranTrackerService();
  Map<String, dynamic>? _plan;
  Map<String, dynamic>? _stats;
  bool _loading = true;
  bool _showSetup = false;
  final _targetController = TextEditingController(text: '30');
  bool _showCongrats = false;

  static const int totalAyat = 6236;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    setState(() => _loading = true);
    final plan = await _tracker.getKhatamPlan();
    setState(() {
      _plan = plan;
      _loading = false;
    });
    if (plan != null) _calculateStats(plan);
  }

  void _calculateStats(Map<String, dynamic> plan) {
    final startDate = DateTime.parse(
      plan['startDate'] ?? DateTime.now().toIso8601String(),
    );
    final today = DateTime.now();
    final daysElapsed = today.difference(startDate).inDays;
    final targetDays = plan['targetDays'] ?? 30;
    final progressAyat = (plan['progressAyat'] ?? 0) as int;
    final daysRemaining = (targetDays - daysElapsed).clamp(1, 9999);
    final ayatRemaining = (totalAyat - progressAyat).clamp(0, totalAyat);
    final targetAyatPerDay = (ayatRemaining / daysRemaining).ceil();
    final expectedProgress = ((totalAyat / targetDays) * daysElapsed).ceil();
    final percentage = ((progressAyat / totalAyat) * 100).toStringAsFixed(1);

    String status = 'ON_TRACK';
    String recommendation =
        'Konsistensi yang hebat! Tetap pertahankan membaca sekitar $targetAyatPerDay ayat setiap harinya.';
    if (progressAyat < expectedProgress - 50) {
      status = 'BEHIND';
      recommendation =
          'Target harianmu naik menjadi $targetAyatPerDay ayat. Coba bagi waktu membaca setelah setiap shalat wajib.';
    } else if (progressAyat > expectedProgress + 50) {
      status = 'AHEAD';
      recommendation =
          'MasyaAllah, bacaanmu lebih cepat dari target! Kamu bisa mempertahankan ritme santai ini.';
    }

    if (progressAyat >= totalAyat) {
      if (mounted) {
        setState(() => _showCongrats = true);
      }
    }

    setState(() {
      _stats = {
        'daysRemaining': daysRemaining,
        'ayatRemaining': ayatRemaining,
        'targetAyatPerDay': targetAyatPerDay,
        'status': status,
        'recommendation': recommendation,
        'percentage': percentage,
        'progressAyat': progressAyat,
        'targetDays': targetDays,
      };
    });
  }

  Future<void> _createPlan() async {
    final targetDays = int.tryParse(_targetController.text) ?? 30;
    if (targetDays < 1) return;
    await _tracker.saveKhatamPlan({
      'targetDays': targetDays,
      'progressAyat': 0,
      'startDate': DateTime.now().toIso8601String(),
    });
    setState(() => _showSetup = false);
    await _loadPlan();
  }

  Future<void> _removePlan() async {
    await _tracker.clearKhatamPlan();
    if (mounted) {
      setState(() {
        _plan = null;
        _stats = null;
        _showCongrats = false;
      });
    }
    widget.onResetLastRead?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.surfaceDark
              : CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isDark
                ? AppColors.textLight
                : CupertinoColors.systemGrey6,
          ),
        ),
        child: const Center(child: CupertinoActivityIndicator(radius: 10)),
      );
    }
    if (_plan == null) return _buildEmptyState();
    return _buildPlanState();
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.fiqihSholat.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.flag_fill,
                  size: 18,
                  color: AppColors.fiqihSholat,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Program Khatam',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Buat target khatam Al-Quran dan pantau progress harianmu.',
            style: TextStyle(
              fontSize: 12,
              color: widget.isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 12),
          if (!_showSetup)
            GestureDetector(
              onTap: () => setState(() => _showSetup = true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fiqihSholat,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Mulai Program',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? AppColors.textLight
                        : CupertinoColors.tertiarySystemBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CupertinoTextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    placeholder: '30',
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hari',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _createPlan,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fiqihSholat,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Simpan Target',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPlanState() {
    if (_stats == null) return const SizedBox();
    final percentage = _stats!['percentage'] as String;
    final progressAyat = _stats!['progressAyat'] as int;
    final targetAyatPerDay = _stats!['targetAyatPerDay'] as int;
    final daysRemaining = _stats!['daysRemaining'] as int;
    final status = _stats!['status'] as String;
    final recommendation = _stats!['recommendation'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.flag_fill,
                    size: 18,
                    color: AppColors.fiqihSholat,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Progres Khatam',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showResetConfirm(),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.fiqihSholat,
                ),
              ),
              Text(
                '$progressAyat / $totalAyat Ayat',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: widget.isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (progressAyat / totalAyat).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.fiqihSholat,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox('Target Harian', '$targetAyatPerDay Ayat'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox('Sisa Waktu', '$daysRemaining Hari'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: status == 'BEHIND'
                  ? CupertinoColors.systemRed.withValues(alpha: 0.1)
                  : status == 'AHEAD'
                  ? AppColors.heat4.withValues(alpha: 0.1)
                  : AppColors.fiqihSholat.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  status == 'BEHIND'
                      ? CupertinoIcons.exclamationmark_triangle_fill
                      : status == 'AHEAD'
                      ? CupertinoIcons.arrow_up_circle_fill
                      : CupertinoIcons.check_mark_circled_solid,
                  size: 16,
                  color: status == 'BEHIND'
                      ? CupertinoColors.systemRed
                      : status == 'AHEAD'
                      ? AppColors.heat4
                      : AppColors.fiqihSholat,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.4,
                      color: widget.isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showCongrats) _buildCongratsModal(),
        ],
      ),
    );
  }

  Widget _buildCongratsModal() {
    return GestureDetector(
      onTap: () => setState(() => _showCongrats = false),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.warningBgLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.warningBorder),
        ),
        child: Column(
          children: [
            const Icon(
              CupertinoIcons.star_fill,
              size: 40,
              color: AppColors.warning,
            ),
            const SizedBox(height: 8),
            const Text(
              'Alhamdulillah!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.warningTextDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Kamu telah menyelesaikan bacaan Al-Qur'an.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.warningTextDark),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                _removePlan();
                setState(() => _showCongrats = false);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Selesai & Mulai Ulang',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? AppColors.textLight.withValues(alpha: 0.5)
            : CupertinoColors.tertiarySystemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirm() {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Reset Program Khatam?'),
        content: const Text('Apakah kamu yakin ingin mereset target khatam?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Reset'),
            onPressed: () {
              _removePlan().then((_) {
                if (mounted) Navigator.pop(ctx);
              });
            },
          ),
        ],
      ),
    );
  }
}
