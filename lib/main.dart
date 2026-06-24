import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'config/colors.dart';
import 'providers/theme_provider.dart';
import 'providers/prayer_times_provider.dart';
import 'providers/quran_provider.dart';
import 'providers/doa_provider.dart';
import 'providers/hadits_provider.dart';
import 'providers/fiqih_provider.dart';
import 'providers/tracker_provider.dart';
import 'providers/journal_provider.dart';
import 'providers/zakat_provider.dart';
import 'providers/haid_provider.dart';
import 'providers/tasbih_provider.dart';
import 'providers/muslim_ai_provider.dart';
import 'providers/user_provider.dart';
import 'providers/background_sound_provider.dart';
import 'providers/update_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'config/ai_config.dart';
import 'config/api_config.dart';
import 'services/local_storage.dart';
import 'services/notification_service.dart';
import 'services/prayer_alarm_service.dart';
import 'services/murattal_audio_handler.dart';
import 'utils/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AwesomeNotifications (for notifications from background isolate)
  await AwesomeNotifications().initialize('resource://mipmap/ic_launcher', [
    NotificationChannel(
      channelKey:        'umma_prayer_times_v2',
      channelName: 'Waktu Sholat',
      channelDescription: 'Notifikasi waktu sholat harian — suara menggunakan nada alarm sistem',
      defaultColor: AppColors.primary,
      ledColor: AppColors.primary,
      importance: NotificationImportance.Max,
      playSound: true,
      enableVibration: true,
    ),
  ]);

  // Register workmanager background task (safety net, every 4h)
  await NotificationService().initialize();

  // Initialize exact alarm scheduling via AndroidAlarmManager
  await PrayerAlarmService.initialize();

  // Start background prayer time check (safety net)
  await NotificationService().startBackgroundCheck();

  // Schedule exact alarms for today's prayer times
  await PrayerAlarmService.scheduleAll();

  // Initialize app version from native build
  await AppInfo.init();

  // Initialize local storage
  final storage = LocalStorage();
  await storage.init();

  // Load saved Groq API key
  final savedKey = storage.getString(ApiConfig.storageKeyGroqApiKey);
  if (savedKey != null && savedKey.isNotEmpty) {
    AiConfig.groqApiKey = savedKey;
  }

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize AudioService untuk background playback Murattal
  await AudioService.init(
    builder: () => MurattalAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'app.umma.aokaze.audio',
      androidNotificationChannelName: 'Murattal Quran',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true, // INI YANG GUE UBAH JADI TRUE, JING! BIAR GAK CRASH!
    ),
  );

  // Get saved theme
  final savedTheme = prefs.getString('umma_theme') ?? 'light';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..loadTheme(savedTheme),
        ),
        ChangeNotifierProvider(
          create: (_) {
            final p = PrayerTimesProvider();
            p.loadSavedCity();
            return p;
          },
        ),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => DoaProvider()),
        ChangeNotifierProvider(create: (_) => HaditsProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final p = FiqihProvider();
            p.loadContent();
            return p;
          },
        ),
        ChangeNotifierProvider(create: (_) => TrackerProvider()),
        ChangeNotifierProvider(create: (_) => JournalProvider()),
        ChangeNotifierProvider(create: (_) => ZakatProvider()),
        ChangeNotifierProvider(create: (_) => HaidProvider()),
        ChangeNotifierProvider(create: (_) => TasbihProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final p = MuslimAiProvider();
            p.loadCooldown();
            return p;
          },
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
          create: (_) => BackgroundSoundProvider()..loadSettings(),
        ),
        ChangeNotifierProvider(
          create: (_) => UpdateProvider(),
        ),
      ],
      child: const UmmaApp(),
    ),
  );
}