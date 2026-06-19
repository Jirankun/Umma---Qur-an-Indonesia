import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../providers/theme_provider.dart';

// ── Cupertino-style progress bar ──────────────────────────────────────────
class _CupertinoProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const _CupertinoProgressBar({
    required this.value,
    this.color = AppColors.toolPurple,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
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

// ── Ripple data model ─────────────────────────────────────────────────────
class _RippleData {
  final AnimationController controller;
  final double delay; // 0.0 – 1.0, kapan ripple mulai muncul

  _RippleData(this.controller, this.delay);
}

// ── Ripple painter — efek air lebih dramatis ─────────────────────────────
class _RipplePainter extends CustomPainter {
  final List<_RippleData> ripples;
  final bool isDark;

  _RipplePainter(this.ripples, {this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2; // ~110

    for (final r in ripples) {
      final p = r.controller.value;
      // Staggered appearance
      final effectiveP = ((p - r.delay) / (1 - r.delay)).clamp(0.0, 1.0);
      if (effectiveP <= 0) continue;

      // Radius meluas hingga 3x button (sebar luas)
      final radius = maxRadius * effectiveP * 3.0;

      // Opacity turun gradual dari 55% → 0%
      final opacity = (1 - effectiveP) * 0.55;

      // Stroke menipis seiring meluas: tebal → tipis
      final strokeW = 2.0 + (1 - effectiveP) * 8;

      // Warna ripple: putih di dark theme, purple di light theme (dengan opacity)
      final rippleColor = isDark
          ? AppColors.tasbihPurpleLight // light purple di dark bg
          : AppColors.toolPurple;

      // ── Layer 1: Fill samar di dalam ──
      final fillPaint = Paint()
        ..color = rippleColor.withValues(alpha: opacity * 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * 0.7, fillPaint);

      // ── Layer 2: Stroke cincin air ──
      final strokePaint = Paint()
        ..color = rippleColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      canvas.drawCircle(center, radius, strokePaint);

      // ── Layer 3: Inner highlight tipis (efek kilau air) ──
      if (opacity > 0.1) {
        final highlightPaint = Paint()
          ..color = (isDark ? CupertinoColors.white : AppColors.tasbihPurpleHighlight)
              .withValues(alpha: opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(center, radius * 0.85, highlightPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) => true;
}

// ── Ripple counter widget ─────────────────────────────────────────────────
class _RippleCounter extends StatefulWidget {
  final int count;
  final int target;
  final double progress;
  final bool isCompleted;
  final bool isDark;
  final VoidCallback onTap;

  const _RippleCounter({
    required this.count,
    required this.target,
    required this.progress,
    required this.isCompleted,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_RippleCounter> createState() => _RippleCounterState();
}

class _RippleCounterState extends State<_RippleCounter>
    with TickerProviderStateMixin {
  final List<_RippleData> _ripples = [];

  void _handleTap() {
    if (widget.isCompleted) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Spawn 4 ripples cascading — efek ombak air
    final baseDuration = 800;
    for (int i = 0; i < 4; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: baseDuration + i * 80),
      );
      final ripple = _RippleData(controller, i * 0.08);
      _ripples.add(ripple);

      controller.addListener(() => setState(() {}));
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.dispose();
          _ripples.removeWhere((r) => r.controller == controller);
        }
      });
      controller.forward();
    }

    widget.onTap();
  }

  @override
  void dispose() {
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.toolPurple;
    final bgColor = widget.isDark
        ? AppColors.surfaceDark
        : CupertinoColors.white;

    return GestureDetector(
      onTap: _handleTap,
      child: CustomPaint(
        painter: _RipplePainter(_ripples, isDark: widget.isDark),
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.count}',
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  fontFamily: '.SF Mono',
                  color: widget.isDark
                      ? CupertinoColors.white
                      : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '/ ${widget.target}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: _CupertinoProgressBar(
                    value: widget.progress,
                    color: accentColor,
                    height: 4,
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

// ── Completion overlay ────────────────────────────────────────────────────
class _CompletionBadge extends StatelessWidget {
  final bool isDark;

  const _CompletionBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.toolPurple.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.check_mark_circled_solid,
            color: AppColors.toolPurple,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            'Dzikir Selesai!',
            style: TextStyle(
              color: AppColors.toolPurple,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main screen ───────────────────────────────────────────────────────────
class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.tasbihBgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.circle_fill,
              size: 18,
              color: AppColors.toolPurple,
            ),
            SizedBox(width: 8),
            Text('Dzikir Digital'),
          ],
        ),
      ),
      child: SafeArea(
        child: Consumer<TasbihProvider>(
          builder: (context, provider, _) {
            final dzikir = provider.currentDzikir;
            final progress = provider.progress;

            return Column(
              children: [
                // ── Dzikir info card ──
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textLight
                          : CupertinoColors.systemGrey5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (dzikir['title'] as String).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: isDark
                              ? AppColors.toolPurple
                              : AppColors.toolPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dzikir['arabic'] as String,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          fontFamily: 'Lateef',
                          color: isDark
                              ? CupertinoColors.white
                              : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '"${dzikir['latin']}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Circular counter + ripple ──
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _RippleCounter(
                          count: provider.count,
                          target: dzikir['target'] as int,
                          progress: progress,
                          isCompleted: provider.isCompleted,
                          isDark: isDark,
                          onTap: () => provider.incrementAndAutoAdvance(),
                        ),
                        const SizedBox(height: 20),
                        if (provider.isCompleted && provider.isLastDzikir)
                          _CompletionBadge(isDark: isDark),
                      ],
                    ),
                  ),
                ),

                // ── Controls ──
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : CupertinoColors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textLight
                          : CupertinoColors.systemGrey5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.chevron_left,
                          size: 22,
                        ),
                        onPressed: () => provider.changeDzikir(-1),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? AppColors.textLight
                            : CupertinoColors.systemGrey5,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: provider.reset,
                        child: const Icon(
                          CupertinoIcons.refresh,
                          size: 22,
                          color: AppColors.toolPurple,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        color: isDark
                            ? AppColors.textLight
                            : CupertinoColors.systemGrey5,
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.chevron_right,
                          size: 22,
                        ),
                        onPressed: () => provider.changeDzikir(1),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
