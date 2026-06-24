import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../config/api_config.dart';
import '../../../config/ai_config.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/background_sound_provider.dart';
import '../../../providers/tracker_provider.dart';
import '../../../providers/prayer_times_provider.dart';
import '../../../providers/quran_provider.dart';
import '../../../providers/doa_provider.dart';
import '../../../providers/hadits_provider.dart';
import '../../../providers/fiqih_provider.dart';
import '../../../providers/journal_provider.dart';
import '../../../providers/zakat_provider.dart';
import '../../../providers/haid_provider.dart';
import '../../../providers/tasbih_provider.dart';
import '../../../providers/muslim_ai_provider.dart';
import '../../../services/local_storage.dart';
import 'profile_helpers.dart';

// ═══════════════════════════════════════════════════════════════
// PROFILE DIALOGS — All bottom sheet dialogs for User Profile
// ═══════════════════════════════════════════════════════════════
class ProfileDialogs {
  ProfileDialogs._();

  // ─── 1. EDIT PROFILE ────────────────────────────────────────
  static void showEditProfile(BuildContext context, bool isDark) {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.profile;
    final nameController = TextEditingController(text: profile?.username ?? '');
    String selectedCity = profile?.locationCity ?? 'Jakarta';
    String searchCity = '';

    final cities = ApiConfig.indonesianCities;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: StatefulBuilder(
            builder: (context, setSheetState) => Container(
              height: 480,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceDark
                    : AppColors.cupertinoSystemBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.cupertinoSystemGrey4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.userEditProfile,
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      AppStrings.userUsername,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cupertinoSystemGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CupertinoTextField(
                      controller: nameController,
                      placeholder: AppStrings.userMasukkanNama,
                      padding: const EdgeInsets.all(12),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.cupertinoWhite
                            : AppColors.textLight,
                        fontSize: 14,
                      ),
                      placeholderStyle: TextStyle(
                        color: isDark
                            ? AppColors.cupertinoSystemGrey
                            : AppColors.cupertinoSystemGrey2,
                        fontSize: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textLight
                            : AppColors.cupertinoTertiarySystemBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.userKota,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cupertinoSystemGrey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CupertinoSearchTextField(                        placeholder: AppStrings.userCariKota,
                      onChanged: (v) =>
                          setSheetState(() => searchCity = v.toLowerCase()),
                      onSuffixTap: () => setSheetState(() {
                        searchCity = '';
                      }),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: buildCitySearchResult(
                        cities,
                        searchCity,
                        selectedCity,
                        isDark,
                        (city) {
                          setSheetState(() => selectedCity = city);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    CupertinoButton.filled(
                      child: Text(AppStrings.userSimpan),
                      onPressed: () {
                        final name = nameController.text.trim();
                        if (name.isNotEmpty) {
                          userProvider.updateUsername(name);
                        }
                        userProvider.updateCity(selectedCity);
                        context
                            .read<PrayerTimesProvider>()
                            .fetchPrayerTimes(city: selectedCity);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── 2. AI SETTINGS ──────────────────────────────────────
  static void showAiSettings(BuildContext context, bool isDark) {
    final keyController =
        TextEditingController(text: AiConfig.groqApiKey);
    bool showKey = false;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            padding: EdgeInsets.only(bottom: bottomInset),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.cupertinoSystemBackground,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cupertinoSystemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        CupertinoIcons.sparkles,
                        size: 18,
                        color: AppColors.toolIndigo,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Pengaturan AI',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Masukkan API key Groq pribadi Anda untuk mengaktifkan Muslim AI Chat.\n\n'
                    'Konten AI lainnya (quotes, nasehat, quest) sudah aktif secara default.\n\n'
                    'Dapatkan API key gratis di console.groq.com',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.cupertinoSystemGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CupertinoTextField(
                    controller: keyController,
                    placeholder: 'gsk_...',
                    obscureText: !showKey,
                    padding: const EdgeInsets.all(12),
                    style: TextStyle(
                      color: isDark
                          ? AppColors.cupertinoWhite
                          : AppColors.textLight,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    placeholderStyle: TextStyle(
                      color: isDark
                          ? AppColors.cupertinoSystemGrey
                          : AppColors.cupertinoSystemGrey2,
                      fontSize: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textLight
                          : AppColors.cupertinoTertiarySystemBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffix: GestureDetector(
                      onTap: () =>
                          setSheetState(() => showKey = !showKey),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          showKey
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          size: 18,
                          color: AppColors.cupertinoSystemGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => openUrl(ApiConfig.groqConsoleUrl, context),
                    child: const Row(
                      children: [
                        Icon(
                          CupertinoIcons.link,
                          size: 12,
                          color: AppColors.toolIndigo,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Buka console.groq.com',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.toolIndigo,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoButton(
                          child: Text(AppStrings.deleteKey),
                          onPressed: () async {
                            AiConfig.groqApiKey = '';
                            final storage = LocalStorage();
                            await storage.remove(
                              ApiConfig.storageKeyGroqApiKey,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              showToast(ctx, 'API key berhasil dihapus');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CupertinoButton.filled(
                          child: Text(AppStrings.saveKey),
                          onPressed: () async {
                            final key = keyController.text.trim();
                            if (key.isEmpty) {
                              showToast(context,
                                  'Masukkan API key terlebih dahulu');
                              return;
                            }
                            AiConfig.groqApiKey = key;
                            final storage = LocalStorage();
                            await storage.setString(
                              ApiConfig.storageKeyGroqApiKey,
                              key,
                            );
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              showToast(ctx, '✅ API key berhasil disimpan');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── 3. DATA MANAGEMENT ─────────────────────────────────────
  static void showDataManagement(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Manajemen Data',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Text(
                'Pindahkan data Jurnal, Tracker, dan preferensi Anda jika ingin berpindah perangkat.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.cupertinoSystemGrey
                      : AppColors.cupertinoSystemGrey,
                ),
              ),
              const SizedBox(height: 20),
              // Export
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.profileBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.profileBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Export (Backup) Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fiqihSholat,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unduh semua progres ke file .json',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.cupertinoSystemGrey
                            : AppColors.cupertinoSystemGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        child: const Text(
                          'Buat Backup',
                          style: TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _exportData(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Import
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.toolTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.toolTeal.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import (Restore) Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pulihkan data dari file backup',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.cupertinoSystemGrey
                            : AppColors.cupertinoSystemGrey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        child: const Text(
                          'Pilih File Backup',
                          style: TextStyle(fontSize: 13),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _importData(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _exportData(BuildContext context) async {
    try {
      final exportData = await LocalStorage().collectAllExportData();
      final jsonStr = jsonEncode(exportData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/umma_backup.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Backup Data Umma',
        ),
      );

      if (context.mounted) {
        showToast(context, 'Backup berhasil dibuat!');
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Gagal export data: $e');
      }
    }
  }

  static Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (context.mounted) showToast(context, 'Gagal membaca file');
        return;
      }

      if (!context.mounted) return;
      showToast(context, 'Memulihkan data...');

      final file = File(filePath);
      final content = await file.readAsString();

      Map<String, dynamic> data;

      if (content.trim().startsWith('{')) {
        data = jsonDecode(content) as Map<String, dynamic>;
      } else {
        try {
          final gzipped = base64Decode(content.trim());
          final jsonBytes = gzip.decode(gzipped);
          final jsonStr = utf8.decode(jsonBytes);
          data = jsonDecode(jsonStr) as Map<String, dynamic>;
        } catch (_) {
          if (context.mounted) {
            showToast(context, 'Format file tidak dikenal');
          }
          return;
        }
      }

      final restored = await LocalStorage().restoreFromExport(data);

      if (context.mounted) {
        final themeStr = LocalStorage()
            .getString(ApiConfig.storageKeyTheme);
        if (themeStr != null) {
          context.read<ThemeProvider>().loadTheme(themeStr);
        }

        context.read<UserProvider>().loadProfile();
        context.read<TrackerProvider>().loadTrackers();
        context.read<QuranProvider>().loadStoredData();
        context.read<DoaProvider>().loadData();
        context.read<HaditsProvider>().loadBooks();
        context.read<FiqihProvider>().loadContent();
        context.read<JournalProvider>().loadJournals();
        context.read<ZakatProvider>().loadSavedSettings();
        context.read<HaidProvider>().loadData();
        context.read<TasbihProvider>().loadSettings();
        context.read<MuslimAiProvider>().loadCooldown();
        context.read<BackgroundSoundProvider>().loadSettings();

        final userProvider = context.read<UserProvider>();
        final currentCity = userProvider.profile?.locationCity;
        if (currentCity != null) {
          context
              .read<PrayerTimesProvider>()
              .fetchPrayerTimes(city: currentCity);
        }

        final groqKey = LocalStorage()
            .getString(ApiConfig.storageKeyGroqApiKey);
        if (groqKey != null && groqKey.isNotEmpty) {
          AiConfig.groqApiKey = groqKey;
        }

        showToast(context, '✅ $restored data berhasil dipulihkan!');
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Gagal import data: $e');
      }
    }
  }

  // ─── 4. RESET DATA ─────────────────────────────────────────
  static void showResetConfirm(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
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
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.cupertinoSystemRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.trash_fill,
                  size: 28,
                  color: AppColors.cupertinoSystemRed,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Reset Semua Data?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua data tracker, jurnal, bookmark, dan preferensi akan dihapus secara permanen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      child: Text(AppStrings.cancel),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CupertinoButton.filled(
                      child: Text(AppStrings.yesHapus),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await LocalStorage().clearAll();
                        if (context.mounted) {
                          context.read<TrackerProvider>().loadTrackers();
                          context.read<QuranProvider>().loadStoredData();
                          context.read<DoaProvider>().loadData();
                          context.read<HaditsProvider>().loadBooks();
                          context.read<FiqihProvider>().loadContent();
                          context.read<JournalProvider>().loadJournals();
                          context.read<ZakatProvider>().loadSavedSettings();
                          context.read<HaidProvider>().loadData();
                          context.read<TasbihProvider>().loadSettings();
                          showToast(context, 'Semua data berhasil direset');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 5. BANTUAN & FAQ ──────────────────────────────────────
  static void showBantuan(BuildContext context, bool isDark) {
    final faqs = [
      {
        'q': 'Apakah aplikasi ini butuh internet?',
        'a':
            'Sebagian besar fitur — Al-Qur\'an, Hadits, Doa, Tracker Ibadah, Tasbih, Arah Kiblat — bisa dipakai offline. Internet hanya diperlukan untuk Muslim AI, konten inspirasi harian, dan jadwal sholat terbaru.',
      },
      {
        'q': 'Kenapa data saya tidak muncul di HP lain?',
        'a':
            'Umma 100% offline (Local-First). Data kamu tersimpan aman di memori HP ini, bukan di server. Untuk pindah data, gunakan fitur Sync P2P (QR) atau Backup File di menu Profil.',
      },
      {
        'q': 'Bagaimana cara cadangkan & pindahkan data?',
        'a':
            'Buka Profil → Sync P2P (QR) untuk kirim data langsung ke HP lain via QR Code. Kalau data terlalu besar, gunakan "Manajemen Data" → "Buat Backup" untuk ekspor file .json, lalu kirim file itu ke HP baru.',
      },
      {
        'q': 'Kenapa jadwal sholat saya tidak sesuai?',
        'a':
            'Pastikan lokasi kota sudah benar. Buka Profil → Edit Profil → pilih kota yang sesuai. Jadwal sholat otomatis terupdate setelah kota diganti.',
      },
      {
        'q': 'Apa itu Muslim AI? Apa saja yang bisa ditanyakan?',
        'a':
            'Muslim AI adalah asisten pintar yang bisa jawab pertanyaan seputar doa, surat, fiqih, dan hadits. Bisa juga dipakai ngobrol santai. Pilih mode yang sesuai, lalu ketik pertanyaan kamu. Fitur ini butuh koneksi internet.',
      },
      {
        'q': 'Apakah ada biaya untuk menggunakan Umma?',
        'a':
            'Umma 100% gratis tanpa iklan. Tidak ada biaya langganan, tidak ada pembelian dalam aplikasi. Semua fitur bisa dinikmati tanpa dipungut biaya.',
      },
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 500,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Bantuan & FAQ',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: faqs.length,
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textLight.withValues(alpha: 0.5)
                            : AppColors.cupertinoTertiarySystemBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Q. ${faq['q']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.cupertinoWhite
                                  : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            faq['a']!,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark
                                  ? AppColors.cupertinoSystemGrey
                                  : AppColors.cupertinoSystemGrey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 6. KEBIJAKAN PRIVASI ──────────────────────────────────
  static void showPrivasi(BuildContext context, bool isDark) {
    final items = [
      {
        'num': 1,
        'title': '100% Local-First (Data di HP Anda)',
        'desc':
            'Semua data Anda disimpan sepenuhnya secara lokal di memori perangkat Anda.',
      },
      {
        'num': 2,
        'title': 'Tidak Ada Database Server',
        'desc':
            'Kami tidak mengumpulkan, melihat, atau menyimpan data pribadi Anda di server mana pun.',
      },
      {
        'num': 3,
        'title': 'Transfer Data Langsung',
        'desc':
            'Saat Anda memindahkan data ke perangkat baru, file backup ditransfer langsung tanpa perantara server.',
      },
      {
        'num': 4,
        'title': 'Tanpa Iklan & Pelacakan',
        'desc':
            'Aplikasi ini bersih dari iklan pihak ketiga dan skrip pelacak.',
      },
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 460,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kebijakan Privasi',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kenyamanan dan privasi Anda adalah prioritas mutlak kami:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.toolTeal.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${item['num']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.cupertinoWhite
                                        : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.cupertinoSystemGrey
                                        : AppColors.cupertinoSystemGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 7. TENTANG UMMA ──────────────────────────────────────
  static void showTentang(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 420,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  CupertinoIcons.book_fill,
                  size: 32,
                  color: AppColors.cupertinoWhite,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Umma',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.appVersionShort,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Umma adalah aplikasi Muslim all-in-one yang dirancang untuk '
                    'membantu ibadah sehari-hari. Fitur lengkap mulai dari Al-Quran digital '
                    'dengan audio, kumpulan doa & dzikir, hadits, fiqih, jadwal sholat, '
                    'tracker ibadah, jurnal, hingga tasbih dan arah kiblat.\n\n'
                    'Aplikasi ini 100% gratis tanpa iklan. Data Anda aman tersimpan secara '
                    'lokal di perangkat Anda sendiri.\n\n'
                    'Semoga menjadi amal jariyah dan bermanfaat bagi kita semua. 🤲',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark
                          ? AppColors.cupertinoWhite
                          : AppColors.textLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 8. PENGEMBANG APLIKASI ────────────────────────────────
  static void showPengembang(BuildContext context, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 360,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClipOval(
                child: Image.network(
                  ApiConfig.githubAvatarUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.indigoLight, AppColors.toolIndigo],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      size: 32,
                      color: AppColors.cupertinoWhite,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'ZHYLLAN FYLLAH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.cupertinoWhite
                      : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Ikuti Saya',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildSocialButton(
                    context: context,
                    url: ApiConfig.developerPortfolioUrl,
                    icon: CupertinoIcons.link,
                    label: 'Portofolio',
                  ),
                  const SizedBox(width: 14),
                  buildSocialButton(
                    context: context,
                    url: ApiConfig.githubUrl,
                    icon: CupertinoIcons.square_favorites_alt_fill,
                    label: 'GitHub',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── 9. DO'A UNTUK DEVELOPER ──────────────────────────────
  static void showDoa(BuildContext context, bool isDark) {
    final doaList = [
      {
        'title': 'Do\'a Sapu Jagat',
        'source': 'QS. Al-Baqarah: 201',
        'arabic':
            'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
        'latin':
            'Rabbana atina fid-dunya hasanah, wa fil-akhirati hasanah, wa qina \'adhaban-nar',
        'meaning':
            'Ya Tuhan kami, berilah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari azab neraka.',
      },
      {
        'title': 'Do\'a Rezeki Halal',
        'source': 'HR. Tirmidzi',
        'arabic':
            'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
        'latin':
            'Allahummakfini bi halalika \'an haramika, wa aghnini bi fadhlika \'amman siwaka',
        'meaning':
            'Ya Allah, cukupkanlah aku dengan yang halal dan jauhkanlah aku dari yang haram, dan cukupkanlah aku dengan karunia-Mu dari bergantung pada selain-Mu.',
      },
      {
        'title': 'Do\'a Ilmu Bermanfaat',
        'source': 'HR. Ibnu Majah',
        'arabic':
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
        'latin':
            'Allahumma inni as\'aluka \'ilman nafi\'an, wa rizqan thayyiban, wa \'amalan mutaqabbalan',
        'meaning':
            'Ya Allah, sungguh aku memohon kepada-Mu ilmu yang bermanfaat, rezeki yang baik, dan amal yang diterima.',
      },
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 520,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cupertinoSystemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.heart_fill,
                    size: 18,
                    color: isDark
                        ? AppColors.cupertinoWhite
                        : AppColors.profilePink,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Do\'akan Developer',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.cupertinoWhite
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Do'a untuk kebaikan — semoga berkah 🤲",
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.builder(
                  itemCount: doaList.length,
                  itemBuilder: (context, index) {
                    final doa = doaList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textLight.withValues(alpha: 0.5)
                            : AppColors.studyGreenLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderSubtle
                              : AppColors.accentBgLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  doa['source']!,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                doa['title']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? AppColors.cupertinoWhite
                                      : AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(
                              doa['arabic']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'ScheherazadeNew',
                                fontSize: 20,
                                height: 1.8,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doa['latin']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: isDark
                                  ? AppColors.cupertinoSystemGrey
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doa['meaning']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: isDark
                                  ? AppColors.cupertinoWhite
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
