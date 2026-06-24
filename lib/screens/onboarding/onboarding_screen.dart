import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/local_storage.dart';
import '../home/home_screen.dart';
import '../../utils/app_info.dart';

// ─── CONSTANTS ────────────────────────────────────────────
const _kPageCount = 5;
const _kParticleCount = 50;



// ─── PAGE DATA (RUMAYSHO STYLE) ────────────────────────────
final List<_OnboardingPage> _pages = [
  _OnboardingPage(
    icon: CupertinoIcons.moon_stars_fill,
    title: 'Selamat Datang di Umma',
    arabicText: 'السلام عليكم ورحمة الله',
    subtitle:
        'Segala puji bagi Allah. Umma hadir untuk memudahkan Anda dalam menuntut ilmu syar\'i dan mengamalkannya. Aplikasi ini menyediakan Al-Qur\'an dengan tafsir, kumpulan hadits shahih, doa & dzikir pilihan, serta panduan fikih praktis. Semoga menjadi wasilah istiqomah Anda dalam beribadah.',
    gradientColors: [AppColors.primary, AppColors.primaryDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.book_fill,
    title: "Al-Qur'an Digital dengan Tafsir",
    arabicText: 'القرآن كلام الله',
    subtitle:
        'Baca Al-Qur\'an 114 surah dengan terjemah dan tafsir lengkap. Dilengkapi audio murottal, bookmark ayat, catatan pribadi, dan target khatam. Nikmati pengalaman membaca yang khusyuk dengan tampilan mushaf yang nyaman di mata.',
    gradientColors: [AppColors.accent, AppColors.onboardingEmeraldDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.clock_fill,
    title: 'Jadwal Shalat & Dzikir Harian',
    arabicText: 'أقم الصلاة لذكري',
    subtitle:
        'Jadwal shalat otomatis untuk kota Anda dengan notifikasi yang akurat. Lengkap dengan dzikir pagi-petua, doa sehari-hari, hadits Arbain, dan kompas kiblat. Jangan lewatkan waktu shalat dengan alarm yang tepat.',
    gradientColors: [AppColors.onboardingBlue, AppColors.onboardingBlueDark],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.sparkles,
    title: 'Fitur Lengkap untuk Muslim',
    arabicText: 'طلب العلم فريضة',
    subtitle:
        'Tracker ibadah harian, jurnal muhasabah, kalkulator zakat, tracker haid untuk muslimah, dan Muslim AI untuk tanya jawab agama. Semua fitur dirancang untuk membantu Anda lebih dekat dengan Allah.',
    gradientColors: [
      AppColors.onboardingPurple,
      AppColors.onboardingPurpleDark,
    ],
  ),
  _OnboardingPage(
    icon: CupertinoIcons.doc_text_fill,
    title: 'Catatan Update',
    arabicText: '', // KOSONG KARENA CARD VERSI GAK PUNYA ARAB
    subtitle: '', // KOSONG KARENA CARD VERSI GAK PUNYA SUBTITLE
    gradientColors: [AppColors.toolIndigo, AppColors.onboardingIndigoDark],
  ),
];

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String arabicText;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.arabicText,
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

// ─── PARTICLE PAINTER ──────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter({required this.particles, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final wobble = sin(p.wobblePhase) * p.wobbleOffset;
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width + wobble, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// ─── FLIP TRANSITION (WITH FADE) ───────────────────────────
class FlipTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const FlipTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = (1 - animation.value) * pi;
        final opacity = animation.value;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateX(angle),
          alignment: Alignment.center,
          child: Opacity(opacity: opacity, child: child),
        );
      },
      child: child,
    );
  }
}

// ─── PARTICLE LAYER (BACKGROUND) ───────────────────────────
class _ParticleLayer extends StatefulWidget {
  final AnimationController controller;
  const _ParticleLayer({required this.controller});

  @override
  State<_ParticleLayer> createState() => _ParticleLayerState();
}

class _ParticleLayerState extends State<_ParticleLayer> {
  final _particles = <_Particle>[];
  final _rng = Random(42);

  @override
  void initState() {
    super.initState();
    _generateParticles();
    widget.controller.addListener(_updateParticles);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateParticles);
    super.dispose();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < _kParticleCount; i++) {
      _particles.add(
        _Particle(
          x: _rng.nextDouble(),
          y: _rng.nextDouble(),
          size: 0 + _rng.nextDouble() * 6,
          speed: 0.001,
          opacity: 0.3 + _rng.nextDouble() * 0.4,
          wobbleOffset: 2 + _rng.nextDouble() * 8,
          wobblePhase: _rng.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  void _updateParticles() {
    setState(() {
      for (final p in _particles) {
        p.y -= p.speed;
        if (p.y < -0.05) {
          p.y = 1.05;
          p.x = _rng.nextDouble();
        }
        p.wobblePhase += 0.02;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParticlePainter(
        particles: _particles,
        color: AppColors.cupertinoWhite,
      ),
      size: Size.infinite,
    );
  }
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

  late final AnimationController _particleAnimCtrl;
  String _changelog = '';

  @override
  void initState() {
    super.initState();

    _particleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _loadVersionAndChangelog();
  }

  Future<void> _loadVersionAndChangelog() async {
    try {
      final content = await rootBundle.loadString(
        'assets/update/update_infos.txt',
      );
      final lines = content.split('\n');

      if (lines.isNotEmpty && mounted) {
        final rawContent = lines.join('\n').trim();
        setState(() => _changelog = rawContent);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    _particleAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await LocalStorage().setBool('umma_onboarding_done_${AppInfo.version}', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  void _skipToLastPage() {
    _pageController.animateToPage(
      _kPageCount - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final screenWidth = MediaQuery.of(context).size.width;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : const Color.fromARGB(255, 0, 0, 0),
      child: Stack(
        children: [
          // ─── PARTICLE LAYER (BACKGROUND) ───
          Positioned.fill(
            child: IgnorePointer(
              child: _ParticleLayer(controller: _particleAnimCtrl),
            ),
          ),

          // ─── MAIN CONTENT ───
          SafeArea(
            child: Column(
              children: [
                // ─── Skip button ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        opacity: _currentPage < _kPageCount - 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: _skipToLastPage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _pages[_currentPage].gradientColors
                                    .map((c) => c.withValues(alpha: 0.3))
                                    .toList(),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.cupertinoWhite.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _pages[_currentPage].gradientColors[0]
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              AppStrings.onboardingLewati,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cupertinoWhite,
                              ),
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
                    },
                    itemCount: _kPageCount,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 0.0;
                          if (_pageController.position.haveDimensions) {
                            value =
                                index.toDouble() -
                                (_pageController.page ??
                                    _currentPage.toDouble());
                          }

                          value = value.clamp(-1.0, 1.0);

                          final double scale = 1.0 - (value.abs() * 0.08);
                          final double rotateY = value * 0.2;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(rotateY)
                              // ignore: deprecated_member_use
                              ..scale(scale),
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                        child: _buildPage(context, _pages[index], screenWidth),
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
                              : AppColors.cupertinoWhite.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // ─── Next / Mulai button (FLIP + FADE) ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FlipTransition(
                            animation: animation,
                            child: child,
                          );
                        },
                    child: GestureDetector(
                      key: ValueKey(_currentPage),
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
                            colors: _pages[_currentPage].gradientColors
                                .map((c) => c.withValues(alpha: 0.4))
                                .toList(),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.cupertinoWhite.withValues(alpha: 0.4),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _pages[_currentPage].gradientColors[0]
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
                                  ? AppStrings.onboardingLanjut
                                  : AppStrings.onboardingMulai,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.cupertinoWhite,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentPage < _kPageCount - 1
                                  ? CupertinoIcons.chevron_right
                                  : CupertinoIcons.check_mark_circled_solid,
                              size: 18,
                              color: AppColors.cupertinoWhite,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    _OnboardingPage page,
    double screenWidth,
  ) {
    final isFirstPage = _pages.indexOf(page) == 0;
    final isChangelogPage = _pages.indexOf(page) == 4;

    // Responsive font size untuk teks Arab
    final arabicFontSize = screenWidth < 360
        ? 15.0
        : screenWidth < 400
        ? 25.0
        : 30.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: page.gradientColors
                .map((c) => c.withValues(alpha: 0.3))
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.cupertinoWhite.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: page.gradientColors[0].withValues(alpha: 0.3),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── CARD VERSI (CHANGELOG — TANPA NESTED SCROLL) ───
                if (isChangelogPage) ...[
                  // Title
                  Center(
                    child: Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cupertinoWhite,
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Version labels (parsed from raw changelog)
                  if (_changelog.isNotEmpty)
                    ..._buildChangelogWidgets(),
                  if (_changelog.isEmpty)
                    const Center(
                      child: Text(
                        AppStrings.onboardingVersionLoading,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.cupertinoWhite,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ] else ...[
                  // ─── CARD NORMAL (DENGAN ICON & ARAB) ───
                  Center(
                    child: isFirstPage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              'assets/onboarding_icon.png',
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.cupertinoWhite.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(27),
                              border: Border.all(
                                color: AppColors.cupertinoWhite.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Icon(
                              page.icon,
                              size: 48,
                              color: AppColors.cupertinoWhite,
                            ),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // ─── ARABIC TEXT ───
                  Center(
                    child: Text(
                      page.arabicText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: arabicFontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'ScheherazadeNew',
                        color: AppColors.cupertinoWhite.withValues(alpha: 0.95),
                        height: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── TITLE ───
                  Center(
                    child: Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cupertinoWhite,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── SUBTITLE ───
                  Center(
                    child: Text(
                      page.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.cupertinoWhite.withValues(alpha: 0.9),
                        height: 1.5,
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

  /// Parse changelog text into formatted version blocks.
  List<Widget> _buildChangelogWidgets() {
    final lines = _changelog.split('\n');
    final widgets = <Widget>[];
    String? currentVersion;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Detect version header: "Umma v1.0.1" or "v1.0.1"
      final versionMatch = RegExp(r'^[Uu]mma\s+v?[\d.]+').firstMatch(line);
      if (versionMatch != null) {
        currentVersion = line;
        widgets.add(const SizedBox(height: 12));
        widgets.add(
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.cupertinoWhite.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.cupertinoWhite.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              currentVersion,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.cupertinoWhite,
                height: 1.3,
              ),
            ),
          ),
        );
        continue;
      }

      // Detect "Perubahan :" / "dev :" section headers
      if (line.endsWith(':')) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.cupertinoWhite.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
          ),
        );
        continue;
      }

      // Bullet point
      if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.cupertinoWhite,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: AppColors.cupertinoWhite.withValues(alpha: 0.85),
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Other lines (fallback)
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.cupertinoWhite.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
        ),
      );
    }

    return widgets;
  }
}
