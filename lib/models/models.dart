class PrayerTime {
  final String imsak;
  final String subuh;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;
  final String date;
  final String isoDate;
  final String hijri;

  PrayerTime({
    this.imsak = '--:--',
    this.subuh = '--:--',
    this.dzuhur = '--:--',
    this.ashar = '--:--',
    this.maghrib = '--:--',
    this.isya = '--:--',
    this.date = '',
    this.isoDate = '',
    this.hijri = '',
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] ?? {};
    return PrayerTime(
      imsak: timings['Imsak'] ?? '--:--',
      subuh: timings['Subuh'] ?? '--:--',
      dzuhur: timings['Dzuhur'] ?? '--:--',
      ashar: timings['Ashar'] ?? '--:--',
      maghrib: timings['Maghrib'] ?? '--:--',
      isya: timings['Isya'] ?? '--:--',
      date: json['date'] ?? '',
      isoDate: json['isoDate'] ?? '',
      hijri: json['hijri'] ?? '',
    );
  }

  String getTime(String prayerName) {
    switch (prayerName) {
      case 'Imsak':
        return imsak;
      case 'Subuh':
        return subuh;
      case 'Dzuhur':
        return dzuhur;
      case 'Ashar':
        return ashar;
      case 'Maghrib':
        return maghrib;
      case 'Isya':
        return isya;
      default:
        return '--:--';
    }
  }

  /// All prayer times as list for iteration
  List<({String name, String time, int minutes})> get allPrayers {
    final result = <({String name, String time, int minutes})>[
      (name: 'Imsak', time: imsak, minutes: _parseTime(imsak)),
      (name: 'Subuh', time: subuh, minutes: _parseTime(subuh)),
      (name: 'Dzuhur', time: dzuhur, minutes: _parseTime(dzuhur)),
      (name: 'Ashar', time: ashar, minutes: _parseTime(ashar)),
      (name: 'Maghrib', time: maghrib, minutes: _parseTime(maghrib)),
      (name: 'Isya', time: isya, minutes: _parseTime(isya)),
    ];
    result.sort((a, b) => a.minutes.compareTo(b.minutes));
    return result;
  }

  /// Get next prayer based on current time (dengan display name untuk Jumat)
  /// [cityUtcOffset] = UTC offset jam kota terpilih (WIB=7, WITA=8, WIT=9)
  String? getNextPrayer(DateTime now, {int cityUtcOffset = 7}) {
    final prayers = allPrayers;
    // Konversi device local time ke timezone kota
    final cityTime = _toCityTime(now, cityUtcOffset);
    final currentMinutes = cityTime.hour * 60 + cityTime.minute;
    final isFriday = cityTime.weekday == DateTime.friday;
    for (final prayer in prayers) {
      if (prayer.minutes > currentMinutes && prayer.minutes != -1) {
        if (prayer.name == 'Dzuhur' && isFriday) return 'Jumat';
        return prayer.name;
      }
    }
    return 'Subuh'; // Next day
  }

  /// Countdown seconds to next prayer
  /// [cityUtcOffset] = UTC offset jam kota terpilih (WIB=7, WITA=8, WIT=9)
  int getCountdownTo(String prayerName, {int cityUtcOffset = 7}) {
    final now = DateTime.now();
    // Konversi device local time ke timezone kota agar sesuai dgn jadwal dari API
    final cityTime = _toCityTime(now, cityUtcOffset);
    final timeStr = getTime(prayerName);
    if (timeStr == '--:--') return 0;

    final parts = timeStr.split(':');
    if (parts.length != 2) return 0;

    final target = DateTime(
      cityTime.year,
      cityTime.month,
      cityTime.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    if (target.isBefore(cityTime)) {
      return target.add(const Duration(days: 1)).difference(cityTime).inSeconds;
    }
    return target.difference(cityTime).inSeconds;
  }

  /// Convert device local DateTime ke waktu kota terpilih berdasarkan UTC offset
  DateTime _toCityTime(DateTime deviceTime, int cityUtcOffset) {
    final deviceUtcOffset = deviceTime.timeZoneOffset.inHours;
    final diff = cityUtcOffset - deviceUtcOffset;
    return deviceTime.add(Duration(hours: diff));
  }

  int _parseTime(String time) {
    if (time == '--:--') return -1;
    final parts = time.split(':');
    if (parts.length != 2) return -1;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

class ScheduleResponse {
  final String location;
  final int year;
  final String info;
  final List<PrayerTime> schedule;

  ScheduleResponse({
    required this.location,
    required this.year,
    required this.info,
    required this.schedule,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      location: json['location'] ?? '',
      year: json['year'] ?? 0,
      info: json['info'] ?? '',
      schedule: (json['schedule'] as List? ?? [])
          .map((s) => PrayerTime.fromJson(s))
          .toList(),
    );
  }
}

class DailyTracker {
  final String date;
  bool isPuasa;
  bool subuh;
  bool dzuhur;
  bool ashar;
  bool maghrib;
  bool isya;
  bool tarawih;
  bool quran;
  bool sedekah;
  Map<String, bool> customProgress;

  DailyTracker({
    required this.date,
    this.isPuasa = false,
    this.subuh = false,
    this.dzuhur = false,
    this.ashar = false,
    this.maghrib = false,
    this.isya = false,
    this.tarawih = false,
    this.quran = false,
    this.sedekah = false,
    Map<String, bool>? customProgress,
  }) : customProgress = customProgress ?? {};

  int get completedCount {
    int count = 0;
    if (isPuasa) count++;
    if (subuh) count++;
    if (dzuhur) count++;
    if (ashar) count++;
    if (maghrib) count++;
    if (isya) count++;
    if (tarawih) count++;
    if (quran) count++;
    if (sedekah) count++;
    count += customProgress.values.where((v) => v).length;
    return count;
  }

  int get totalCount {
    // 8 default items + 1 tarawih (only during Ramadhan)
    final d = DateTime.tryParse(date);
    if (d != null) {
      // Gunakan DateHelper yang akurat (pakai hijri_date package)
      final isRamadhan = _isRamadhanDate(d);
      return (isRamadhan ? 9 : 8) + customProgress.length;
    }
    return 9 + customProgress.length;
  }

  bool _isRamadhanDate(DateTime d) {
    // Import-free: panggil DateHelper.isRamadhanSeason via provider
    // atau fallback manual sederhana
    try {
      // Coba dengan HijriDate logic manual
      // Ramadhan 1447-1450 coverage
      if (d.year == 2026 && d.month == 2 && d.day >= 19) return true;
      if (d.year == 2026 && d.month == 3 && d.day <= 21) return true;
      if (d.year == 2027 && d.month == 2 && d.day >= 8) return true;
      if (d.year == 2027 && d.month == 3 && d.day <= 10) return true;
      if (d.year == 2028 && d.month == 1 && d.day >= 28) return true;
      if (d.year == 2028 && d.month == 2 && d.day <= 27) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  int get percentage =>
      totalCount == 0 ? 0 : (completedCount * 100 ~/ totalCount);

  bool get isComplete => percentage == 100;

  Map<String, dynamic> toJson() => {
    'date': date,
    'isPuasa': isPuasa,
    'subuh': subuh,
    'dzuhur': dzuhur,
    'ashar': ashar,
    'maghrib': maghrib,
    'isya': isya,
    'tarawih': tarawih,
    'quran': quran,
    'sedekah': sedekah,
    'customProgress': customProgress,
  };

  factory DailyTracker.fromJson(Map<String, dynamic> json) {
    return DailyTracker(
      date: json['date'] ?? '',
      isPuasa: json['isPuasa'] ?? false,
      subuh: json['subuh'] ?? false,
      dzuhur: json['dzuhur'] ?? false,
      ashar: json['ashar'] ?? false,
      maghrib: json['maghrib'] ?? false,
      isya: json['isya'] ?? false,
      tarawih: json['tarawih'] ?? false,
      quran: json['quran'] ?? false,
      sedekah: json['sedekah'] ?? false,
      customProgress: Map<String, bool>.from(json['customProgress'] ?? {}),
    );
  }
}

class FiqihItem {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? reference;

  FiqihItem({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.reference,
  });
}

class ZakatResult {
  final String type;
  final double amount;
  final String description;
  final bool isEligible;

  ZakatResult({
    required this.type,
    required this.amount,
    required this.description,
    this.isEligible = true,
  });
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final String category;
  final String mood;
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.mood,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'category': category,
    'mood': mood,
    'createdAt': createdAt.toIso8601String(),
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'daily',
      mood: json['mood'] ?? 'calm',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class HaidLog {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final String type;

  HaidLog({
    required this.id,
    required this.startDate,
    this.endDate,
    this.type = 'start',
  });

  int get duration {
    if (endDate == null) return 0;
    return endDate!.difference(startDate).inDays + 1;
  }

  int get qadhaDays {
    return duration;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'type': type,
  };

  factory HaidLog.fromJson(Map<String, dynamic> json) {
    return HaidLog(
      id: json['id'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      type: json['type'] ?? 'start',
    );
  }
}

class UserProfile {
  String? username;
  String? avatarUrl;
  String? locationCity;
  List<CustomHabit> customHabits;

  UserProfile({
    this.username,
    this.avatarUrl,
    this.locationCity,
    List<CustomHabit>? customHabits,
  }) : customHabits = customHabits ?? [];

  Map<String, dynamic> toJson() => {
    'username': username,
    'avatarUrl': avatarUrl,
    'locationCity': locationCity,
    'customHabits': customHabits.map((h) => h.toJson()).toList(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      locationCity: json['locationCity'],
      customHabits: (json['customHabits'] as List? ?? [])
          .map((h) => CustomHabit.fromJson(h))
          .toList(),
    );
  }
}

class CustomHabit {
  final String id;
  final String label;

  CustomHabit({required this.id, required this.label});

  Map<String, dynamic> toJson() => {'id': id, 'label': label};

  factory CustomHabit.fromJson(Map<String, dynamic> json) {
    return CustomHabit(id: json['id'] ?? '', label: json['label'] ?? '');
  }
}

class Quote {
  final String text;
  final String author;
  final String? source;

  Quote({required this.text, required this.author, this.source});
}

class StudyMaterial {
  final int day;
  final String title;
  final String content;
  final String? source;

  StudyMaterial({
    required this.day,
    required this.title,
    required this.content,
    this.source,
  });
}

class ChatMessage {
  final String id;
  final String role; // 'user' or 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
