import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Service untuk mengecek update dan download APK dari GitHub.
class UpdateService {
  static const String appVersion = '1.0.0';
  static const String githubRepo = 'Jirankun/Umma---Qur-an-Indonesia';
  static const String tagsApiUrl =
      'https://api.github.com/repos/$githubRepo/tags';
  static const String releaseBaseUrl =
      'https://github.com/$githubRepo/releases/download';

  /// Ambil daftar tag dari GitHub API, urut terbaru duluan.
  Future<List<String>> fetchTags() async {
    try {
      final response = await http.get(
        Uri.parse(tagsApiUrl),
        headers: {
          'User-Agent': 'UmmaApp/1.0',
          'Accept': 'application/vnd.github+json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((t) => t['name'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  /// Ambil tag terbaru (pertama).
  Future<String?> getLatestTag() async {
    final tags = await fetchTags();
    return tags.isNotEmpty ? tags.first : null;
  }

  /// Bandingkan dua versi semantic. Return true jika [latest] > [current].
  bool isNewerVersion(String current, String latest) {
    final c = current.replaceFirst(RegExp(r'^v'), '');
    final l = latest.replaceFirst(RegExp(r'^v'), '');
    final cp = c.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final lp = l.split('.').map((s) => int.tryParse(s) ?? 0).toList();
    for (int i = 0; i < 3; i++) {
      final cv = i < cp.length ? cp[i] : 0;
      final lv = i < lp.length ? lp[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  /// Cek update. Return [UpdateCheckResult].
  Future<UpdateCheckResult> checkForUpdate() async {
    final latestTag = await getLatestTag();
    if (latestTag == null) {
      return UpdateCheckResult(hasUpdate: false, error: 'Tidak dapat menjangkau server');
    }
    final clean = latestTag.replaceFirst(RegExp(r'^v'), '');
    return UpdateCheckResult(
      hasUpdate: isNewerVersion(appVersion, latestTag),
      latestVersion: clean,
      latestTag: latestTag,
    );
  }

  /// Download APK via streaming. [onProgress](downloaded, total).
  Future<String> downloadApk({
    required String versionTag,
    required void Function(int downloaded, int total) onProgress,
  }) async {
    final clean = versionTag.replaceFirst(RegExp(r'^v'), '');
    final apkUrl = '$releaseBaseUrl/$versionTag/umma_v$clean.apk';

    final dir = await getTemporaryDirectory();
    final dlDir = Directory('${dir.path}/umma_update');
    if (!await dlDir.exists()) await dlDir.create(recursive: true);

    final filePath = '${dlDir.path}/umma_v$clean.apk';
    final existing = File(filePath);
    if (await existing.exists()) await existing.delete();

    final req = http.Request('GET', Uri.parse(apkUrl));
    final streamed = await req.send();
    if (streamed.statusCode != 200) {
      throw HttpException('Gagal download APK (HTTP ${streamed.statusCode})');
    }

    final total = streamed.contentLength ?? 0;
    int dl = 0;
    final sink = existing.openWrite();
    await for (final chunk in streamed.stream) {
      sink.add(chunk);
      dl += chunk.length;
      onProgress(dl, total);
    }
    await sink.close();
    return filePath;
  }

  /// Buka APK dengan package installer Android via MethodChannel ke native.
  /// Menggunakan FileProvider (content:// URI) — aman untuk Android 7+.
  Future<bool> installApk(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      await MethodChannel('app.umma.aokaze/installer').invokeMethod('installApk', {'path': filePath});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Buka pengaturan izin install dari sumber tidak dikenal.
  Future<bool> openInstallSettings() async {
    try {
      await MethodChannel('app.umma.aokaze/installer').invokeMethod('openInstallSettings');
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── URLS ─────────────────────────────────────────────────
  String get githubUrl => 'https://github.com/$githubRepo';
  String get releasesUrl => 'https://github.com/$githubRepo/releases';
}

/// Hasil pengecekan update.
class UpdateCheckResult {
  final bool hasUpdate;
  final String? latestVersion;
  final String? latestTag;
  final String? error;

  const UpdateCheckResult({
    required this.hasUpdate,
    this.latestVersion,
    this.latestTag,
    this.error,
  });
}
