import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/doa_provider.dart';
import '../../providers/hadits_provider.dart';
import '../../providers/fiqih_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/zakat_provider.dart';
import '../../providers/haid_provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../providers/muslim_ai_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/background_sound_provider.dart';
import '../../services/local_storage.dart';
import '../../config/api_config.dart';
import '../../config/ai_config.dart';

class P2pSyncScreen extends StatefulWidget {
  const P2pSyncScreen({super.key});

  @override
  State<P2pSyncScreen> createState() => _P2pSyncScreenState();
}

class _P2pSyncScreenState extends State<P2pSyncScreen> {
  int _selectedTab = 0; // 0 = Kirim, 1 = Terima

  // ─── SEND STATE ──────────────────────────────────────────
  String? _qrData;
  bool _isPreparing = false;
  String _dataSizeInfo = '';
  bool _dataTooLarge = false;

  // ─── RECEIVE STATE ───────────────────────────────────────
  bool _isProcessing = false;
  String _scanStatus = '';
  final MobileScannerController _scannerController = MobileScannerController();

  // ═══════════════════════════════════════════════════════
  //  SEND LOGIC
  // ═══════════════════════════════════════════════════════
  Future<void> _prepareQrData() async {
    setState(() {
      _isPreparing = true;
      _qrData = null;
      _dataTooLarge = false;
      _dataSizeInfo = 'Mengumpulkan data...';
    });

    try {
      final exportData = await LocalStorage().collectAllExportData();

      // Encode: JSON → gzip → base64
      final jsonStr = jsonEncode(exportData);
      final jsonBytes = utf8.encode(jsonStr);
      final gzipped = gzip.encode(jsonBytes);
      final b64 = base64Encode(gzipped);

      final rawSize = jsonBytes.length;
      final compressedSize = gzipped.length;
      final qrSize = b64.length;

      setState(() {
        _dataSizeInfo =
            'JSON: ${_formatBytes(rawSize)} → '
            'QR: ${_formatBytes(qrSize)} '
            '(kompresi ${((1 - compressedSize / rawSize) * 100).toStringAsFixed(0)}%)';

        if (qrSize > 4000) {
          // QR code versi 40 max ~4296 alphanumeric chars
          // Using byte mode: max ~2953 bytes. 4000 is conservative limit.
          _dataTooLarge = true;
          _qrData = null;
        } else {
          _qrData = b64;
          _dataTooLarge = false;
        }
      });
    } catch (e) {
      setState(() {
        _dataSizeInfo = 'Gagal: $e';
      });
    } finally {
      setState(() => _isPreparing = false);
    }
  }

  Future<void> _shareAsFile() async {
    try {
      final exportData = await LocalStorage().collectAllExportData();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/umma_backup.json');
      final jsonStr = jsonEncode(exportData);
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Backup Data Umma'),
      );
    } catch (e) {
      if (mounted) {
        _showToast('Gagal: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  //  RECEIVE LOGIC
  // ═══════════════════════════════════════════════════════
  void _onQrDetected(String data) {
    if (_isProcessing) return; // prevent double processing
    setState(() => _isProcessing = true);
    // Tutup kamera segera setelah QR terbaca
    _scannerController.stop();
    _restoreFromQrData(data);
  }

  Future<void> _restoreFromQrData(String b64Data) async {
    try {
      setState(() => _scanStatus = 'Mendekode data...');

      // Decode: base64 → gzip → json
      final gzipped = base64Decode(b64Data);
      final jsonBytes = gzip.decode(gzipped);
      final jsonStr = utf8.decode(jsonBytes);
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;

      setState(() => _scanStatus = 'Memulihkan data...');

      final restored = await LocalStorage().restoreFromExport(data);

      if (mounted) {
        await _reloadAllProviders();
        setState(() {
          _isProcessing = false;
        });
        // Tampilkan Cupertino modal sukses — bukan toast
        _showSuccessModal(restored);
      }
    } catch (e) {
      setState(() {
        _scanStatus = 'Gagal: $e';
        _isProcessing = false;
      });
    }
  }

  /// Tampilkan Cupertino modal sukses dengan icon proper (bukan emoji)
  void _showSuccessModal(int restored) {
    if (!mounted) return;
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 340,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Icon sukses — bukan emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.toolTeal.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 44,
                  color: AppColors.toolTeal,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Data Berhasil Dipulihkan',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$restored data berhasil dipulihkan.\nSemua pengaturan dan progres sudah diterapkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const Spacer(),
              CupertinoButton.filled(
                child: const Text(
                  'Oke',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _scanStatus = '';
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  //  UI
  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return CupertinoPageScaffold(
      backgroundColor: isDark
          ? AppColors.bgDark
          : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : CupertinoColors.systemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.arrow_2_circlepath,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(AppStrings.syncP2P),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ─── TAB SELECTOR ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceDark
                      : CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6,
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppColors.primary
                                : AppColors.blackTransparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.share_up,
                                size: 16,
                                color: _selectedTab == 0
                                    ? CupertinoColors.white
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.syncKirim,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTab == 0
                                      ? CupertinoColors.white
                                      : (isDark
                                            ? CupertinoColors.white
                                            : AppColors.textLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppColors.primary
                                : AppColors.blackTransparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.qrcode_viewfinder,
                                size: 16,
                                color: _selectedTab == 1
                                    ? CupertinoColors.white
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppStrings.syncTerima,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTab == 1
                                      ? CupertinoColors.white
                                      : (isDark
                                            ? CupertinoColors.white
                                            : AppColors.textLight),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── CONTENT ──────────────────────────────────
            Expanded(
              child: _selectedTab == 0
                  ? _buildSendTab(isDark)
                  : _buildReceiveTab(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SEND TAB ─────────────────────────────────────────────
  Widget _buildSendTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.profileBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.profileBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  size: 18,
                  color: AppColors.profileBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Data akan dikompres dan diubah jadi QR Code. '
                    'Perangkat lain bisa scan QR ini untuk memulihkan data.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Prepare button
          if (_qrData == null && !_isPreparing)
            SizedBox(
              width: double.infinity,
              child: CupertinoButton.filled(
                onPressed: _prepareQrData,
                child: Text(AppStrings.syncSiapkanQR),
              ),
            ),

          // Loading
          if (_isPreparing)
            const Column(
              children: [
                CupertinoActivityIndicator(radius: 16),
                SizedBox(height: 12),
                Text(
                  'Menyiapkan data...',
                  style: TextStyle(
                    fontSize: 13,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),

          // Data size info
          if (_dataSizeInfo.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _dataSizeInfo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ),

          // QR Code
          if (_qrData != null && !_dataTooLarge) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: CupertinoColors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.qrcode,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Scan QR ini di perangkat tujuan',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              onPressed: _prepareQrData,
              child: const Text(
                'Buat Ulang QR',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],

          // Data too large → fallback to file share
          if (_dataTooLarge) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CupertinoColors.systemYellow.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Data terlalu besar untuk QR Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gunakan opsi Backup File untuk mengirim data.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: _shareAsFile,
                      child: const Text(
                        'Bagikan sebagai File',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],


        ],
      ),
    );
  }

  // ─── RECEIVE TAB ──────────────────────────────────────────
  Widget _buildReceiveTab(bool isDark) {
    return Column(
      children: [
        // Scanner area
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.textLight
                    : CupertinoColors.systemGrey5,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  fit: BoxFit.cover,
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    final rawValue = barcode?.rawValue;
                    if (rawValue != null && !_isProcessing) {
                      _onQrDetected(rawValue);
                    }
                  },
                ),

                // Overlay scan area indicator
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.white.withValues(alpha: 0.6),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                // Top gradient hint
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          CupertinoColors.black.withValues(alpha: 0.5),
                          AppColors.blackTransparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.qrcode_viewfinder,
                          size: 16,
                          color: CupertinoColors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Arahkan kamera ke QR Code',
                          style: TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: CupertinoColors.black.withValues(alpha: 0.6),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CupertinoActivityIndicator(
                            radius: 20,
                            color: CupertinoColors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _scanStatus,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Status / info
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.textLight
                    : CupertinoColors.systemGrey6,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.toolTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        CupertinoIcons.lock_fill,
                        size: 16,
                        color: AppColors.toolTeal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '100% Peer-to-Peer',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? CupertinoColors.white
                                  : AppColors.textLight,
                            ),
                          ),
                          Text(
                            'Data tidak dikirim ke server',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_scanStatus.isNotEmpty)
                  Text(
                    _scanStatus,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _scanStatus.startsWith('✅')
                          ? AppColors.toolTeal
                          : _scanStatus.startsWith('❌')
                          ? CupertinoColors.systemRed
                          : (isDark
                                ? CupertinoColors.white
                                : AppColors.textLight),
                    ),
                  ),
                if (_scanStatus.isNotEmpty && _scanStatus.startsWith('✅'))
                  const SizedBox(height: 12),
                if (_scanStatus.isNotEmpty && _scanStatus.startsWith('✅'))
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: () {
                        setState(() {
                          _scanStatus = '';
                          _isProcessing = false;
                        });
                      },
                      child: const Text(
                        'Scan Lagi',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                if (_scanStatus.startsWith('❌')) const SizedBox(height: 12),
                if (_scanStatus.startsWith('❌'))
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () {
                        setState(() {
                          _scanStatus = '';
                          _isProcessing = false;
                        });
                      },
                      child: const Text(
                        'Coba Lagi',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),

              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  /// Reload ALL providers after data restore — shared antara QR scan & file import
  /// Semua loadX() dijalankan parallel via Future.wait() untuk kecepatan maksimal.
  Future<void> _reloadAllProviders() async {
    final futures = <Future<void>>[];

    // Theme
    final themeStr = LocalStorage().getString(ApiConfig.storageKeyTheme);
    if (themeStr != null) {
      context.read<ThemeProvider>().loadTheme(themeStr);
    }

    // Provider loads — semua dijalankan parallel
    futures.add(context.read<UserProvider>().loadProfile());
    futures.add(context.read<TrackerProvider>().loadTrackers());
    futures.add(context.read<QuranProvider>().loadStoredData());
    futures.add(context.read<DoaProvider>().loadData());
    futures.add(context.read<HaditsProvider>().loadBooks());
    futures.add(context.read<FiqihProvider>().loadContent());
    futures.add(context.read<JournalProvider>().loadJournals());
    futures.add(context.read<ZakatProvider>().loadSavedSettings());
    futures.add(context.read<HaidProvider>().loadData());
    futures.add(context.read<TasbihProvider>().loadSettings());
    futures.add(context.read<MuslimAiProvider>().loadCooldown());
    futures.add(context.read<BackgroundSoundProvider>().loadSettings());

    // Tunggu semua selesai parallel
    await Future.wait(futures);

    // Prayer times (butuh user profile kota yang sudah di-load)
    final userProvider = context.read<UserProvider>();
    final currentCity = userProvider.profile?.locationCity;
    if (currentCity != null) {
      context.read<PrayerTimesProvider>().fetchPrayerTimes(city: currentCity);
    }

    // Groq API key (applied runtime)
    final groqKey = LocalStorage().getString(ApiConfig.storageKeyGroqApiKey);
    if (groqKey != null && groqKey.isNotEmpty) {
      AiConfig.groqApiKey = groqKey;
    }
  }

  // ─── HELPERS ──────────────────────────────────────────────
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showToast(String message) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.black,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) entry.remove();
    });
  }
}
