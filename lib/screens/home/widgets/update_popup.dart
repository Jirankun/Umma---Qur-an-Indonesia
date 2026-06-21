import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/update_provider.dart';

/// Tampilkan mandatory update popup — tidak bisa ditutup, hanya 1 tombol Update.
void showUpdatePopup(BuildContext context, UpdateProvider provider) {
  final isDark = Provider.of<ThemeProvider>(context).isDark;

  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.cloud_download_fill,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.update,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            provider.latestVersion != null
                ? 'Silahkan Update aplikasi Umma ke versi ${provider.latestVersion}'
                : 'Versi baru tersedia, silahkan update aplikasi Umma',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.startDownload();
              showDownloadProgress(context, provider);
            },
            child: Text(
              AppStrings.update,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tampilkan download progress popup — mandatory, tidak bisa ditutup.
void showDownloadProgress(BuildContext context, UpdateProvider provider) {
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _DownloadProgressDialog(
      context: context,
      provider: provider,
      dialogContext: ctx,
    ),
  );
}

/// StatefulWidget untuk download progress — tidak ada memory leak karena listener dibersihkan di dispose.
class _DownloadProgressDialog extends StatefulWidget {
  final BuildContext context;
  final UpdateProvider provider;
  final BuildContext dialogContext;

  const _DownloadProgressDialog({
    required this.context,
    required this.provider,
    required this.dialogContext,
  });

  @override
  State<_DownloadProgressDialog> createState() =>
      _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<_DownloadProgressDialog> {
  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onProviderChange);
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _onProviderChange() {
    if (!mounted) return;
    final status = widget.provider.status;
    // Tunggu sampai _installApk selesai sebelum tutup dialog
    if (status == UpdateStatus.installing) {
      // Install mulai, tampilkan status
      setState(() {});
    } else if (status == UpdateStatus.installPermissionNeeded) {
      // Install butuh izin — tutup download dialog, tampilkan permission dialog
      if (widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.context.mounted) {
          showInstallPermissionPopup(widget.context, widget.provider);
        }
      });
    } else if (status == UpdateStatus.idle) {
      // Install berhasil (reset) — tutup dialog
      if (widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop();
      }
    } else if (status == UpdateStatus.error) {
      // Error — tutup dialog
      if (widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop();
      }
      _showErrorToast(
        widget.context,
        widget.provider.error ?? 'Gagal download',
      );
    } else {
      setState(() {});
    }
  }

  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) entry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const CupertinoActivityIndicator(radius: 14),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.mengunduh,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: widget.provider.downloadTotal > 0
                    ? FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: widget.provider.downloadFraction.clamp(
                          0.0,
                          1.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.provider.downloadTotal > 0
                    ? '${_formatSize(widget.provider.downloadProgress)} / ${_formatSize(widget.provider.downloadTotal)}'
                    : '${_formatSize(widget.provider.downloadProgress)} — Mengunduh...',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.provider.downloadTotal > 0
                    ? '${(widget.provider.downloadFraction * 100).toStringAsFixed(0)}%'
                    : '...',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: const [SizedBox.shrink()],
      ),
    );
  }
}

/// Tampilkan popup install permission needed.
void showInstallPermissionPopup(BuildContext context, UpdateProvider provider) {
  final isDark = Provider.of<ThemeProvider>(context).isDark;

  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.shield_fill,
                size: 28,
                color: CupertinoColors.systemOrange,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.izinDiperlukan,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Aktifkan "Izinkan Install dari sumber tidak dikenal" '
            'di pengaturan, lalu kembali ke aplikasi untuk melanjutkan install.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.openInstallSettings();
              // retryInstall akan dipanggil saat app resume (lifecycle)
            },
            child: Text(
              AppStrings.bukaPengaturan,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Tampilkan popup cek update — SATU DIALOG dengan teks yang berubah.
/// Loading → sukses/gagal — bukan 2 entitas terpisah.
void showUpdateCheckPopup(BuildContext context, UpdateProvider provider) {
  final ctx = context;
  showCupertinoDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => _UpdateCheckDialog(
      provider: provider,
      dialogContext: dialogCtx,
      parentContext: ctx,
    ),
  );
}

/// StatefulWidget untuk dialog cek update — teks berubah sendiri saat status berubah.
class _UpdateCheckDialog extends StatefulWidget {
  final UpdateProvider provider;
  final BuildContext dialogContext;
  final BuildContext parentContext;

  const _UpdateCheckDialog({
    required this.provider,
    required this.dialogContext,
    required this.parentContext,
  });

  @override
  State<_UpdateCheckDialog> createState() => _UpdateCheckDialogState();
}

class _UpdateCheckDialogState extends State<_UpdateCheckDialog> {
  String _message = 'Memeriksa update...';
  bool _isLoading = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.provider.addListener(_onStatusChange);
    // Cek status saat ini (mungkin sudah checking)
    _onStatusChange();
  }

  @override
  void dispose() {
    widget.provider.removeListener(_onStatusChange);
    super.dispose();
  }

  void _onStatusChange() {
    if (!mounted) return;
    switch (widget.provider.status) {
      case UpdateStatus.checking:
        setState(() {
          _message = 'Mohon tunggu...';
          _isLoading = true;
          _isSuccess = false;
        });
        break;
      case UpdateStatus.noUpdate:
        setState(() {
          _message = 'Aplikasi sudah versi terbaru';
          _isLoading = false;
          _isSuccess = true;
        });
        break;
      case UpdateStatus.updateAvailable:
        // Tutup dialog cek — lalu tampilkan popup update
        if (widget.dialogContext.mounted) {
          Navigator.of(widget.dialogContext).pop();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.parentContext.mounted) {
            showUpdatePopup(widget.parentContext, widget.provider);
          }
        });
        break;
      case UpdateStatus.error:
        final errMsg = widget.provider.error;
        setState(() {
          _message =
              'Gagal memeriksa update${errMsg != null ? ': $errMsg' : ''}';
          _isLoading = false;
          _isSuccess = false;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    return PopScope(
      canPop: !_isLoading, // Tidak bisa ditutup saat loading
      child: CupertinoAlertDialog(
        title: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _isSuccess
                    ? AppColors.accent.withValues(alpha: 0.1)
                    : _isLoading
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : CupertinoColors.systemRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const CupertinoActivityIndicator(radius: 14)
                  : _isSuccess
                  ? const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      size: 28,
                      color: AppColors.accent,
                    )
                  : const Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      size: 28,
                      color: CupertinoColors.systemRed,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              _isLoading
                  ? 'Memeriksa Update'
                  : _isSuccess
                  ? 'Terbaru'
                  : 'Gagal',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? CupertinoColors.white : AppColors.textLight,
            ),
          ),
        ),
        actions: _isLoading
            ? const [SizedBox.shrink()]
            : [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
