import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';

/// Background service untuk check jadwal sholat dan kirim notifikasi.
/// Dipanggil oleh Workmanager setiap 30 menit.
///
/// Bekerja di isolate terpisah — tidak punya akses ke Provider atau Context.
/// Semua data dibaca langsung dari file system (appDocDir).
@pragma('vm:entry-point')
Future<void> backgroundCheckPrayerTimes() async {
  final now = DateTime.now();
  final todayStr =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  try {
    // 1. Cek apakah ada jadwal sholat tersimpan
    final schedule = await _loadSchedule();
    if (schedule == null || schedule.isEmpty) {
      // Coba download jadwal bulan ini
      await _downloadAndSaveSchedule(now.year, now.month);
      return;
    }

    // 2. Cari jadwal untuk hari ini
    final todaySchedule = schedule.firstWhere(
      (s) => s['tanggal_lengkap'] == todayStr,
      orElse: () => <String, dynamic>{},
    );
    if (todaySchedule.isEmpty) return;

    // 3. Cek apakah ada waktu sholat yang sudah lewat tapi belum dinotifikasi
    final notified = await _getNotifiedTimes();
    final isFriday = now.weekday == DateTime.friday;
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

      final prayerHour = int.tryParse(parts[0]) ?? 0;
      final prayerMinute = int.tryParse(parts[1]) ?? 0;
      final prayerDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        prayerHour,
        prayerMinute,
      );

      // Waktu sholat sudah lewat (dalam 5 menit terakhir) dan belum dinotifikasi
      final diff = now.difference(prayerDateTime).inMinutes;
      if (diff >= 0 && diff <= 5 && !notified.contains(prayer['name'])) {
        await _showNotification(prayer['name']!);
        await _markNotified(prayer['name']!);
      }
    }

    // 4. Cek apakah besok ada jadwal? Jika tidak, download bulan depan
    final tomorrowStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}';
    final tomorrowExists = schedule.any(
      (s) => s['tanggal_lengkap'] == tomorrowStr,
    );
    if (!tomorrowExists) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;
      await _downloadAndSaveSchedule(nextYear, nextMonth);
    }
  } catch (_) {
    // Background task gagal — akan dicoba lagi 30 menit kemudian
  }
}

/// Load jadwal sholat dari file lokal
Future<List<Map<String, dynamic>>?> _loadSchedule() async {
  try {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/prayer_schedule.json');
    if (!await file.exists()) return null;
    final raw = await file.readAsString();
    final data = jsonDecode(raw) as List;
    return data.cast<Map<String, dynamic>>();
  } catch (_) {
    return null;
  }
}

/// Load selected city from local file (ditulis oleh PrayerTimesProvider)
Future<String> _loadSelectedCity() async {
  try {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/selected_city.json');
    if (await file.exists()) {
      final data = jsonDecode(await file.readAsString());
      final city = data['city'] as String?;
      if (city != null && ApiConfig.cityToShalatMapping.containsKey(city)) {
        return city;
      }
    }
  } catch (_) {}
  return 'Jakarta';
}

/// Download jadwal sholat dari API dan simpan ke lokal
Future<void> _downloadAndSaveSchedule(int year, int month) async {
  final city = await _loadSelectedCity();
  final mapping = ApiConfig.cityToShalatMapping[city];
  if (mapping == null) return;

  try {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.equranShalatBaseUrl}${ApiConfig.equranShalatEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provinsi': mapping['provinsi'],
        'kabkota': mapping['kabkota'],
        'bulan': month,
        'tahun': year,
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final jadwal = decoded['data']?['jadwal'] as List? ?? [];
      if (jadwal.isNotEmpty) {
        await _saveSchedule(jadwal.cast<Map<String, dynamic>>());
      }
    }
  } catch (_) {
    // Gagal download — next background cycle akan coba lagi
  }
}

/// Save jadwal to local file
Future<void> _saveSchedule(List<Map<String, dynamic>> schedule) async {
  final dir = await _getStorageDir();
  final file = File('${dir.path}/prayer_schedule.json');

  // Merge with existing schedule (avoid duplicates by tanggal_lengkap)
  final existing = await _loadSchedule() ?? [];
  final existingDates = existing.map((s) => s['tanggal_lengkap']).toSet();

  for (final item in schedule) {
    if (!existingDates.contains(item['tanggal_lengkap'])) {
      existing.add(item);
    }
  }

  await file.writeAsString(jsonEncode(existing));
}

/// Get storage directory for schedule
Future<Directory> _getStorageDir() async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final dir = Directory('${appDocDir.path}/umma_data');
  if (!await dir.exists()) await dir.create(recursive: true);
  return dir;
}

/// Show notification using AwesomeNotifications (works in background isolates)
Future<void> _showNotification(String prayerName) async {
  final emojis = {
    'Imsak': '🌅',
    'Subuh': '🌤️',
    'Dzuhur': '☀️',
    'Jumat': '☀️',
    'Ashar': '🌤️',
    'Maghrib': '🌇',
    'Isya': '🌙',
  };

  final messages = {
    'Imsak': 'Waktu Imsak telah tiba. Segera persiapkan sahur! 🌅',
    'Subuh': 'Waktu Sholat Subuh telah tiba. 🤲',
    'Dzuhur': 'Waktu Sholat Dzuhur telah tiba. 🤲',
    'Jumat': 'Waktu Sholat Jumat telah tiba. 🤲',
    'Ashar': 'Waktu Sholat Ashar telah tiba. 🤲',
    'Maghrib': 'Waktu Sholat Maghrib telah tiba. 🤲',
    'Isya': 'Waktu Sholat Isya telah tiba. 🤲',
  };

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: prayerName.hashCode,
      channelKey: 'umma_prayer_times',
      title: '🕌 ${emojis[prayerName] ?? ''} $prayerName — Umma',
      body: messages[prayerName] ?? 'Waktu sholat telah tiba.',
      payload: {'action': 'prayer_$prayerName'},
      notificationLayout: NotificationLayout.BigText,
      displayOnForeground: true,
    ),
    actionButtons: [
      NotificationActionButton(key: 'open', label: 'Buka Aplikasi'),
    ],
  );
}

/// Get set of already-notified prayer times today
Future<Set<String>> _getNotifiedTimes() async {
  try {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/prayer_notified.json');
    if (!await file.exists()) return {};
    final raw = await file.readAsString();
    final data = jsonDecode(raw) as Map;
    final today = DateTime.now();
    final key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return Set<String>.from(data[key] ?? []);
  } catch (_) {
    return {};
  }
}

/// Mark a prayer time as notified today
Future<void> _markNotified(String prayerName) async {
  try {
    final dir = await _getStorageDir();
    final file = File('${dir.path}/prayer_notified.json');
    final today = DateTime.now();
    final key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    Map<String, dynamic> data = {};
    if (await file.exists()) {
      data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    }

    final list = List<String>.from(data[key] ?? []);
    list.add(prayerName);
    data[key] = list;
    await file.writeAsString(jsonEncode(data));
  } catch (_) {}
}
