import 'package:package_info_plus/package_info_plus.dart';

// ============================================================
// APP INFO — Baca versi aplikasi dari native build config
// ============================================================
// Menggunakan package_info_plus untuk membaca versionName
// dan versionCode dari android/app/build.gradle.kts secara
// native. Fallback ke '1.0.0' jika gagal.
// ============================================================

class AppInfo {
  static String version = '1.0.0'; // fallback
  static String buildNumber = '1';
  static bool _initialized = false;

  /// Inisialisasi — panggil di main() sebelum runApp()
  static Future<void> init() async {
    if (_initialized) return;
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      buildNumber = info.buildNumber;
      _initialized = true;
    } catch (_) {
      // Fallback tetap '1.0.0'
    }
  }

  /// Display string: "v1.0.1"
  static String get displayVersion => 'v$version';

  /// Display string: "Umma v1.0.1"
  static String get fullDisplay => 'Umma v$version';
}
