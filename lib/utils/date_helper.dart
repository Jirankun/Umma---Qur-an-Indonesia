import 'package:hijri_date/hijri_date.dart';

/// Helper untuk deteksi tanggal Hijriyah dan musim Ramadhan.
/// Menggunakan package hijri_date (Umm al-Qura standard).
/// Akurat untuk tahun berapapun — tidak perlu hardcode.
class DateHelper {
  /// Deteksi apakah saat ini sedang musim Ramadhan.
  static bool isRamadhanSeason(DateTime date) {
    final hijri = _toHijri(date);
    if (hijri == null) return _approximateFallback(date);
    return hijri.hMonth == 9;
  }

  /// Deteksi apakah saat ini akhir Ramadhan (10 hari terakhir, hDay >= 20).
  /// Digunakan untuk menyembunyikan/menampilkan opsi Zakat.
  static bool isEndOfRamadhan(DateTime date) {
    final hijri = _toHijri(date);
    if (hijri == null) return _approximateEndFallback(date);
    return hijri.hMonth == 9 && hijri.hDay >= 20;
  }

  /// Alias: cek apakah bulan Hijri saat ini Ramadhan
  static bool isCurrentlyRamadhan(DateTime date) => isRamadhanSeason(date);

  /// Dapatkan objek HijriDate untuk tanggal tertentu
  static HijriDate? _toHijri(DateTime date) {
    try {
      return HijriDate.fromDate(date);
    } catch (_) {
      return null;
    }
  }

  /// Dapatkan objek HijriDate (public)
  static HijriDate? getHijriDate(DateTime date) => _toHijri(date);

  /// Dapatkan tahun Hijriyah saat ini
  static int getHijriYear() {
    try {
      return HijriDate.now().hYear;
    } catch (_) {
      final now = DateTime.now();
      final baseGreg = DateTime(2024, 7, 7);
      const baseHijri = 1446;
      final diffDays = now.difference(baseGreg).inDays;
      return baseHijri + (diffDays ~/ 354);
    }
  }

  /// Dapatkan nama bulan Hijriyah dalam Bahasa Indonesia
  static String getHijriMonthName(DateTime date) {
    const months = [
      'Muharram',
      'Safar',
      'Rabiul Awal',
      'Rabiul Akhir',
      'Jumadil Awal',
      'Jumadil Akhir',
      'Rajab',
      'Sya\'ban',
      'Ramadhan',
      'Syawal',
      'Dzulqa\'dah',
      'Dzulhijjah',
    ];
    final hijri = _toHijri(date);
    if (hijri == null) return '';
    final idx = hijri.hMonth - 1;
    if (idx < 0 || idx >= months.length) return '';
    return months[idx];
  }

  /// Dapatkan tanggal Hijriyah lengkap (format: "17 Ramadhan 1447 H")
  static String getFullHijriDate(DateTime date) {
    final hijri = _toHijri(date);
    if (hijri == null) return '';
    return '${hijri.hDay} ${getHijriMonthName(date)} ${hijri.hYear} H';
  }

  /// Dapatkan nama bulan Masehi dalam Bahasa Indonesia
  static String getMonthName(int month) {
    const months = [
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
    return months[month];
  }

  /// Format waktu relatif Bahasa Indonesia
  static String relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${diff.inDays ~/ 7} minggu lalu';
  }

  /// Fallback: kalkulasi perkiraan jika package gagal
  static bool _approximateFallback(DateTime date) {
    if (date.year == 2026) {
      return (date.month == 2 && date.day >= 19) ||
          (date.month == 3 && date.day <= 21);
    }
    if (date.year == 2027) {
      return (date.month == 2 && date.day >= 8) ||
          (date.month == 3 && date.day <= 10);
    }
    if (date.year == 2028) {
      return (date.month == 1 && date.day >= 28) ||
          (date.month == 2 && date.day <= 27);
    }
    return false;
  }

  /// Fallback akhir Ramadhan: 5 hari terakhir dari perkiraan Ramadhan
  static bool _approximateEndFallback(DateTime date) {
    if (date.year == 2026) {
      return (date.month == 3 && date.day >= 17);
    }
    if (date.year == 2027) {
      return (date.month == 3 && date.day >= 6);
    }
    if (date.year == 2028) {
      return (date.month == 2 && date.day >= 23);
    }
    return false;
  }
}
