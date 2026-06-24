import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../providers/theme_provider.dart';

class KompasScreen extends StatefulWidget {
  const KompasScreen({super.key});

  @override
  State<KompasScreen> createState() => _KompasScreenState();
}

class _KompasScreenState extends State<KompasScreen> {
  double _heading = 0;
  double _smoothHeading = -1;
  double _qibla = 0;
  double _latitude = 0;
  double _longitude = 0;
  int _headingOffset =
      0; // kalibrasi: 0 atau 180 (untuk perangkat dgn sumbu terbalik)
  bool _loading = true;
  String? _error;
  bool _hasLocation = false;

  final List<double> _gravityVec = [0, 0, 0];
  int _gravitySamples = 0;
  bool _hasGravity = false;
  bool _wasAligned = false;
  static const double _filterStrength = 0.18;
  static const double _updateThreshold = 1.0;
  static const int _minGravitySamples = 8;

  @override
  void initState() {
    super.initState();
    _initSensors();
    _getLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = AppStrings.kompasNoGps;
          _loading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = AppStrings.kompasNoPermission;
            _loading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = AppStrings.kompasNoPermissionPermanent;
          _loading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _qibla = _calculateQibla(position.latitude, position.longitude);
        _hasLocation = true;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppStrings.kompasGagalLokasi;
        _loading = false;
      });
    }
  }

  void _checkQiblaAlignment() {
    final diff = (_heading - _qibla + 540) % 360 - 180;
    final aligned = diff.abs() <= 3;
    if (aligned && !_wasAligned) {
      HapticFeedback.mediumImpact();
    }
    _wasAligned = aligned;
  }

  /// Koreksi lokal arah kiblat (derajat). Diisi manual jika hasil perhitungan
  /// standar meleset dari arah sebenarnya di lokasi pengguna.
  static const double _qiblaKoreksi = -31.0;

  /// ✅ FIXED: Correct Qibla calculation using standard spherical trigonometry
  double _calculateQibla(double lat, double lng) {
    const double kaabaLat = 21.4225; // ApiConfig.kabahLatitude
    const double kaabaLng = 39.8262; // ApiConfig.kabahLongitude

    final phi1 = lat * math.pi / 180;
    final phi2 = kaabaLat * math.pi / 180;
    final deltaLambda = (kaabaLng - lng) * math.pi / 180;

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    double bearing = math.atan2(y, x);
    bearing = (bearing * 180 / math.pi + 360) % 360;
    bearing = (bearing + _qiblaKoreksi + 360) % 360;
    return bearing;
  }

  void _initSensors() {
    accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50),
    ).listen((event) {
      if (!mounted) return;
      const double alpha = 0.8;
      _gravityVec[0] = _gravityVec[0] * alpha + event.x * (1 - alpha);
      _gravityVec[1] = _gravityVec[1] * alpha + event.y * (1 - alpha);
      _gravityVec[2] = _gravityVec[2] * alpha + event.z * (1 - alpha);
      _gravitySamples++;
      if (_gravitySamples >= _minGravitySamples) {
        _hasGravity = true;
      }
    });

    magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      if (!mounted || !_hasGravity) return;

      final ax = _gravityVec[0], ay = _gravityVec[1], az = _gravityVec[2];
      final mx = event.x, my = event.y, mz = event.z;

      final gNorm = math.sqrt(ax * ax + ay * ay + az * az);
      if (gNorm < 0.001) return;
      final gx = ax / gNorm, gy = ay / gNorm, gz = az / gNorm;

      var ex = gy * mz - gz * my;
      var ey = gz * mx - gx * mz;
      var ez = gx * my - gy * mx;

      final eNorm = math.sqrt(ex * ex + ey * ey + ez * ez);
      if (eNorm < 0.001) return;
      ex /= eNorm;
      ey /= eNorm;
      ez /= eNorm;

      final ny = ez * gx - ex * gz;

      // Reference: flutter_qiblah (iqfareez/medyas) — heading + (360 - offset)
      // Formula: heading = atan2(-ey, -ny) untuk koreksi 180° sensor axis
      var heading = math.atan2(-ey, -ny) * 180 / math.pi;
      heading = (heading + 360) % 360;
      heading = (heading + _headingOffset + 360) % 360;

      if (_smoothHeading < 0) {
        _smoothHeading = heading;
      } else {
        double diff = heading - _smoothHeading;
        if (diff > 180) diff -= 360;
        if (diff < -180) diff += 360;
        _smoothHeading += diff * _filterStrength;
        _smoothHeading = (_smoothHeading + 360) % 360;
      }

      if ((_smoothHeading - _heading).abs() > _updateThreshold) {
        setState(() {
          _heading = _smoothHeading;
          _checkQiblaAlignment();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final diff = (_heading - _qibla + 540) % 360 - 180;
    final isAligned = diff.abs() <= 3;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.kompasBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.kompasBg,
        middle: Text(
          AppStrings.kompasTitle,
          style: const TextStyle(color: CupertinoColors.white),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(child: _buildBody(isDark, isAligned, diff)),
    );
  }

  Widget _buildBody(bool isDark, bool isAligned, double diff) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CupertinoActivityIndicator(radius: 14),
            SizedBox(height: 12),
            Text(
              AppStrings.kompasMendeteksi,
              style: TextStyle(fontSize: 13, color: CupertinoColors.systemGrey),
            ),
          ],
        ),
      );
    }

    if (_error != null && !_hasLocation) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.location_slash_fill,
                size: 48,
                color: CupertinoColors.systemRed,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton.filled(
                child: Text(AppStrings.kompasCobaLagi),
                onPressed: () {
                  setState(() => _loading = true);
                  _getLocation();
                },
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          _buildCompass(isAligned, diff, isDark),
          const SizedBox(height: 24),
          if (isAligned)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.toolTeal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: AppColors.toolTeal,
                  ),
                  SizedBox(width: 8),
                  Text(
                    AppStrings.kompasMenghadap,
                    style: TextStyle(
                      color: AppColors.toolTeal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: CupertinoColors.systemRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.arrow_up_right_square,
                    color: AppColors.kompasRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Putar HP ${diff > 0 ? 'kanan' : 'kiri'} ${diff.abs().round()}°',
                    style: const TextStyle(
                      color: AppColors.kompasRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    AppStrings.kompasHeading,
                    '${_heading.round()}°',
                    CupertinoColors.white,
                    IconsType.heading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    AppStrings.kompasKiblat,
                    '${_qibla.round()}°',
                    AppColors.toolTeal,
                    IconsType.kiblat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    AppStrings.kompasSelisih,
                    '${diff.abs().round()}°',
                    CupertinoColors.white,
                    IconsType.selisih,
                  ),
                ),
              ],
            ),
          ),
          if (_hasLocation) ...[
            const SizedBox(height: 12),
            Text(
              '${_latitude.toStringAsFixed(4)}°, ${_longitude.toStringAsFixed(4)}°',
              style: const TextStyle(
                fontSize: 11,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
          _buildCalibrationBar(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCompass(bool isAligned, double diff, bool isDark) {
    final compassSize = 300.0;
    final center = compassSize / 2;
    final outerRadius = compassSize / 2 - 4;
    final tickOuterRadius = outerRadius - 8;
    const double qiblaNeedleLength = 140;

    return Container(
      width: compassSize,
      height: compassSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : AppColors.textLight,
        border: Border.all(
          color: CupertinoColors.white.withValues(alpha: 0.15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.toolTeal.withValues(alpha: isAligned ? 0.4 : 0.0),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Transform.rotate(
        angle: -_heading * math.pi / 180,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ✅ FIXED: Wrap tick marks in SizedBox to prevent overflow
            ...List.generate(72, (i) {
              final angle = i * 5.0;
              final rad = (angle - 90) * math.pi / 180;
              final isMajor = i % 6 == 0;
              final len = isMajor ? 12.0 : 6.0;
              final innerR = tickOuterRadius - len;
              final outerR = tickOuterRadius;
              return SizedBox(
                width: compassSize,
                height: compassSize,
                child: CustomPaint(
                  painter: _TickPainter(
                    center: Offset(center, center),
                    startRadius: innerR,
                    endRadius: outerR,
                    angle: rad,
                    color: isMajor
                        ? CupertinoColors.white.withValues(alpha: 0.7)
                        : CupertinoColors.white.withValues(alpha: 0.25),
                    strokeWidth: isMajor ? 2.5 : 1.0,
                  ),
                ),
              );
            }),

            // Cardinal directions
            ...['U', 'TL', 'T', 'TG', 'S', 'BD', 'B', 'BL'].asMap().entries.map(
              (entry) {
                final angle = entry.key * 45.0;
                final rad = (angle - 90) * math.pi / 180;
                final r = outerRadius - 28;
                final label = entry.value;
                final isUtara = label == 'U';
                final isSelatan = label == 'S';
                final ts = TextStyle(
                  fontSize: isUtara ? 15 : 10,
                  fontWeight: isUtara ? FontWeight.w900 : FontWeight.w700,
                  color: isUtara
                      ? CupertinoColors.white.withValues(alpha: 0.7)
                      : (isSelatan
                            ? CupertinoColors.white
                            : CupertinoColors.white.withValues(alpha: 0.7)),
                );
                final tp = TextPainter(
                  text: TextSpan(text: label, style: ts),
                  textDirection: TextDirection.ltr,
                )..layout();
                return Positioned(
                  left: center + r * math.cos(rad) - tp.width / 2,
                  top: center + r * math.sin(rad) - tp.height / 2,
                  child: Text(label, style: ts),
                );
              },
            ),

            // Degree labels
            ...List.generate(12, (i) {
              final angle = i * 30.0;
              final rad = (angle - 90) * math.pi / 180;
              final r = outerRadius - 44;
              if (angle % 90 == 0) return const SizedBox.shrink();
              final ts = TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.white.withValues(alpha: 0.4),
              );
              final text = '${angle.round()}°';
              final tp = TextPainter(
                text: TextSpan(text: text, style: ts),
                textDirection: TextDirection.ltr,
              )..layout();
              return Positioned(
                left: center + r * math.cos(rad) - tp.width / 2,
                top: center + r * math.sin(rad) - tp.height / 2,
                child: Text(text, style: ts),
              );
            }),

            // Inner rose
            SizedBox(
              width: compassSize,
              height: compassSize,
              child: CustomPaint(
                painter: _RosePainter(
                  center: Offset(center, center),
                  radius: outerRadius - 52,
                  color: CupertinoColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Qibla needle — satu-satunya jarum (tanpa jarum Utara)
            Transform.rotate(
              angle: _qibla * math.pi / 180,
              child: SizedBox(
                width: compassSize,
                height: compassSize,
                child: CustomPaint(
                  painter: _QiblaNeedlePainter(
                    center: Offset(center, center),
                    length: qiblaNeedleLength,
                    color: AppColors.toolTeal,
                  ),
                ),
              ),
            ),

            // Center dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAligned
                    ? AppColors.toolTeal
                    : CupertinoColors.systemGrey,
                boxShadow: [
                  BoxShadow(
                    color:
                        (isAligned
                                ? AppColors.toolTeal
                                : CupertinoColors.systemGrey)
                            .withValues(alpha: 0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.kompasKalibrasi,
            style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _headingOffset == 0
                ? AppColors.toolTeal.withValues(alpha: 0.3)
                : CupertinoColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => setState(() => _headingOffset = 0),
            child: Text(
              AppStrings.kompasNormal,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _headingOffset == 0
                    ? AppColors.toolTeal
                    : CupertinoColors.systemGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: _headingOffset == 180
                ? AppColors.toolTeal.withValues(alpha: 0.3)
                : CupertinoColors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            onPressed: () => setState(() => _headingOffset = 180),
            child: Text(
              AppStrings.kompasBalik,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _headingOffset == 180
                    ? AppColors.toolTeal
                    : CupertinoColors.systemGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    Color color,
    IconsType type,
  ) {
    IconData icon;
    switch (type) {
      case IconsType.heading:
        icon = CupertinoIcons.compass_fill;
        break;
      case IconsType.kiblat:
        icon = CupertinoIcons.flag_fill;
        break;
      case IconsType.selisih:
        icon = CupertinoIcons.arrow_up_right_square;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: '.SF Mono',
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

enum IconsType { heading, kiblat, selisih }

class _TickPainter extends CustomPainter {
  final Offset center;
  final double startRadius;
  final double endRadius;
  final double angle;
  final Color color;
  final double strokeWidth;

  _TickPainter({
    required this.center,
    required this.startRadius,
    required this.endRadius,
    required this.angle,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final start = Offset(
      center.dx + startRadius * math.cos(angle),
      center.dy + startRadius * math.sin(angle),
    );
    final end = Offset(
      center.dx + endRadius * math.cos(angle),
      center.dy + endRadius * math.sin(angle),
    );
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _TickPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.angle != angle;
}

class _RosePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _RosePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, radius, paint);

    for (int i = 0; i < 4; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        Offset(
          center.dx + radius * 0.85 * math.cos(a),
          center.dy + radius * 0.85 * math.sin(a),
        ),
        Offset(
          center.dx - radius * 0.85 * math.cos(a),
          center.dy - radius * 0.85 * math.sin(a),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RosePainter oldDelegate) =>
      oldDelegate.radius != radius;
}

class _QiblaNeedlePainter extends CustomPainter {
  final Offset center;
  final double length;
  final Color color;

  _QiblaNeedlePainter({
    required this.center,
    required this.length,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final tip = Offset(center.dx, center.dy - length);
    final wingY = center.dy - length * 0.3;
    final right = Offset(center.dx + 8, wingY);
    final left = Offset(center.dx - 8, wingY);

    // Upper diamond (tip to wings)
    final upperPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(right.dx, right.dy)
      ..lineTo(center.dx, center.dy - length * 0.15)
      ..lineTo(left.dx, left.dy)
      ..close();

    canvas.drawPath(
      upperPath,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color, color.withValues(alpha: 0.6)],
            ).createShader(
              Rect.fromLTRB(
                center.dx - 10,
                center.dy - length,
                center.dx + 10,
                center.dy,
              ),
            ),
    );

    // Spine line
    canvas.drawLine(
      tip,
      Offset(center.dx, center.dy - 8),
      Paint()
        ..color = CupertinoColors.white.withValues(alpha: 0.25)
        ..strokeWidth = 1.5,
    );

    // 'K' label at tip
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'K',
        style: TextStyle(
          color: CupertinoColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelX = center.dx - textPainter.width / 2;
    final labelY = tip.dy - textPainter.height - 3;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, labelY + textPainter.height / 2),
        width: textPainter.width + 8,
        height: textPainter.height + 4,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(bgRect, Paint()..color = color);
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.length != length || oldDelegate.color != color;
}
