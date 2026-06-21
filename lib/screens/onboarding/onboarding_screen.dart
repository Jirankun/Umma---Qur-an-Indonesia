import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../config/colors.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_storage.dart';
import '../home/home_screen.dart';

// ─── CONSTANTS ─────────────────────────────────────────────
const _kPageCount = 4;
const _kParticleCount = 30;

// ─── PAGE DATA ─────────────────────────────────────────────
final List<_OnboardingPage> _pages = [
  _OnboardingPage(
    icon: CupertinoIcons.moon_stars_fill,
    title: 'Selamat Datang di Umma',
    subtitle:
        'Aplikasi Muslim iOS-style untuk ibadah sehari-hari & kebutuhan Ramadhan. Lengkap dengan Al-Qur\'an, doa, hadits, dan banyak lagi.',
    gradientColors: [AppColors.primary, AppColors.primaryDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.book_fill,
    title: "Al-Qur'an Digital",
    subtitle:
        'Baca 114 surah & 30 juz dengan audio 6 qari, tafsir Kemenag RI, bookmark ayat, fitur khatam plan, dan scroll presisi ke ayat.',
    gradientColors: [AppColors.accent, AppColors.onboardingEmeraldDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.clock_fill,
    title: 'Ibadah Sehari-hari',
    subtitle:
        'Jadwal sholat otomatis 44 kota, kumpulan doa & dzikir, 9 kitab hadits, fiqih Islam, tasbih digital, dan kompas kiblat real-time.',
    gradientColors: [AppColors.onboardingBlue, AppColors.onboardingBlueDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.sparkles,
    title: 'Pembaruan Terbaru',
    subtitle:
        'Tracker ibadah harian, jurnal refleksi, kalkulator zakat, tracker haid, Muslim AI, studi Ramadhan, dan sinkronisasi data P2P via QR.',
    gradientColors: [AppColors.onboardingPurple, AppColors.onboardingPurpleDark],
  ),
];

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}

// ─── PARTICLE DATA ─────────────────────────────────────────
class _Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double wobbleOffset;
  double wobblePhase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobbleOffset,
    required this.wobblePhase,
  });
}

// ─── PARTICLE BACKGROUND PAINTER ───────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      final wobble = sin(p.wobblePhase) * p.wobbleOffset;
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x + wobble, p.y),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// ─── ONBOARDING SCREEN ─────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  // Page transition animation
  late final AnimationController _pageAnimCtrl;
  late final Animation<double> _fadeAnim;

  // Particle animation
  late final AnimationController _particleAnimCtrl;
  final _particles = <_Particle>[];
  final _rng = Random(42);
  String _appVersion = '';
  String _changelog = '';

  @override
  void initState() {
    super.initState();

    // Page animation
    _pageAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _pageAnimCtrl,
      curve: Curves.easeOut,
    );
    _pageAnimCtrl.forward();

    // Particle animation — continuous loop
    _particleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _generateParticles();
    _loadVersionAndChangelog();
  }

  // ─── PARTICLE GENERATION ─────────────────────────────────
  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < _kParticleCount; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        size: 2 + _rng.nextDouble() * 8,
        speed: 0.003 + _rng.nextDouble() * 0.008,
        opacity: 0.03 + _rng.nextDouble() * 0.06,
        wobbleOffset: 3 + _rng.nextDouble() * 10,
        wobblePhase: _rng.nextDouble() * 2 * pi,
      ));
    }
    // Particles updated inside AnimatedBuilder
  }

  void _updateParticles() {
    for (final p in _particles) {
      // Move upward at constant speed
      p.y -= p.speed * 0.6;
      if (p.y < -0.05) {
        p.y = 1.05;
        p.x = _rng.nextDouble();
      }
      // Wobble
      p.wobblePhase += 0.03;
    }
  }

  // ─── LOAD ASSET DATA ─────────────────────────────────────
  /// Baca file [update_infos.txt] dan simpan konten mentah (raw) apa adanya.
  Future<void> _loadVersionAndChangelog() async {
    try {
      final content =
          await rootBundle.loadString('assets/update/update_infos.txt');
      final lines = content.split('\n');

      // Ekstrak versi dari baris pertama: "Umma v1.0.1"
      final firstLine = lines.first.trim();
      final versionMatch = RegExp(r'v[\d.]+').firstMatch(firstLine);
      if (versionMatch != null && mounted) {
        setState(() => _appVersion = versionMatch.group(0)!);
      }

      // Simpan sisa konten MENTAH apa adanya (termasuk "Perubahan :", "-", "dev :", dll)
      if (lines.length > 1 && mounted) {
        final rawContent = lines.skip(1).join('\n').trim();
        setState(() => _changelog = rawContent);
      }
    } catch (_) {
      // Fallback: keep defaults
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pageAnimCtrl.dispose();
    _particleAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorage().setBool('umma_onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      child: SafeArea(
        child: Stack(
          children: [
            // ─── Particle Background ───
            AnimatedBuilder(
              animation: _particleAnimCtrl,
              builder: (context, _) {
                _updateParticles();
                final particleColor = CupertinoColors.white;
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _ParticlePainter(
                      particles: _particles,
                      color: particleColor,
                    ),
                    size: Size.infinite,
                  ),
                );
              },
            ),

            // ─── Main Content ───
            Column(
              children: [
                // ─── Skip button ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentPage < _kPageCount - 1)
                        GestureDetector(
                          onTap: _completeOnboarding,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.textLight
                                  : CupertinoColors.systemGrey6,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Lewati',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Pages ───
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _pageAnimCtrl.reset();
                      _pageAnimCtrl.forward();
                    },
                    itemCount: _kPageCount,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _fadeAnim,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _currentPage == index
                                ? _fadeAnim.value
                                : 1.0,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                _currentPage == index
                                    ? (1 - _fadeAnim.value) * 30
                                    : 0,
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: _buildPage(context, _pages[index]),
                      );
                    },
                  ),
                ),

                // ─── Page Indicator ───
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _kPageCount,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _pages[i].gradientColors[0]
                              : (isDark
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // ─── Next / Mulai button ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: GestureDetector(
                    onTap: () {
                      if (_currentPage < _kPageCount - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _pages[_currentPage].gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _pages[_currentPage]
                                .gradientColors[0]
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage < _kPageCount - 1
                                ? 'Lanjut'
                                : 'Mulai',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: CupertinoColors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < _kPageCount - 1
                                ? CupertinoIcons.chevron_right
                                : CupertinoIcons.check_mark_circled_solid,
                            size: 18,
                            color: CupertinoColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    _OnboardingPage page,
  ) {
    final isLastPage = _pages.indexOf(page) == _kPageCount - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: page.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: page.gradientColors[0].withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    page.icon,
                    size: 48,
                    color: CupertinoColors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: CupertinoColors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Subtitle
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.white.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // ─── LAST PAGE: Raw Changelog + Version ───
                if (isLastPage) ...[
                  if (_changelog.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxHeight: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          // Raw text — apa adanya dari file
                          _changelog,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            fontFamily: '.SF Mono',
                            fontWeight: FontWeight.w500,
                            color: CupertinoColors.white
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Version badge
                  if (_appVersion.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _appVersion,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
