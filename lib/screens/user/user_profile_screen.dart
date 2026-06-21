import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/ai_config.dart';
import '../../config/api_config.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/background_sound_provider.dart';
import '../../providers/tracker_provider.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/quran_provider.dart';
import '../../providers/doa_provider.dart';
import '../../providers/hadits_provider.dart';
import '../../providers/fiqih_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/zakat_provider.dart';
import '../../providers/haid_provider.dart';
import '../../providers/tasbih_provider.dart';
import '../../providers/muslim_ai_provider.dart';
import '../../providers/update_provider.dart';
import '../../services/local_storage.dart';
import '../home/widgets/update_popup.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadProfile();
    });
  }

  // ─── UTILITIES ──────────────────────────────────────────────
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        _showToast('Gagal membuka link');
      }
    }
  }

  void _checkUpdateManually(bool isDark) {
    final provider = context.read<UpdateProvider>();
    if (provider.status == UpdateStatus.checking) return;
    // Mulai cek update — dialog akan mendengarkan perubahan status provider
    provider.checkForUpdate();
    showUpdateCheckPopup(context, provider);
  }

  // ─── BUILD ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.profile;

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
              CupertinoIcons.person_fill,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(AppStrings.userProfile),
          ],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildProfileCard(isDark, profile, userProvider),
            const SizedBox(height: 24),
            _buildPreferensiSection(isDark),
            const SizedBox(height: 24),
            _buildBantuanSection(isDark),
            const SizedBox(height: 40),
            const Text(
              'Umma v1.0.1',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PROFILE CARD ───────────────────────────────────────────
  Widget _buildProfileCard(
    bool isDark,
    dynamic profile,
    UserProvider userProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.textLight
              : CupertinoColors.systemGrey6,
        ),
      ),
      child: Row(
        children: [
          // Avatar — tap to change photo
          GestureDetector(
            onTap: () => _pickAvatar(isDark, userProvider),
            child: Stack(
              children: [
                _buildAvatar(profile),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 12,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info — tap to edit
          Expanded(
            child: GestureDetector(
              onTap: () => _showEditProfile(isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile?.username ?? 'Hamba Allah',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? CupertinoColors.white
                                : AppColors.textLight,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          CupertinoIcons.pen,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.location_fill,
                        size: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile?.locationCity ?? 'Jakarta',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PREFERENSI APLIKASI ────────────────────────────────────
  Widget _buildPreferensiSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'PREFERENSI APLIKASI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.textLight
                  : CupertinoColors.systemGrey6,
            ),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.moon_fill,
                iconBg: AppColors.profileViolet.withValues(alpha: 0.1),
                iconColor: AppColors.profileViolet,
                title: 'Tema Aplikasi',
                subtitle: isDark ? 'Gelap' : 'Terang',
                trailing: CupertinoSwitch(
                  value: isDark,
                  onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
                ),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.music_note,
                iconBg: AppColors.toolTeal.withValues(alpha: 0.1),
                iconColor: AppColors.heat4,
                title: 'Background Sound',
                subtitle: 'Suasana latar di Beranda',
                trailing: Consumer<BackgroundSoundProvider>(
                  builder: (context, bgSound, _) => CupertinoSwitch(
                    value: bgSound.isEnabled,
                    onChanged: (_) => bgSound.toggle(),
                  ),
                ),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.sparkles,
                iconBg: AppColors.toolIndigo.withValues(alpha: 0.1),
                iconColor: AppColors.toolIndigo,
                title: 'Pengaturan AI Chat',
                subtitle: 'API key Groq untuk Muslim AI Chat',
                onTap: () => _showAiSettings(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.arrow_2_circlepath,
                iconBg: AppColors.profileViolet.withValues(alpha: 0.1),
                iconColor: AppColors.profileViolet,
                title: 'Sync P2P (QR)',
                subtitle: 'Kirim data via QR Code',
                onTap: () => Navigator.of(context).pushNamed('/sync-p2p'),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.cloud_fill,
                iconBg: AppColors.profileBlue.withValues(alpha: 0.1),
                iconColor: AppColors.profileBlue,
                title: 'Manajemen Data',
                subtitle: 'Backup & Restore',
                onTap: () => _showDataManagement(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.refresh_circled,
                iconBg: CupertinoColors.systemRed.withValues(alpha: 0.1),
                iconColor: CupertinoColors.systemRed,
                title: 'Reset Semua Data',
                subtitle: 'Hapus semua progres',
                onTap: () => _showResetConfirm(isDark),
                showBorder: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── BANTUAN & INFO ─────────────────────────────────────────
  Widget _buildBantuanSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'BANTUAN & INFO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.textLight
                  : CupertinoColors.systemGrey6,
            ),
          ),
          child: Column(
            children: [
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.question_circle_fill,
                iconBg: AppColors.profileBlue.withValues(alpha: 0.1),
                iconColor: AppColors.profileBlue,
                title: 'Bantuan & FAQ',
                onTap: () => _showBantuan(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.shield_fill,
                iconBg: AppColors.toolTeal.withValues(alpha: 0.1),
                iconColor: AppColors.toolTeal,
                title: 'Kebijakan Privasi',
                onTap: () => _showPrivasi(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.info_circle_fill,
                iconBg: AppColors.profileViolet.withValues(alpha: 0.1),
                iconColor: AppColors.profileViolet,
                title: 'Tentang Umma',
                subtitle: 'v1.0.1',
                onTap: () => _showTentang(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.person_fill,
                iconBg: AppColors.toolIndigo.withValues(alpha: 0.1),
                iconColor: AppColors.toolIndigo,
                title: 'Pengembang Aplikasi',
                onTap: () => _showPengembang(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.envelope_fill,
                iconBg: AppColors.profileTeal.withValues(alpha: 0.1),
                iconColor: AppColors.profileTeal,
                title: 'Kirim Feedback',
                onTap: () => _openUrl(
                  'https://docs.google.com/forms/d/e/1FAIpQLSdTpzOUsnhjCublNZG-0XRPBnBRkpnDPhyNsgYNbyX0Qidiug/viewform?usp=dialog',
                ),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.cloud_download_fill,
                iconBg: AppColors.heat4.withValues(alpha: 0.1),
                iconColor: AppColors.heat4,
                title: 'Cek Update Aplikasi',
                subtitle: 'v1.0.1 — ketuk untuk periksa',
                onTap: () => _checkUpdateManually(isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.square_favorites_alt_fill,
                iconBg: AppColors.primary.withValues(alpha: 0.1),
                iconColor: AppColors.primary,
                title: 'GitHub Repository',
                subtitle: 'Buka halaman proyek',
                onTap: () => _openUrl('https://github.com/Jirankun/Umma---Qur-an-Indonesia'),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.heart_fill,
                iconBg: AppColors.profilePink.withValues(alpha: 0.1),
                iconColor: AppColors.profilePink,
                title: 'Do\'akan Developer',
                onTap: () => _showDoa(isDark),
                showBorder: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── MENU ITEM ──────────────────────────────────────────────
  Widget _buildMenuItem({
    required bool isDark,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool showBorder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: showBorder
              ? Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.systemGrey6,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? CupertinoColors.white
                          : AppColors.textLight,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(
                        CupertinoIcons.chevron_forward,
                        size: 14,
                        color: CupertinoColors.systemGrey,
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  DRAWERS / BOTTOM SHEETS
  // ═══════════════════════════════════════════════════════════

  // ─── 1. EDIT PROFILE ────────────────────────────────────────
  void _showEditProfile(bool isDark) {
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
                : CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                      color: CupertinoColors.systemGrey4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Edit Profil',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Username',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Masukkan nama',
                  padding: const EdgeInsets.all(12),
                  style: TextStyle(
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                    fontSize: 14,
                  ),
                  placeholderStyle: TextStyle(
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey2,
                    fontSize: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.textLight
                        : CupertinoColors.tertiarySystemBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kota',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 6),
                CupertinoSearchTextField(
                  placeholder: 'Cari kota...',
                  onChanged: (v) =>
                      setSheetState(() => searchCity = v.toLowerCase()),
                  onSuffixTap: () => setSheetState(() {
                    searchCity = '';
                  }),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildCitySearchResult(cities, searchCity, selectedCity, isDark, (city) {
                    setSheetState(() => selectedCity = city);
                  }),
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
                    context.read<PrayerTimesProvider>().fetchPrayerTimes(
                      city: selectedCity,
                    );
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

  // ─── 1B. PENGATURAN AI ────────────────────────────────────
  void _showAiSettings(bool isDark) {
    final keyController = TextEditingController(text: AiConfig.groqApiKey);
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
                  : CupertinoColors.systemBackground,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
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
                        color: CupertinoColors.systemGrey4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.sparkles,
                        size: 18,
                        color: AppColors.toolIndigo,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Pengaturan AI',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Masukkan API key Groq pribadi Anda untuk mengaktifkan Muslim AI Chat.\n\nKonten AI lainnya (quotes, nasehat, quest) sudah aktif secara default.\n\nDapatkan API key gratis di console.groq.com',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: CupertinoColors.systemGrey,
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
                          ? CupertinoColors.white
                          : AppColors.textLight,
                      fontSize: 13,
                      fontFamily: 'monospace',
                    ),
                    placeholderStyle: TextStyle(
                      color: isDark
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
                      fontSize: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.textLight
                          : CupertinoColors.tertiarySystemBackground,
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
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openUrl(
                      'https://console.groq.com/keys',
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.link,
                          size: 12,
                          color: AppColors.toolIndigo,
                        ),
                        const SizedBox(width: 4),
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
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showToast('API key berhasil dihapus');
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
                              _showToast('Masukkan API key terlebih dahulu');
                              return;
                            }
                            AiConfig.groqApiKey = key;
                            final storage = LocalStorage();
                            await storage.setString(
                              ApiConfig.storageKeyGroqApiKey,
                              key,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showToast('✅ API key berhasil disimpan');
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

  // ─── 2. MANAJEMEN DATA ─────────────────────────────────────
  Future<void> _showDataManagement(bool isDark) async {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
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
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey,
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
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
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
                          await _exportData();
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
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey,
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
                          await _importData();
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

  Future<void> _exportData() async {
    try {
      final exportData = await LocalStorage().collectAllExportData();
      final jsonStr = jsonEncode(exportData);
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/umma_backup.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Backup Data Umma'),
      );

      if (mounted) {
        _showToast('Backup berhasil dibuat!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Gagal export data: $e');
      }
    }
  }

  Future<void> _importData() async {
    try {
      // Use file_picker to let user select a backup file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return; // user cancelled

      final filePath = result.files.single.path;
      if (filePath == null) {
        if (mounted) _showToast('Gagal membaca file');
        return;
      }

      _showToast('Memulihkan data...');

      final file = File(filePath);
      final content = await file.readAsString();

      // Support dual format:
      // 1. Raw JSON (starts with '{')
      // 2. Base64-encoded gzipped JSON (from QR scan)
      Map<String, dynamic> data;

      if (content.trim().startsWith('{')) {
        // Format 1: Raw JSON
        data = jsonDecode(content) as Map<String, dynamic>;
      } else {
        // Format 2: Base64 → gzip → JSON (QR format)
        try {
          final gzipped = base64Decode(content.trim());
          final jsonBytes = gzip.decode(gzipped);
          final jsonStr = utf8.decode(jsonBytes);
          data = jsonDecode(jsonStr) as Map<String, dynamic>;
        } catch (_) {
          if (mounted) {
            _showToast('Format file tidak dikenal');
          }
          return;
        }
      }

      final restored = await LocalStorage().restoreFromExport(data);

      if (mounted) {
        // Theme
        final themeStr = LocalStorage().getString(ApiConfig.storageKeyTheme);
        if (themeStr != null) {
          context.read<ThemeProvider>().loadTheme(themeStr);
        }

        // User profile
        context.read<UserProvider>().loadProfile();

        // Tracker, Quran, Doa, Hadits, Fiqih, Jurnal
        context.read<TrackerProvider>().loadTrackers();
        context.read<QuranProvider>().loadStoredData();
        context.read<DoaProvider>().loadData();
        context.read<HaditsProvider>().loadBooks();
        context.read<FiqihProvider>().loadContent();
        context.read<JournalProvider>().loadJournals();

        // Settings
        context.read<ZakatProvider>().loadSavedSettings();
        context.read<HaidProvider>().loadData();
        context.read<TasbihProvider>().loadSettings();

        // Muslim AI
        context.read<MuslimAiProvider>().loadCooldown();

        // Background sound
        context.read<BackgroundSoundProvider>().loadSettings();

        // Prayer times
        final userProvider = context.read<UserProvider>();
        final currentCity = userProvider.profile?.locationCity;
        if (currentCity != null) {
          context.read<PrayerTimesProvider>().fetchPrayerTimes(
            city: currentCity,
          );
        }

        // Groq API key runtime
        final groqKey = LocalStorage().getString(ApiConfig.storageKeyGroqApiKey);
        if (groqKey != null && groqKey.isNotEmpty) {
          AiConfig.groqApiKey = groqKey;
        }

        _showToast('✅ $restored data berhasil dipulihkan!');
      }
    } catch (e) {
      if (mounted) {
        _showToast('Gagal import data: $e');
      }
    }
  }

  // ─── 3. RESET SEMUA DATA ───────────────────────────────────
  void _showResetConfirm(bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              const SizedBox(height: 20),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.trash_fill,
                  size: 28,
                  color: CupertinoColors.systemRed,
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
                  color: CupertinoColors.systemGrey,
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
                        await LocalStorage().clearAll();      if (mounted) {
          context.read<TrackerProvider>().loadTrackers();
          context.read<QuranProvider>().loadStoredData();
          context.read<DoaProvider>().loadData();
          context.read<HaditsProvider>().loadBooks();
          context.read<FiqihProvider>().loadContent();
          context.read<JournalProvider>().loadJournals();
          context.read<ZakatProvider>().loadSavedSettings();
          context.read<HaidProvider>().loadData();
          context.read<TasbihProvider>().loadSettings();
          _showToast('Semua data berhasil direset');
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

  // ─── 4. BANTUAN & FAQ ──────────────────────────────────────
  void _showBantuan(bool isDark) {
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
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
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
                            : CupertinoColors.tertiarySystemBackground,
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
                                  ? CupertinoColors.white
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
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey,
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

  // ─── 5. KEBIJAKAN PRIVASI ──────────────────────────────────
  void _showPrivasi(bool isDark) {
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
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
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
                  color: CupertinoColors.systemGrey,
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
                                        ? CupertinoColors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
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

  // ─── 6. TENTANG UMMA ──────────────────────────────────────
  void _showTentang(bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 420,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
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
                  color: CupertinoColors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Umma',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.systemGrey,
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
                          ? CupertinoColors.white
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

  // ─── 7. PENGEMBANG APLIKASI ────────────────────────────────
  void _showPengembang(bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 360,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Foto dari GitHub dengan fallback
              ClipOval(
                child: Image.network(
                  'https://www.github.com/jirankun.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.indigoLight, AppColors.toolIndigo],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      size: 32,
                      color: CupertinoColors.white,
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
                      ? CupertinoColors.white
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
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    url: 'https://jirankun.github.io/portofoliozhyllan',
                    icon: CupertinoIcons.link,
                    label: 'Portofolio',
                  ),
                  const SizedBox(width: 14),
                  _buildSocialButton(
                    url: 'https://www.github.com/jirankun',
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

  Widget _buildSocialButton({
    required String url,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: () => _openUrl(url),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── AVATAR ───────────────────────────────────────────────────
  Widget _buildAvatar(dynamic profile) {
    final avatarUrl = profile?.avatarUrl as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        final bytes = base64Decode(avatarUrl);
        return ClipOval(
          child: Image.memory(
            Uint8List.fromList(bytes),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {
        // Fallback ke gradient jika decode gagal
      }
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        CupertinoIcons.person_fill,
        size: 36,
        color: CupertinoColors.white,
      ),
    );
  }

  Future<void> _pickAvatar(bool isDark, UserProvider userProvider) async {
    final action = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) => Container(
        height: userProvider.profile?.avatarUrl != null &&
                userProvider.profile!.avatarUrl!.isNotEmpty
            ? 240
            : 200,
        decoration: BoxDecoration(
          color: isDark
                ? AppColors.surfaceDark
                : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CupertinoButton(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.photo_fill),
                    SizedBox(width: 8),
                    Text(AppStrings.pilihGaleri),
                  ],
                ),
                onPressed: () => Navigator.pop(ctx, 'gallery'),
              ),
              CupertinoButton(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera_fill),
                    SizedBox(width: 8),
                    Text(AppStrings.ambilFoto),
                  ],
                ),
                onPressed: () => Navigator.pop(ctx, 'camera'),
              ),
              if (userProvider.profile?.avatarUrl != null &&
                  userProvider.profile!.avatarUrl!.isNotEmpty)
                CupertinoButton(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.trash_fill, color: CupertinoColors.systemRed),
                      SizedBox(width: 8),
                      Text(AppStrings.hapusFoto, style: TextStyle(color: CupertinoColors.systemRed)),
                    ],
                  ),
                  onPressed: () => Navigator.pop(ctx, 'delete'),
                ),
            ],
          ),
        ),
      ),
    );

    if (action == null) {
      // User dismisses the modal — do nothing
      return;
    }

    if (action == 'delete') {
      final profile = userProvider.profile;
      if (profile != null) {
        profile.avatarUrl = null;
        await userProvider.saveProfile(profile);
        _showToast('Foto profil dihapus');
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      _showToast('Memproses foto...');

      final bytes = await pickedFile.readAsBytes();
      final base64Str = base64Encode(bytes);

      final profile = userProvider.profile;
      if (profile != null) {
        profile.avatarUrl = base64Str;
        await userProvider.saveProfile(profile);
        _showToast('✅ Foto profil diperbarui');
      }
    } catch (e) {
      _showToast('Gagal memproses foto: $e');
    }
  }

  // ─── CITY SEARCH HELPER ─────────────────────────────────────
  Widget _buildCitySearchResult(
    List<String> cities,
    String searchCity,
    String selectedCity,
    bool isDark,
    void Function(String) onSelect,
  ) {
    final filtered = searchCity.isEmpty
        ? cities
        : cities.where((c) => c.toLowerCase().contains(searchCity)).toList();

    if (filtered.isEmpty && searchCity.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 40,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ditemukan kota untuk "$searchCity"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final isSelected = filtered[index] == selectedCity;
        return GestureDetector(
          onTap: () => onSelect(filtered[index]),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.location_fill,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  filtered[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? CupertinoColors.white
                        : AppColors.textLight,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── 9. DO'A SAJA ──────────────────────────────────────────
  void _showDoa(bool isDark) {
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
              : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                    color: CupertinoColors.systemGrey4,
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
                        ? CupertinoColors.white
                        : AppColors.profilePink,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Do\'akan Developer',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? CupertinoColors.white
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
                  color: CupertinoColors.systemGrey,
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
                                  color:AppColors.accent.withValues(alpha: 0.1),
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
                                      ? CupertinoColors.white
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
                                  ? CupertinoColors.systemGrey
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
                                  ? CupertinoColors.white
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

  // ─── TOAST ──────────────────────────────────────────────────
  /// Show a floating overlay toast — tidak pakai showCupertinoModalPopup
  /// agar tidak bentrok dengan route transition yang sedang berlangsung.
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
