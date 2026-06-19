import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.cloud_download_fill, size: 28, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            const Text('Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            provider.latestVersion != null
                ? 'Silahkan Update aplikasi Umma ke versi ${provider.latestVersion}'
                : 'Versi baru tersedia, silahkan update aplikasi Umma',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? CupertinoColors.white : AppColors.textLight),
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
            child: const Text('Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
    builder: (ctx) => _DownloadProgressDialog(context: context, provider: provider, dialogContext: ctx),
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
  State<_DownloadProgressDialog> createState() => _DownloadProgressDialogState();
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
      if (widget.dialogContext.mounted) Navigator.of(widget.dialogContext).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.context.mounted) {
          showInstallPermissionPopup(widget.context, widget.provider);
        }
      });
    } else if (status == UpdateStatus.idle) {
      // Install berhasil (reset) — tutup dialog
      if (widget.dialogContext.mounted) Navigator.of(widget.dialogContext).pop();
    } else if (status == UpdateStatus.error) {
      // Error — tutup dialog
      if (widget.dialogContext.mounted) Navigator.of(widget.dialogContext).pop();
      _showErrorToast(widget.context, widget.provider.error ?? 'Gagal download');
    } else {
      setState(() {});
    }
  }

  void _showErrorToast(BuildContext context, String message) {
    if (!context.mounted) return;
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 20, right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: CupertinoColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 3), () { if (mounted) entry.remove(); });
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const CupertinoActivityIndicator(radius: 14),
            ),
            const SizedBox(height: 12),
            const Text('Mengunduh Update', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
                      widthFactor: widget.provider.downloadFraction.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.provider.downloadTotal > 0
                    ? '${_formatSize(widget.provider.downloadProgress)} / ${_formatSize(widget.provider.downloadTotal)}'
                    : '${_formatSize(widget.provider.downloadProgress)} — Mengunduh...',
                style: TextStyle(fontSize: 12, color: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey),
              ),
              const SizedBox(height: 4),
              Text(
                widget.provider.downloadTotal > 0
                    ? '${(widget.provider.downloadFraction * 100).toStringAsFixed(0)}%'
                    : '...',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
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
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: CupertinoColors.systemOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.shield_fill, size: 28, color: CupertinoColors.systemOrange),
            ),
            const SizedBox(height: 12),
            const Text('Izin Diperlukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Aktifkan "Izinkan Install dari sumber tidak dikenal" '
            'di pengaturan, lalu kembali ke aplikasi untuk melanjutkan install.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.4, color: isDark ? CupertinoColors.white : AppColors.textLight),
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
            child: const Text('Buka Pengaturan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    ),
  );
}

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
