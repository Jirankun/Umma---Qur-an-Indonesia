import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'config/colors.dart';
import 'config/strings.dart';
import 'providers/theme_provider.dart';
import 'services/local_storage.dart';
import 'utils/app_info.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/quran/quran_index_screen.dart';
import 'screens/doa/doa_home_screen.dart';
import 'screens/hadits/hadits_home_screen.dart';
import 'screens/fiqih/fiqih_home_screen.dart';
import 'screens/zakat/zakat_screen.dart';
import 'screens/tasbih/tasbih_screen.dart';
import 'screens/kompas/kompas_screen.dart';
import 'screens/muslim_ai/muslim_ai_screen.dart';
import 'screens/tracker/tracker_screen.dart';
import 'screens/tracker/tracker_dashboard_screen.dart';
import 'screens/jurnal/jurnal_dashboard_screen.dart';
import 'screens/haid/haid_tracker_screen.dart';
import 'screens/user/user_profile_screen.dart';
import 'screens/study/study_screen.dart';
import 'screens/sync/p2p_sync_screen.dart';

class UmmaApp extends StatefulWidget {
  const UmmaApp({super.key});

  @override
  State<UmmaApp> createState() => _UmmaAppState();
}

class _UmmaAppState extends State<UmmaApp> {
  bool? _isFirstLaunch;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final done = LocalStorage().getBool('umma_onboarding_done_${AppInfo.version}') ?? false;
    if (mounted) {
      setState(() => _isFirstLaunch = !done);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return CupertinoApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: themeProvider.brightness,
            primaryColor: AppColors.primary,
            primaryContrastingColor: CupertinoColors.white,
            scaffoldBackgroundColor:
                AppColors.background(themeProvider.isDark),
            barBackgroundColor: AppColors.navbar(themeProvider.isDark),
            textTheme: CupertinoTextThemeData(
              primaryColor: AppColors.text(themeProvider.isDark),
              textStyle: const TextStyle(
                fontFamily: '.SF Pro Display',
                fontSize: 16,
              ),
            ),
          ),
          home: _isFirstLaunch == null
              ? const Center(child: CupertinoActivityIndicator(radius: 14))
              : (_isFirstLaunch!
                    ? const OnboardingScreen()
                    : const HomeScreen()),
          routes: {
            '/quran': (context) => const QuranIndexScreen(),
            '/doa': (context) => const DoaHomeScreen(),
            '/hadits': (context) => const HaditsHomeScreen(),
            '/fiqih': (context) => const FiqihHomeScreen(),
            '/zakat': (context) => const ZakatScreen(),
            '/tasbih': (context) => const TasbihScreen(),
            '/kompas': (context) => const KompasScreen(),
            '/muslim-ai': (context) => const MuslimAiScreen(),
            '/tracker': (context) => const TrackerDashboardScreen(),
            '/tracker-harian': (context) => const TrackerScreen(),
            '/jurnal': (context) => const JurnalDashboardScreen(),
            '/haid': (context) => const HaidTrackerScreen(),
            '/user': (context) => const UserProfileScreen(),
            '/study': (context) => const StudyScreen(),
            '/sync-p2p': (context) => const P2pSyncScreen(),
          },
        );
      },
    );
  }
}
