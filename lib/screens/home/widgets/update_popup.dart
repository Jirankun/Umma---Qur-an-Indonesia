import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/update_provider.dart';

/// Tampilkan mandatory update popup — tidak bisa ditutup, hanya 1 tombol Update.
void showUpdatePopup(BuildContext context, UpdateProvider provider) {
  // Cegah stacking popup
  if (provider.isPopupVisible) return;
  provider.setPopupVisible(true);

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
              color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              provider.setPopupVisible(false);
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
  // Cegah stacking popup
  if (provider.isPopupVisible) return;
  provider.setPopupVisible(true);

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
    widget.provider.setPopupVisible(false);
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
        widget.provider.setPopupVisible(false);
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
        widget.provider.setPopupVisible(false);
      }
    } else if (status == UpdateStatus.error) {
      // Error — tutup dialog download, tampilkan popup error
      if (widget.dialogContext.mounted) {
        Navigator.of(widget.dialogContext).pop();
        widget.provider.setPopupVisible(false);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.context.mounted) {
          showErrorPopup(widget.context, widget.provider);
        }
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.cupertinoSystemGrey5,
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
                  color: AppColors.cupertinoSystemGrey,
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

/// Tampilkan popup error download — proper dialog, bukan toast.
void showErrorPopup(BuildContext context, UpdateProvider provider) {
  // Cegah stacking popup
  if (provider.isPopupVisible) return;
  provider.setPopupVisible(true);

  final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

  showCupertinoDialog(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.cupertinoSystemRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle_fill,
              size: 28,
              color: AppColors.cupertinoSystemRed,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.gagalMengunduh,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          provider.error ?? AppStrings.updateError,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            provider.setPopupVisible(false);
            Navigator.of(ctx).pop();
          },
          child: Text(
            AppStrings.tutup,
            style: const TextStyle(
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

/// Tampilkan popup install permission needed.
void showInstallPermissionPopup(BuildContext context, UpdateProvider provider) {
  // Cegah stacking popup
  if (provider.isPopupVisible) return;
  provider.setPopupVisible(true);

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
                color: AppColors.cupertinoSystemOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.shield_fill,
                size: 28,
                color: AppColors.cupertinoSystemOrange,
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
            AppStrings.installPermission,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              provider.setPopupVisible(false);
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
  // Cegah stacking popup
  if (provider.isPopupVisible) return;
  provider.setPopupVisible(true);

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
    widget.provider.setPopupVisible(false);
    super.dispose();
  }

  void _onStatusChange() {
    if (!mounted) return;
    switch (widget.provider.status) {
      case UpdateStatus.checking:
        setState(() {
          _message = AppStrings.updateCheckWait;
          _isLoading = true;
          _isSuccess = false;
        });
        break;
      case UpdateStatus.noUpdate:
        setState(() {
          _message = AppStrings.updateAlreadyLatest;
          _isLoading = false;
          _isSuccess = true;
        });
        break;
      case UpdateStatus.updateAvailable:
        // Tutup dialog cek — reset flag dulu agar showUpdatePopup bisa tampil
        if (widget.dialogContext.mounted) {
          widget.provider.setPopupVisible(false);
          Navigator.of(widget.dialogContext).pop();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.parentContext.mounted) {
            showUpdatePopup(widget.parentContext, widget.provider);
          }
        });
        break;
      case UpdateStatus.error:
        setState(() {
          _message = AppStrings.updateCheckError;
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
                    : AppColors.cupertinoSystemRed.withValues(alpha: 0.1),
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
                      color: AppColors.cupertinoSystemRed,
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              _isLoading
                  ? AppStrings.updateChecking
                  : _isSuccess
                  ? AppStrings.updateLatest
                  : AppStrings.updateCheckFailed,
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
              color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
            ),
          ),
        ),
        actions: _isLoading
            ? const [SizedBox.shrink()]
            : [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    widget.provider.setPopupVisible(false);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppStrings.tutup,
                    style: const TextStyle(
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
