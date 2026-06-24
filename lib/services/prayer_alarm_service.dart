import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'background_service.dart';

/// Exact alarm scheduling for prayer time notifications.
///
/// Menggunakan Android AlarmManager (via android_alarm_manager_plus)
/// untuk menjadwalkan exact alarm di setiap waktu sholat.
///
/// Keunggulan dibanding Workmanager polling:
/// - Alarm fire PERSIS di waktu sholat (tidak delay hingga 4 jam)
/// - Bekerja lebih reliable di Doze mode (setExactAndAllowWhileIdle)
/// - Wake lock otomatis untuk membangunkan device
///
/// Notification logic tetap di background_service.dart
/// (backgroundCheckPrayerTimes) untuk menghindari duplikasi.
class PrayerAlarmService {
  PrayerAlarmService._();

  /// Initialize AndroidAlarmManager. Panggil di main() sebelum runApp().
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  /// Jadwalkan exact alarm untuk semua waktu sholat hari ini.
  /// Juga jadwalkan alarm reschedule untuk besok jam 00:05.
  static Future<void> scheduleAll() async {
    await _schedulePrayersForDate(DateTime.now());
  }

  static Future<void> _schedulePrayersForDate(DateTime date) async {
    try {
      final schedule = await loadPrayerSchedule();
      if (schedule == null || schedule.isEmpty) return;

      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final todaySchedule = schedule.firstWhere(
        (s) => s['tanggal_lengkap'] == dateStr,
        orElse: () => <String, dynamic>{},
      );
      if (todaySchedule.isEmpty) return;

      final now = DateTime.now();
      final isFriday = date.weekday == DateTime.friday;
      final prayers = [
        {'name': 'Imsak', 'time': todaySchedule['imsak'] as String? ?? ''},
        {'name': 'Subuh', 'time': todaySchedule['subuh'] as String? ?? ''},
        {
          'name': isFriday ? 'Jumat' : 'Dzuhur',
          'time': todaySchedule['dzuhur'] as String? ?? '',
        },
        {'name': 'Ashar', 'time': todaySchedule['ashar'] as String? ?? ''},
        {'name': 'Maghrib', 'time': todaySchedule['maghrib'] as String? ?? ''},
        {'name': 'Isya', 'time': todaySchedule['isya'] as String? ?? ''},
      ];

      for (final prayer in prayers) {
        final timeStr = prayer['time'] as String;
        if (timeStr.isEmpty || timeStr == '--:--') continue;

        final parts = timeStr.split(':');
        if (parts.length != 2) continue;

        final alarmTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );

        // Hanya jadwalkan yang masih akan datang
        if (alarmTime.isAfter(now)) {
          // Android 12+ butuh SCHEDULE_EXACT_ALARM permission.
          // Jika tidak di-grant, exact: false akan fallback ke inexact alarm
          // (masih lebih baik daripada Workmanager 4 jam).
          final canExact = await Permission.scheduleExactAlarm.isGranted;
          await AndroidAlarmManager.oneShotAt(
            alarmTime,
            _getIdForPrayer(prayer['name']!),
            _prayerAlarmCallback,
            exact: canExact,
            wakeup: true,
            rescheduleOnReboot: true,
          );
        }
      }

      // Jadwalkan reschedule untuk besok jam 00:05
      final tomorrow = DateTime(
        date.year,
        date.month,
        date.day + 1,
        0,
        5,
      );
      await AndroidAlarmManager.oneShotAt(
        tomorrow,
        _rescheduleAlarmId,
        _rescheduleCallback,
        exact: false,
        wakeup: false,
        rescheduleOnReboot: true,
      );
    } catch (_) {
      // Gagal scheduling — Workmanager safety net akan coba lagi
    }
  }

  /// Hapus semua alarm yang sudah dijadwalkan
  static Future<void> cancelAll() async {
    try {
      for (int id = _imsakAlarmId; id <= _rescheduleAlarmId; id++) {
        await AndroidAlarmManager.cancel(id);
      }
    } catch (_) {}
  }

  static int _getIdForPrayer(String name) {
    switch (name) {
      case 'Imsak':
        return _imsakAlarmId;
      case 'Subuh':
        return _subuhAlarmId;
      case 'Dzuhur':
      case 'Jumat':
        return _dzuhurAlarmId;
      case 'Ashar':
        return _asharAlarmId;
      case 'Maghrib':
        return _maghribAlarmId;
      case 'Isya':
        return _isyaAlarmId;
      default:
        return _subuhAlarmId;
    }
  }
}

// ─── ALARM IDs ─────────────────────────────────────────────
const _imsakAlarmId = 101;
const _subuhAlarmId = 102;
const _dzuhurAlarmId = 103;
const _asharAlarmId = 104;
const _maghribAlarmId = 105;
const _isyaAlarmId = 106;
const _rescheduleAlarmId = 999;

// ─── ALARM CALLBACKS ───────────────────────────────────────
// Top-level @pragma('vm:entry-point') agar bisa dipanggil dari background isolate.
// Notification logic di-background_service.dart (backgroundCheckPrayerTimes).

@pragma('vm:entry-point')
void _prayerAlarmCallback() {
  backgroundCheckPrayerTimes();
}

@pragma('vm:entry-point')
void _rescheduleCallback() {
  PrayerAlarmService.scheduleAll();
}
