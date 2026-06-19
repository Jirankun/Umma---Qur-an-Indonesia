import 'package:flutter/cupertino.dart';
import '../../../config/colors.dart';
import '../../../config/api_config.dart';
import '../../../models/models.dart';
import '../../../utils/date_helper.dart';

class HeroCard extends StatelessWidget {
  final PrayerTime? prayerTime;
  final DateTime currentTime;
  final bool isDark;
  final String city;

  const HeroCard({
    super.key,
    this.prayerTime,
    required this.currentTime,
    required this.isDark,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    final isRamadhan = DateHelper.isRamadhanSeason(currentTime);
    final badgeText = isRamadhan
        ? '✨ Ramadhan ${DateHelper.getHijriYear()} H'
        : '🌙 ${DateHelper.getMonthName(currentTime.month)}';
    final tz = ApiConfig.getTimezone(city);
    final isFriday = DateTime.now().weekday == DateTime.friday;
    final pt = prayerTime;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CupertinoColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge + city
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ALL prayer times
                  if (pt != null) ...[
                    _prayerRow(pt, 'imsak', 'Imsak', '🌅'),
                    _prayerRow(pt, 'subuh', 'Subuh', '🌤️'),
                    _prayerRow(
                      pt,
                      'dzuhur',
                      isFriday ? 'Jumat' : 'Dzuhur',
                      '☀️',
                    ),
                    _prayerRow(pt, 'ashar', 'Ashar', '🌤️'),
                    _prayerRow(pt, 'maghrib', 'Maghrib', '🌇'),
                    _prayerRow(pt, 'isya', 'Isya', '🌙'),
                  ],

                  const SizedBox(height: 12),
                  // Footer: city + timezone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.location_fill,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$city ($tz)',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.bell_fill,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Notif Aktif',
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prayerRow(PrayerTime pt, String key, String label, String emoji) {
    String time;
    switch (key) {
      case 'imsak':
        time = pt.imsak;
        break;
      case 'subuh':
        time = pt.subuh;
        break;
      case 'dzuhur':
        time = pt.dzuhur;
        break;
      case 'ashar':
        time = pt.ashar;
        break;
      case 'maghrib':
        time = pt.maghrib;
        break;
      case 'isya':
        time = pt.isya;
        break;
      default:
        time = '--:--';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFamily: '.SF Mono',
            ),
          ),
        ],
      ),
    );
  }
}
