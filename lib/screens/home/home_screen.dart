import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
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

  /// Apakah user sedang di tab Beranda (tab 0).
  /// Digunakan oleh _HomeContentState untuk cek sebelum restart sound.
  bool get isOnBerandaTab => _selectedTab == 0;

  final List<Widget> _screens = [
    const _HomeContent(),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start background sound on Beranda (tab 0) if enabled
      context.read<BackgroundSoundProvider>().start();
      // Cek update dari GitHub
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
      provider.checkForUpdate().then((_) {
        if (!mounted) return;
        if (provider.status == UpdateStatus.updateAvailable) {
          showUpdatePopup(context, provider);
        }
      }).catchError((_) {}); // silent catch for network errors
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App di-minimize → stop semua audio
      context.read<BackgroundSoundProvider>().stop();
      context.read<QuranProvider>().stopAudio();
    } else if (state == AppLifecycleState.resumed) {
      // App kembali aktif → restart bg sound jika di Beranda
      if (_selectedTab == 0) {
        context.read<BackgroundSoundProvider>().start();
      }
      // Retry install APK setelah kembali dari settings
      final updateProvider = context.read<UpdateProvider>();
      if (updateProvider.status == UpdateStatus.installPermissionNeeded) {
        updateProvider.retryInstall().then((_) {
          if (!mounted) return;
          if (updateProvider.status == UpdateStatus.installPermissionNeeded) {
            // Gagal lagi — tampilkan permission popup lagi
            showInstallPermissionPopup(context, updateProvider);
          }
        }).catchError((_) {});
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _selectedTab = index);
    final bgSound = context.read<BackgroundSoundProvider>();
    if (index == 0) {
      bgSound.start();
    } else {
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
      (icon: CupertinoIcons.house_fill, label: 'Beranda'),
      (icon: CupertinoIcons.book_fill, label: "Al-Qur'an"),
      (icon: CupertinoIcons.heart_fill, label: 'Doa'),
      (icon: CupertinoIcons.person_fill, label: 'Akun'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
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
        ? CupertinoColors.systemGrey
        : CupertinoColors.systemGrey2;
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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  DateTime _currentTime = DateTime.now();

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
        // ─── FAB: Hadits An-Nawawiyyah ───
        Positioned(
          right: 20,
          bottom: 20,
          child: GestureDetector(
            onTap: () => _navigateTo(context, '/arbain'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.heat4,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.heat4.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.book_fill,
                    size: 18,
                    color: CupertinoColors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hadits An-Nawawiyyah',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        ? 'Selamat Pagi'
        : _currentTime.hour < 15
        ? 'Selamat Siang'
        : _currentTime.hour < 18
        ? 'Selamat Sore'
        : 'Selamat Malam';

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
                      'Gagal memuat jadwal sholat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      'Periksa koneksi internet',
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
                child: const Text('Muat Ulang', style: TextStyle(fontSize: 12)),
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
                    nextPrayer != null ? 'Menuju $nextPrayer' : 'Jadwal Sholat',
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
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
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
        ? 'Ayat ${lastRead.ayahNumber} dari $totalAyat'
        : 'Ayat ${lastRead.ayahNumber}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: GestureDetector(
        onTap: () async {
          await context.read<BackgroundSoundProvider>().stop();
          if (!mounted) return;
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
          Navigator.of(context).push(route).then((_) {
            if (!mounted) return;
            final parent = context
                .findAncestorStateOfType<_HomeScreenState>();
            if (parent != null && parent.isOnBerandaTab) {
              context.read<BackgroundSoundProvider>().start();
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
                            'LANJUT BACA',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: CupertinoColors.white.withValues(
                                alpha: 0.9,
                              ),
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

  void _navigateTo(BuildContext context, String route) {
    // Stop background sound saat navigasi keluar dari Beranda
    context.read<BackgroundSoundProvider>().stop();

    Navigator.of(context)
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
                default:
                  return const SizedBox();
              }
            },
          ),
        )
        .then((_) {
          // Resume background sound hanya jika:
          // - masih di tab Beranda
          // - HomeScreen adalah satu-satunya route (tidak ada screen di atasnya)
          if (mounted) {
            final parent = context.findAncestorStateOfType<_HomeScreenState>();
            if (parent != null && parent.isOnBerandaTab) {
              final nav = Navigator.of(context);
              if (!nav.canPop()) {
                context.read<BackgroundSoundProvider>().start();
              }
            }
          }
        });
  }
}
