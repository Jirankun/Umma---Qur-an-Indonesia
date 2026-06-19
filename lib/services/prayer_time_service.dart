import '../models/models.dart';
import '../utils/date_helper.dart';

/// Service untuk kalkulasi arah kiblat dan prayer times
class PrayerTimeService {
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  /// Get the Hero Mode based on current time and prayer times
  String getHeroMode(PrayerTime? prayerTimes, DateTime currentTime) {
    if (prayerTimes == null) return 'default';

    final currentMinutes = currentTime.hour * 60 + currentTime.minute;
    final subuhMinutes = _parseTime(prayerTimes.subuh);
    final dzuhurMinutes = _parseTime(prayerTimes.dzuhur);
    final asharMinutes = _parseTime(prayerTimes.ashar);
    final maghribMinutes = _parseTime(prayerTimes.maghrib);
    final isyaMinutes = _parseTime(prayerTimes.isya);

    if (currentMinutes < subuhMinutes) return 'malam';
    if (currentMinutes < dzuhurMinutes) return 'pagi';
    if (currentMinutes < asharMinutes) return 'siang';
    if (currentMinutes < maghribMinutes) return 'sore';
    if (currentMinutes < isyaMinutes) return 'petang';
    return 'malam';
  }

  int _parseTime(String time) {
    if (time == '--:--') return -1;
    final parts = time.split(':');
    if (parts.length != 2) return -1;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Get Hijri date — akurat menggunakan package hijri_date
  Map<String, dynamic> getHijriDate(DateTime date) {
    final hijri = DateHelper.getHijriDate(date);
    if (hijri == null) {
      return {'day': 0, 'month': '', 'year': 0, 'full': ''};
    }
    return {
      'day': hijri.hDay,
      'month': DateHelper.getHijriMonthName(date),
      'year': hijri.hYear,
      'full': DateHelper.getFullHijriDate(date),
    };
  }
}
