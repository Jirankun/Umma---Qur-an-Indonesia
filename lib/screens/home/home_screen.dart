// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/background_sound_provider.dart';
import '../../providers/update_provider.dart';
import '../../models/models.dart';
import '../../utils/date_helper.dart';
import '../quran/quran_index_screen.dart';
import '../quran/surah_reader_screen.dart';
import '../quran/juz_reader_screen.dart';
import '../doa/doa_home_screen.dart';
import '../hadits/hadits_home_screen.dart';
import '../hadits/hadits_arbain_screen.dart';
import '../fiqih/fiqih_home_screen.dart';
import '../zakat/zakat_screen.dart';
import '../tasbih/tasbih_screen.dart';
import '../kompas/kompas_screen.dart';
import '../muslim_ai/muslim_ai_screen.dart';
import '../tracker/tracker_screen.dart';
import '../tracker/tracker_dashboard_screen.dart';
import '../jurnal/jurnal_dashboard_screen.dart';
import '../haid/haid_tracker_screen.dart';
import '../murattal/murattal_screen.dart';
import '../user/user_profile_screen.dart';
import 'widgets/hero_card.dart';
import 'widgets/daily_goal_tracker.dart';
import 'widgets/tool_grid.dart';
import 'widgets/daily_knowledge_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/daily_quest_card.dart';
import 'widgets/update_popup.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedTab = 0;
  late final PageController _pageController;

  /// GlobalKey untuk mengontrol video HeroCard dari sini
  final _homeContentKey = GlobalKey<HomeContentState>();

  /// Apakah user sedang di tab Beranda (tab 0).
  /// Digunakan oleh HomeContentState untuk cek sebelum restart sound.
  bool get isOnBerandaTab => _selectedTab == 0;

  List<Widget> get _screens => [
        HomeContent(key: _homeContentKey),
        const QuranIndexScreen(),
        const DoaHomeScreen(),
        const UserProfileScreen(),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
    _loadData();
    final ctx = context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctx.read<BackgroundSoundProvider>().start();
      _checkForUpdate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  void _checkForUpdate() {
    final provider = context.read<UpdateProvider>();
    if (provider.status == UpdateStatus.idle ||
        provider.status == UpdateStatus.noUpdate ||
        provider.status == UpdateStatus.error) {
      final ctx = context;
      provider.checkForUpdate().then((_) {
        if (!mounted) return;
        if (provider.status == UpdateStatus.updateAvailable) {
          showUpdatePopup(ctx, provider);
        }
      }).catchError((_) {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App di-minimize → pause video + stop semua audio
      _homeContentKey.currentState?.pauseVideo();
      context.read<BackgroundSoundProvider>().stop();
      context.read<QuranProvider>().stopAudio();
    } else if (state == AppLifecycleState.resumed) {
      final bgSound = context.read<BackgroundSoundProvider>();
      if (_selectedTab == 0) {
        _homeContentKey.currentState?.resumeVideo();
        bgSound.start();
      }
      // Retry install APK setelah kembali dari settings
      final updateProvider = context.read<UpdateProvider>();
      if (updateProvider.status == UpdateStatus.installPermissionNeeded) {
        final ctx = context;
        updateProvider.retryInstall().then((_) {
          if (!mounted) return;
          if (updateProvider.status == UpdateStatus.installPermissionNeeded) {
            showInstallPermissionPopup(ctx, updateProvider);
          }
        }).catchError((_) {});
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _selectedTab = index);
    final bgSound = context.read<BackgroundSoundProvider>();
    if (index == 0) {
      _homeContentKey.currentState?.resumeVideo();
      bgSound.start();
    } else {
      _homeContentKey.currentState?.pauseVideo();
      bgSound.stop();
    }
  }

  void _onTabTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimesProvider>().fetchPrayerTimes();
      context.read<TrackerProvider>().loadTrackers();
      context.read<QuranProvider>().loadStoredData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _screens,
          ),
        ),
        _buildBottomNavBar(isDark),
      ],
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    final items = [
      (icon: CupertinoIcons.house_fill, label: AppStrings.homeTitle),
      (icon: CupertinoIcons.book_fill, label: AppStrings.quranTitle),
      (icon: CupertinoIcons.heart_fill, label: AppStrings.doaTitle),
      (icon: CupertinoIcons.person_fill, label: AppStrings.userProfile),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navbar(isDark),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Active indicator bar ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: 3,
              margin: EdgeInsets.only(
                left: (MediaQuery.of(context).size.width / 4) * _selectedTab,
                right:
                    (MediaQuery.of(context).size.width / 4) *
                    (3 - _selectedTab),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2),
                ),
              ),
            ),
            // ── Tab items ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: List.generate(items.length, (i) {
                  final isActive = _selectedTab == i;
                  final item = items[i];
                  return Expanded(
                    child: _TabItem(
                      isActive: isActive,
                      isDark: isDark,
                      icon: item.icon,
                      label: item.label,
                      onTap: () => _onTabTap(i),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BOTTOM TAB ITEM ────────────────────────────────────────
class _TabItem extends StatefulWidget {
  final bool isActive;
  final bool isDark;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TabItem({
    required this.isActive,
    required this.isDark,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _animController.forward();
  void _onTapCancel() => _animController.reverse();

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = widget.isDark
        ? AppColors.cupertinoSystemGrey
        : AppColors.cupertinoSystemGrey2;
    final color = widget.isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (_) {
        _animController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 24, color: color),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SPEED-DIAL FAB: Arba'in + Murattal ──────────────────
class _SpeedDialFab extends StatefulWidget {
  final bool isDark;
  final VoidCallback onArbainTap;
  final VoidCallback onMurattalTap;

  const _SpeedDialFab({
    required this.isDark,
    required this.onArbainTap,
    required this.onMurattalTap,
  });

  @override
  State<_SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<_SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _handleTap(VoidCallback onTap) {
    _toggle();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Child FAB: Arba'in ──
          _buildChildItem(
            icon: CupertinoIcons.book_fill,
            label: AppStrings.homeArbainTitle,
            color: AppColors.heat4,
            index: 1,
            onTap: () => _handleTap(widget.onArbainTap),
          ),
          const SizedBox(height: 12),
          // ── Child FAB: Murattal ──
          _buildChildItem(
            icon: CupertinoIcons.music_mic,
            label: AppStrings.murattalTitle,
            color: AppColors.toolIndigo,
            index: 0,
            onTap: () => _handleTap(widget.onMurattalTap),
          ),
          const SizedBox(height: 12),
          // ── Main FAB ──
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.heat4,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.heat4.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _expanded ? 0.125 : 0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  CupertinoIcons.book_fill,
                  size: 22,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildItem({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final expandValue = _expandAnimation.value;
        final fadeValue = _fadeAnimation.value;

        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - expandValue)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label (to the LEFT of icon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? AppColors.surfaceDark
                    : AppColors.cupertinoWhite,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color                    : AppColors.blackWithAlpha(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark
                      ? AppColors.cupertinoWhite
                      : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 20,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  final _heroCardKey = GlobalKey<HeroCardState>();
  DateTime _currentTime = DateTime.now();

  /// Public wrapper: pause video HeroCard
  void pauseVideo() => _heroCardKey.currentState?.pauseVideo();

  /// Public wrapper: resume video HeroCard (hanya jika sudah initialized)
  void resumeVideo() {
    if (mounted && _heroCardKey.currentState != null) {
      _heroCardKey.currentState!.resumeVideo();
    }
  }

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _currentTime = DateTime.now());
        _startClock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final prayerProvider = Provider.of<PrayerTimesProvider>(context);
    final trackerProvider = Provider.of<TrackerProvider>(context);
    final todayPrayer = prayerProvider.todayPrayer;

    return Stack(
      children: [
        CupertinoPageScaffold(
          backgroundColor: isDark
              ? AppColors.bgDark
              : AppColors.bgLight,
          child: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(isDark, prayerProvider, todayPrayer),
                ),
                SliverToBoxAdapter(child: _buildCountdown(isDark)),
                SliverToBoxAdapter(child: _buildDateInfo(isDark)),
                SliverToBoxAdapter(
                  child: HeroCard(
                    key: _heroCardKey,
                    prayerTime: todayPrayer,
                    currentTime: _currentTime,
                    isDark: isDark,
                    city: prayerProvider.selectedCity,
                  ),
                ),
                SliverToBoxAdapter(
                  child: DailyGoalTracker(
                    summary: trackerProvider.getTrackerSummary(),
                    isDark: isDark,
                    onTap: () => _navigateTo(context, '/tracker-harian'),
                  ),
                ),
                SliverToBoxAdapter(child: DailyQuestCard(isDark: isDark)),
                SliverToBoxAdapter(child: _buildLastReadCard(isDark)),
                SliverToBoxAdapter(
                  child: ToolGrid(
                    isDark: isDark,
                    onToolTap: (route) => _navigateTo(context, route),
                  ),
                ),
                SliverToBoxAdapter(child: DailyKnowledgeCard(isDark: isDark)),
                SliverToBoxAdapter(child: QuoteCard(isDark: isDark)),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ),
        // ─── Speed-Dial FAB: Arba'in + Murattal ───
        _SpeedDialFab(
          isDark: isDark,
          onArbainTap: () => _navigateTo(context, '/arbain'),
          onMurattalTap: () => _navigateTo(context, '/murattal'),
        ),
      ],
    );
  }

  Widget _buildHeader(
    bool isDark,
    PrayerTimesProvider prayerProvider,
    PrayerTime? todayPrayer,
  ) {
    final timeStr =
        '${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}';
    final greeting = _currentTime.hour < 11
        ? AppStrings.homeGreetingMorning
        : _currentTime.hour < 15
        ? AppStrings.homeGreetingAfternoon
        : _currentTime.hour < 18
        ? AppStrings.homeGreetingEvening
        : AppStrings.homeGreetingNight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.location_fill,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${prayerProvider.selectedCity} (${ApiConfig.getTimezone(prayerProvider.selectedCity)})',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.textLight : CupertinoColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.borderSubtle
                    : CupertinoColors.systemGrey5,
              ),
            ),
            child: Text(
              timeStr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: '.SF Mono',
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown(bool isDark) {
    final prayerProvider = Provider.of<PrayerTimesProvider>(
      context,
      listen: false,
    );
    final todayPrayer = prayerProvider.todayPrayer;
    final error = prayerProvider.error;

    // If no data and there's an error, show error state
    if (todayPrayer == null && error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: 18,
                  color: CupertinoColors.systemRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.homeFailedLoadPrayer,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      AppStrings.homeCheckInternet,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Text(AppStrings.homeReload, style: const TextStyle(fontSize: 12)),
                onPressed: () => prayerProvider.fetchPrayerTimes(),
              ),
            ],
          ),
        ),
      );
    }

    final cityOffset = ApiConfig.getUtcOffset(prayerProvider.selectedCity);
    final nextPrayer = todayPrayer?.getNextPrayer(_currentTime, cityUtcOffset: cityOffset);
    final countdown = todayPrayer?.getCountdownTo(nextPrayer ?? '', cityUtcOffset: cityOffset) ?? 0;
    final hours = countdown ~/ 3600;
    final minutes = (countdown % 3600) ~/ 60;
    final seconds = countdown % 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.moon_stars_fill,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nextPrayer != null ? '${AppStrings.homeToward} $nextPrayer' : AppStrings.homePrayerSchedule,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  Text(
                    '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontFamily: '.SF Mono',
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(bool isDark) {
    final months = [
      '',
      AppStrings.monthJanuari,
      AppStrings.monthFebruari,
      AppStrings.monthMaret,
      AppStrings.monthApril,
      AppStrings.monthMei,
      AppStrings.monthJuni,
      AppStrings.monthJuli,
      AppStrings.monthAgustus,
      AppStrings.monthSeptember,
      AppStrings.monthOktober,
      AppStrings.monthNovember,
      AppStrings.monthDesember,
    ];
    final days = [
      AppStrings.daySenin,
      AppStrings.daySelasa,
      AppStrings.dayRabu,
      AppStrings.dayKamis,
      AppStrings.dayJumat,
      AppStrings.daySabtu,
      AppStrings.dayMinggu,
    ];
    final dateStr =
        '${days[_currentTime.weekday - 1]}, ${_currentTime.day} ${months[_currentTime.month]} ${_currentTime.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? CupertinoColors.systemGrey
              : CupertinoColors.systemGrey,
        ),
      ),
    );
  }

  // ─── LAST READ CARD ───────────────────────────────────────
  Widget _buildLastReadCard(bool isDark) {
    final quranProvider = context.watch<QuranProvider>();
    final lastRead = quranProvider.lastRead;
    if (lastRead == null) return const SizedBox.shrink();

    final surah = quranProvider.surahs
        .where((s) => s.nomor == lastRead.surahId)
        .firstOrNull;
    final totalAyat = surah?.jumlahAyat ?? 0;
    final progressText = totalAyat > 0
        ? AppStrings.homeAyatDariFormat
            .replaceAll('{number}', '${lastRead.ayahNumber}')
            .replaceAll('{total}', '$totalAyat')
        : AppStrings.homeAyatFormat.replaceAll('{number}', '${lastRead.ayahNumber}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GestureDetector(
        onTap: () async {
          _heroCardKey.currentState?.pauseVideo();
          await context.read<BackgroundSoundProvider>().stop();
          if (!mounted) return;
          final bgSound = context.read<BackgroundSoundProvider>();
          final homeState =
              context.findAncestorStateOfType<_HomeScreenState>();
          final route = lastRead.isJuz && lastRead.juzNumber != null
              ? CupertinoPageRoute(
                  builder: (_) => JuzReaderScreen(
                    juzNumber: lastRead.juzNumber!,
                    focusSurahId: lastRead.surahId,
                    focusAyahNumber: lastRead.ayahNumber,
                  ),
                )
              : CupertinoPageRoute(
                  builder: (_) => SurahReaderScreen(
                    surahId: lastRead.surahId,
                    ayahNumber: lastRead.ayahNumber,
                  ),
                );
          if (!mounted) return;
          final nav = Navigator.of(context);
          nav.push(route).then((_) {
            if (!mounted) return;
            if (homeState != null && homeState.isOnBerandaTab) {
              bgSound.start();
              _heroCardKey.currentState?.resumeVideo();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  CupertinoIcons.book_fill,
                  size: 22,
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppStrings.homeLanjutBaca,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.whiteWithAlpha(0.9),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateHelper.relativeTime(lastRead.lastReadAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: CupertinoColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${lastRead.surahName} — $progressText',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: CupertinoColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateTo(BuildContext context, String route) async {
    // Pause video + stop background sound sebelum navigasi
    _heroCardKey.currentState?.pauseVideo();
    await context.read<BackgroundSoundProvider>().stop();

    if (!mounted) return;
    final bgSound = context.read<BackgroundSoundProvider>();
    final nav = Navigator.of(context);
    nav
        .push(
          CupertinoPageRoute(
            builder: (context) {
              switch (route) {
                case '/quran':
                  return const QuranIndexScreen();
                case '/doa':
                  return const DoaHomeScreen();
                case '/hadits':
                  return const HaditsHomeScreen();
                case '/fiqih':
                  return const FiqihHomeScreen();
                case '/zakat':
                  return const ZakatScreen();
                case '/tasbih':
                  return const TasbihScreen();
                case '/kompas':
                  return const KompasScreen();
                case '/muslim-ai':
                  return const MuslimAiScreen();
                case '/tracker':
                  return const TrackerDashboardScreen();
                case '/tracker-harian':
                  return const TrackerScreen();
                case '/jurnal':
                  return const JurnalDashboardScreen();
                case '/haid':
                  return const HaidTrackerScreen();
                case '/arbain':
                  return const HaditsArbainScreen();
                case '/murattal':
                  return const MurattalScreen();
                default:
                  return const SizedBox();
              }
            },
          ),
        )
        .then((_) {
          if (!mounted) return;
          if (nav.canPop()) return;
          final homeState = context.findAncestorStateOfType<_HomeScreenState>();
          if (homeState != null && homeState.isOnBerandaTab) {
            bgSound.start();
            _heroCardKey.currentState?.resumeVideo();
          }
        });
  }
}
