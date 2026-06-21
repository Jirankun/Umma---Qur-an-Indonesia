import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../providers/zakat_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/date_helper.dart';

class ZakatScreen extends StatelessWidget {
  const ZakatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
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
              CupertinoIcons.money_dollar_circle_fill,
              size: 18,
              color: AppColors.zakat,
            ),
            SizedBox(width: 8),
            Text(AppStrings.zakatKalkulator),
          ],
        ),
      ),
      child: SafeArea(
        child: DateHelper.isEndOfRamadhan(DateTime.now())
            ? _buildContent(context, isDark)
            : _buildLocked(isDark),
      ),
    );
  }

  /// Full content: banner full-width (edge-to-edge) + kartu zakat
  Widget _buildContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner full-width (tanpa horizontal padding dari scroll view)
          _buildHeader(isDark),
          const SizedBox(height: 24),
          // Kartu-kartu dengan padding horizontal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (DateHelper.isRamadhanSeason(DateTime.now()))
                  _buildTypeCard(
                    context,
                    isDark,
                    AppStrings.zakatFitrah,
                    '🍚',
                    '2.5 kg × jiwa × harga',
                    'fitrah',
                  ),
                if (DateHelper.isRamadhanSeason(DateTime.now()))
                  const SizedBox(height: 12),
                _buildTypeCard(
                  context,
                  isDark,                    AppStrings.zakatMaal,
                    '💰',
                    AppStrings.zakatMaalDesc,
                  'maal',
                ),
                const SizedBox(height: 12),
                _buildTypeCard(
                  context,
                  isDark,                    AppStrings.zakatPenghasilan,
                    '💼',
                    AppStrings.zakatPenghasilanDesc,
                  'penghasilan',
                ),
                const SizedBox(height: 12),
                _buildTypeCard(
                  context,
                  isDark,                    AppStrings.zakatEmas,
                    '✨',
                    AppStrings.zakatEmasDesc,
                  'emas_perak',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Locked state: zakat belum tersedia
  Widget _buildLocked(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.lock_fill,
              size: 48,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 16),
            Text(                  AppStrings.zakatRamadhanOnly,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.5,
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

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.zakat, AppColors.warning],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.zakatTagline,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: CupertinoColors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.zakatSubtitle,
            style: TextStyle(fontSize: 13, color: CupertinoColors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              AppStrings.zakatNisab,
              style: TextStyle(fontSize: 11, color: CupertinoColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(
    BuildContext context,
    bool isDark,
    String title,
    String emoji,
    String subtitle,
    String type,
  ) {
    return GestureDetector(
      onTap: () => _showCalculator(context, type, isDark),
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
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                  Text(
                    subtitle,
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
    );
  }

  void _showCalculator(BuildContext context, String type, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => _ZakatCalculatorSheet(type: type, isDark: isDark),
    );
  }
}

class _ZakatCalculatorSheet extends StatefulWidget {
  final String type;
  final bool isDark;
  const _ZakatCalculatorSheet({required this.type, required this.isDark});

  @override
  State<_ZakatCalculatorSheet> createState() => _ZakatCalculatorSheetState();
}

class _ZakatCalculatorSheetState extends State<_ZakatCalculatorSheet> {
  late Map<String, TextEditingController> _controllers;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    final provider = context.read<ZakatProvider>();
    switch (widget.type) {
      case 'fitrah':
        _controllers = {
          'jumlahJiwa': TextEditingController(
            text: provider.jumlahJiwa.toStringAsFixed(0),
          ),
          'hargaBeras': TextEditingController(
            text: provider.hargaBerasPerKg.toStringAsFixed(0),
          ),
          'berasPerJiwa': TextEditingController(
            text: provider.berasPerJiwa.toStringAsFixed(1),
          ),
        };
        break;
      case 'maal':
        _controllers = {
          'tabungan': TextEditingController(
            text: provider.tabungan.toStringAsFixed(0),
          ),
          'investasi': TextEditingController(
            text: provider.investasi.toStringAsFixed(0),
          ),
          'piutang': TextEditingController(
            text: provider.piutang.toStringAsFixed(0),
          ),
          'hutang': TextEditingController(
            text: provider.hutang.toStringAsFixed(0),
          ),
        };
        break;
      case 'penghasilan':
        _controllers = {
          'penghasilan': TextEditingController(
            text: provider.penghasilanPerBulan.toStringAsFixed(0),
          ),
          'pendapatanLain': TextEditingController(
            text: provider.pendapatanLain.toStringAsFixed(0),
          ),
          'hutangPenghasilan': TextEditingController(
            text: provider.hutangPenghasilan.toStringAsFixed(0),
          ),
          'cicilan': TextEditingController(
            text: provider.cicilan.toStringAsFixed(0),
          ),
        };
        break;
      case 'emas_perak':
        _controllers = {
          'emas': TextEditingController(
            text: provider.emasTurun.toStringAsFixed(1),
          ),
          'perak': TextEditingController(
            text: provider.perakTurun.toStringAsFixed(1),
          ),
        };
        break;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    final provider = context.read<ZakatProvider>();

    switch (widget.type) {
      case 'fitrah':
        provider.setJumlahJiwa(
          double.tryParse(_controllers['jumlahJiwa']!.text) ?? 1,
        );
        provider.setHargaBeras(
          double.tryParse(_controllers['hargaBeras']!.text) ?? 15000,
        );
        provider.setBerasPerJiwa(
          double.tryParse(_controllers['berasPerJiwa']!.text) ?? 2.5,
        );
        _result = provider.calculateFitrah();
        break;
      case 'maal':
        provider.setTabungan(
          double.tryParse(_controllers['tabungan']!.text) ?? 0,
        );
        provider.setInvestasi(
          double.tryParse(_controllers['investasi']!.text) ?? 0,
        );
        provider.setPiutang(
          double.tryParse(_controllers['piutang']!.text) ?? 0,
        );
        provider.setHutang(double.tryParse(_controllers['hutang']!.text) ?? 0);
        _result = provider.calculateMaal();
        break;
      case 'penghasilan':
        provider.setPenghasilan(
          double.tryParse(_controllers['penghasilan']!.text) ?? 0,
        );
        provider.setPendapatanLain(
          double.tryParse(_controllers['pendapatanLain']!.text) ?? 0,
        );
        provider.setHutangPenghasilan(
          double.tryParse(_controllers['hutangPenghasilan']!.text) ?? 0,
        );
        provider.setCicilan(
          double.tryParse(_controllers['cicilan']!.text) ?? 0,
        );
        _result = provider.calculatePenghasilan();
        break;
      case 'emas_perak':
        provider.setEmasTurun(double.tryParse(_controllers['emas']!.text) ?? 0);
        provider.setPerakTurun(
          double.tryParse(_controllers['perak']!.text) ?? 0,
        );
        _result = provider.calculateEmasPerak();
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.type == 'fitrah'
        ? 480.0
        : (widget.type == 'penghasilan' ? 500.0 : 460.0);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: widget.isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _getTitle(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ..._buildInputFields(),
                      const SizedBox(height: 12),
                      CupertinoButton.filled(
                        onPressed: _calculate,
                        child: Text(AppStrings.zakatHitung),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 16),
                        _buildResult(),
                      ],
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

  String _getTitle() {
    switch (widget.type) {
      case 'fitrah':
        return '🍚 ${AppStrings.zakatKalkulator} ${AppStrings.zakatFitrah}';
      case 'maal':
        return '💰 ${AppStrings.zakatKalkulator} ${AppStrings.zakatMaal}';
      case 'penghasilan':
        return '💼 ${AppStrings.zakatKalkulator} ${AppStrings.zakatPenghasilan}';
      case 'emas_perak':
        return '✨ ${AppStrings.zakatKalkulator} ${AppStrings.zakatEmas}';
      default:
        return AppStrings.zakatKalkulator;
    }
  }

  List<Widget> _buildInputFields() {
    switch (widget.type) {
      case 'fitrah':
        return [
          _buildField(AppStrings.zakatJumlahJiwa, _controllers['jumlahJiwa']!, AppStrings.zakatOrang),
          _buildField(
            AppStrings.zakatHargaBeras,
            _controllers['hargaBeras']!,
            'Rp',
          ),
          _buildField(
            AppStrings.zakatBerasJiwa,
            _controllers['berasPerJiwa']!,
            'kg',
          ),
        ];
      case 'maal':
        return [
          _buildField(AppStrings.zakatTabungan, _controllers['tabungan']!, 'Rp'),
          _buildField(AppStrings.zakatInvestasi, _controllers['investasi']!, 'Rp'),
          _buildField(AppStrings.zakatPiutang, _controllers['piutang']!, 'Rp'),
          _buildField(AppStrings.zakatHutang, _controllers['hutang']!, 'Rp'),
        ];
      case 'penghasilan':
        return [
          _buildField(
            AppStrings.zakatPenghasilanBulan,
            _controllers['penghasilan']!,
            'Rp',
          ),
          _buildField(
            AppStrings.zakatPendapatanLain,
            _controllers['pendapatanLain']!,
            'Rp',
          ),
          _buildField(AppStrings.zakatHutang, _controllers['hutangPenghasilan']!, 'Rp'),
          _buildField(AppStrings.zakatCicilan, _controllers['cicilan']!, 'Rp'),
        ];
      case 'emas_perak':
        return [
          _buildField(AppStrings.zakatEmasGram, _controllers['emas']!, 'gr'),
          _buildField(AppStrings.zakatPerakGram, _controllers['perak']!, 'gr'),
        ];
      default:
        return [];
    }
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              keyboardType: TextInputType.number,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              style: TextStyle(
                color: widget.isDark
                    ? CupertinoColors.white
                    : AppColors.textLight,
                fontSize: 13,
              ),
              placeholderStyle: TextStyle(
                color: widget.isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey2,
                fontSize: 13,
              ),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.textLight
                    : CupertinoColors.tertiarySystemBackground,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            suffix,
            style: TextStyle(
              fontSize: 11,
              color: widget.isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    if (_result == null) return const SizedBox();

    switch (widget.type) {
      case 'fitrah':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.zakat.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _resultRow(
                AppStrings.zakatTotalBeras,
                '${(_result!['totalBeras'] as num).toStringAsFixed(1)} kg',
              ),
              _resultRow(
                AppStrings.zakatTotalUang,
                'Rp ${(_result!['totalUang'] as num).toStringAsFixed(0)}',
              ),
              _resultRow(
                AppStrings.zakatPerJiwa,
                '${(_result!['perJiwa'] as num).toStringAsFixed(1)} kg / Rp ${(_result!['perJiwaUang'] as num).toStringAsFixed(0)}',
              ),
            ],
          ),
        );
      case 'maal':
        final isEligible = _result!['isEligible'] as bool;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEligible
                ? AppColors.zakat.withValues(alpha: 0.1)
                : CupertinoColors.systemRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _resultRow(
                AppStrings.zakatTotalHarta,
                'Rp ${(_result!['totalHarta'] as num).toStringAsFixed(0)}',
              ),
              _resultRow(
                AppStrings.zakatNisabLabel,
                'Rp ${(_result!['nisab'] as num).toStringAsFixed(0)}',
              ),
              if (isEligible)
                _resultRow(
                  AppStrings.zakatProsen,
                  'Rp ${(_result!['zakat'] as num).toStringAsFixed(0)}',
                  isTotal: true,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppStrings.zakatBelumNisab,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ),
            ],
          ),
        );
      case 'penghasilan':
        final isEligible = _result!['isEligible'] as bool;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isEligible
                ? AppColors.zakat.withValues(alpha: 0.1)
                : CupertinoColors.systemRed.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _resultRow(
                AppStrings.zakatTotalPendapatan,
                'Rp ${(_result!['totalPendapatan'] as num).toStringAsFixed(0)}',
              ),
              _resultRow(
                AppStrings.zakatNisabLabel,
                'Rp ${(_result!['nisab'] as num).toStringAsFixed(0)}',
              ),
              if (isEligible)
                _resultRow(
                  AppStrings.zakatProsen,
                  'Rp ${(_result!['zakat'] as num).toStringAsFixed(0)}',
                  isTotal: true,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    AppStrings.zakatBelumNisab,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                ),
            ],
          ),
        );
      case 'emas_perak':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.zakat.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _resultRow(
                AppStrings.zakatEmasLabel,
                '${(_result!['zakatEmas'] as num).toStringAsFixed(2)} gr',
                isTotal: _result!['isEligibleEmas'] as bool,
              ),
              if (!(_result!['isEligibleEmas'] as bool))
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    AppStrings.zakatEmasNisab,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              _resultRow(
                AppStrings.zakatPerakLabel,
                '${(_result!['zakatPerak'] as num).toStringAsFixed(2)} gr',
                isTotal: _result!['isEligiblePerak'] as bool,
              ),
              if (!(_result!['isEligiblePerak'] as bool))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    AppStrings.zakatPerakNisab,
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _resultRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.zakat,
            ),
          ),
        ],
      ),
    );
  }
}
