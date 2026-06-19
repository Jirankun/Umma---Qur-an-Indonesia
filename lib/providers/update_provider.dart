import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../services/update_service.dart';

/// Status alur update.
enum UpdateStatus {
  idle,
  checking,
  updateAvailable,
  noUpdate,
  downloadReady, // user akan download
  downloading,
  downloadComplete,
  installing,
  error,
  installPermissionNeeded,
}

/// Provider untuk mengecek update dan mengelola download APK.
class UpdateProvider extends ChangeNotifier {
  final UpdateService _service = UpdateService();

  UpdateStatus _status = UpdateStatus.idle;
  String? _latestVersion;
  String? _latestTag;
  String? _apkPath;
  String? _error;
  int _downloadProgress = 0;
  int _downloadTotal = 0;
  bool _dismissed = false; // user pernah dismiss popup (tidak berlaku untuk mandatory)

  UpdateStatus get status => _status;
  String? get latestVersion => _latestVersion;
  String? get error => _error;
  String? get apkPath => _apkPath;
  int get downloadProgress => _downloadProgress;
  int get downloadTotal => _downloadTotal;
  double get downloadFraction =>
      _downloadTotal > 0 ? _downloadProgress / _downloadTotal : 0.0;
  bool get isMandatoryUpdate => _status == UpdateStatus.updateAvailable && !_dismissed;

  /// Cek update dari GitHub.
  Future<void> checkForUpdate() async {
    if (_status == UpdateStatus.checking) return;

    _status = UpdateStatus.checking;
    _error = null;
    notifyListeners();

    final result = await _service.checkForUpdate();

    if (result.hasUpdate) {
      _latestVersion = result.latestVersion;
      _latestTag = result.latestTag;
      _dismissed = false;
      _status = UpdateStatus.updateAvailable;
    } else if (result.error != null) {
      _error = result.error;
      _status = UpdateStatus.error;
    } else {
      _status = UpdateStatus.noUpdate;
    }
    notifyListeners();
  }

  /// User menekan tombol Update — mulai proses download.
  Future<void> startDownload() async {
    if (_latestTag == null) return;

    _status = UpdateStatus.downloading;
    _downloadProgress = 0;
    _downloadTotal = 0;
    notifyListeners();

    try {
      _apkPath = await _service.downloadApk(
        versionTag: _latestTag!,
        onProgress: (downloaded, total) {
          _downloadProgress = downloaded;
          _downloadTotal = total;
          notifyListeners();
        },
      );
      _status = UpdateStatus.downloadComplete;
      notifyListeners();

      // Langsung coba install
      await _installApk();
    } catch (e) {
      _error = e.toString();
      _status = UpdateStatus.error;
      notifyListeners();
    }
  }

  /// Install APK yang sudah didownload.
  Future<void> _installApk() async {
    if (_apkPath == null) return;

    _status = UpdateStatus.installing;
    notifyListeners();

    final success = await _service.installApk(_apkPath!);
    if (success) {
      // Berhasil buka installer Android — reset state
      reset();
    } else {
      // Set status — UI (permission popup) yang handle navigasi settings
      _status = UpdateStatus.installPermissionNeeded;
      notifyListeners();
    }
  }

  /// Buka pengaturan izin install dari sumber tidak dikenal.
  Future<bool> openInstallSettings() async {
    return _service.openInstallSettings();
  }

  /// Dipanggil setelah user kembali dari settings.
  Future<void> retryInstall() async {
    await _installApk();
  }

  /// Reset ke idle (setelah sukses / user tutup popup error).
  void reset() {
    _status = UpdateStatus.idle;
    _error = null;
    _apkPath = null;
    _downloadProgress = 0;
    _downloadTotal = 0;
    notifyListeners();
  }

  /// Cek di background (tanpa notify — untuk WorkManager)
  Future<UpdateCheckResult?> backgroundCheck() async {
    return _service.checkForUpdate();
  }
}
