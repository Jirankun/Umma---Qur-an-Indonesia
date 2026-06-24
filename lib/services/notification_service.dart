import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import '../config/api_config.dart';
import '../services/background_service.dart';
import 'prayer_alarm_service.dart';

/// Service for system-level prayer time notifications.
/// Uses Workmanager for periodic background checks (every 30 min)
/// and AwesomeNotifications for showing notifications (works in background isolates).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String backgroundTaskName = 'prayerTimeCheck';
  static const String backgroundTaskPeriod = 'periodicPrayerCheck';

  Future<void> initialize() async {
    // Register workmanager background task
    await Workmanager().initialize(callbackDispatcher);
  }

  /// Start periodic background prayer time check (every 4 hours, safety net)
  /// Exact alarms via AndroidAlarmManager handle the primary notification delivery.
  Future<void> startBackgroundCheck() async {
    await Workmanager().registerPeriodicTask(
      backgroundTaskPeriod,
      backgroundTaskName,
      frequency: const Duration(hours: 4),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 10),
    );
  }

  /// Stop background check
  Future<void> stopBackgroundCheck() async {
    await Workmanager().cancelByUniqueName(backgroundTaskPeriod);
  }

  /// Schedule prayer notifications — uses exact alarms + Workmanager safety net
  Future<void> schedulePrayerNotifications() async {
    // Cancel old notifications
    await cancelAllNotifications();

    // Ensure background task is running (safety net)
    await startBackgroundCheck();

    // Schedule exact alarms via AndroidAlarmManager
    await PrayerAlarmService.scheduleAll();
  }

  /// Show notification immediately (for testing or manual trigger)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: ApiConfig.notifChannelId,
        title: title,
        body: body,
        payload: {'action': payload ?? ''},
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  Future<bool> requestPermissions() async {
    return AwesomeNotifications().requestPermissionToSendNotifications();
  }
}

/// Workmanager callback — dipanggil di isolate terpisah oleh sistem
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == NotificationService.backgroundTaskName) {
      try {
        await backgroundCheckPrayerTimes();
      } catch (_) {
        return false;
      }
    }
    return true;
  });
}
