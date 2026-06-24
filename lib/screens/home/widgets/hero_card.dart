import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../config/api_config.dart';
import '../../../models/models.dart';
import '../../../utils/date_helper.dart';

class HeroCard extends StatefulWidget {
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
  State<HeroCard> createState() => HeroCardState();
}

class HeroCardState extends State<HeroCard> {
  VideoPlayerController? _videoController;

  /// ── FLAG AUDIO ─────────────────────────────────────────────
  /// Video background HANYA sebagai dekorasi visual.
  /// WAJIB MUTE 100% — tidak boleh ada suara sama sekali.
  /// Alasan:
  /// 1. Background sound (audio/bg_*.mp3) adalah audio utama Beranda
  /// 2. Video player tetap request audio focus meskipun volume 0
  ///    → gunakan setVolume(0.0) + pastikan tidak ganggu AudioContext
  /// ────────────────────────────────────────────────────────────
  static const bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    debugPrint('🎬 HeroCard: initializing video...');
    _videoController = VideoPlayerController.asset('assets/video/background.mp4')
      ..setLooping(true)
      ..setVolume(_isMuted ? 0.0 : 1.0)
      ..initialize().then((_) {
        debugPrint('✅ HeroCard: video initialized, size=${_videoController?.value.size}');
        if (mounted) {
          setState(() {});
          _videoController?.play();
        }
      }).catchError((Object error) {
        debugPrint('❌ HeroCard: video failed: $error');
        if (mounted) {
          setState(() {
            _videoController?.dispose();
            _videoController = null;
          });
        }
      });
  }

  /// Pause video (saat keluar dari Beranda)
  void pauseVideo() {
    _videoController?.pause();
  }

  /// Resume video (saat kembali ke Beranda)
  void resumeVideo() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.play();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRamadhan = DateHelper.isRamadhanSeason(widget.currentTime);
    final badgeText = isRamadhan
        ? '✨ Ramadhan ${DateHelper.getHijriYear()} H'
        : '🌙 ${DateHelper.getMonthName(widget.currentTime.month)}';
    final tz = ApiConfig.getTimezone(widget.city);
    final isFriday = DateTime.now().weekday == DateTime.friday;
    final pt = widget.prayerTime;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Video background ──
            if (_videoController != null && _videoController!.value.isInitialized)
              Positioned.fill(
                child: ClipRect(
                  child: VideoPlayer(_videoController!),
                ),
              ),

            // ── Gradient overlay (semi-transparan biar video kelihatan) ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.75),
                      AppColors.primaryDark.withValues(alpha: 0.80),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.blackWithAlpha(0.20),
                  ),
                ),
              ),
            ),

            // ── Decorative circles ──
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.whiteWithAlpha(0.05),
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
                  color: AppColors.whiteWithAlpha(0.05),
                ),
              ),
            ),

            // ── Content ──
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.whiteWithAlpha(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: AppColors.cupertinoWhite,
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
                    _prayerRow(pt, 'imsak', AppStrings.prayerImsak, '🌅'),
                    _prayerRow(pt, 'subuh', AppStrings.prayerSubuh, '🌤️'),
                    _prayerRow(
                      pt,
                      'dzuhur',
                      isFriday ? 'Jumat' : AppStrings.prayerDzuhur,
                      '☀️',
                    ),
                    _prayerRow(pt, 'ashar', AppStrings.prayerAshar, '🌤️'),
                    _prayerRow(pt, 'maghrib', AppStrings.prayerMaghrib, '🌇'),
                    _prayerRow(pt, 'isya', AppStrings.prayerIsya, '🌙'),
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
                          color: AppColors.whiteWithAlpha(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.location_fill,
                              size: 12,
                              color: AppColors.cupertinoWhite,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.city} ($tz)',
                              style: const TextStyle(
                                color: AppColors.cupertinoWhite,
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
                          color: AppColors.whiteWithAlpha(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.bell_fill,
                              size: 12,
                              color: AppColors.cupertinoWhite,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.homeNotificationActive,
                              style: const TextStyle(
                                color: AppColors.cupertinoWhite,
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
                  color: AppColors.cupertinoWhite,
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
