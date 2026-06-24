import 'package:flutter/cupertino.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import 'package:provider/provider.dart';
import '../../config/api_config.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/background_sound_provider.dart';
import '../../providers/update_provider.dart';
import '../home/widgets/update_popup.dart';
import 'widgets/profile_helpers.dart';
import 'widgets/profile_dialogs.dart';

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

  void _checkUpdateManually() {
    final provider = context.read<UpdateProvider>();
    if (provider.status == UpdateStatus.checking) return;
    provider.checkForUpdate();
    showUpdateCheckPopup(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.profile;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.cupertinoSystemBackground,
        middle: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.person_fill, size: 18, color: AppColors.primary),
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
            Text(
              AppStrings.appVersionDisplay,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.cupertinoSystemGrey,
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
        color: isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.textLight : AppColors.cupertinoSystemGrey6,
        ),
      ),
      child: Row(
        children: [
          // Avatar — tap to change photo
          GestureDetector(
            onTap: () => pickAvatar(context, isDark, userProvider),
            child: Stack(
              children: [
                buildAvatar(profile),
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
                        color: isDark
                            ? AppColors.surfaceDark
                            : AppColors.cupertinoWhite,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 12,
                      color: AppColors.cupertinoWhite,
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
              onTap: () => ProfileDialogs.showEditProfile(context, isDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile?.username ?? AppStrings.userDefaultName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.cupertinoWhite
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
                        color: AppColors.cupertinoSystemGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        profile?.locationCity ?? AppStrings.userDefaultCity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.cupertinoSystemGrey,
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
            AppStrings.userPreferensi,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark
                  ? AppColors.cupertinoSystemGrey
                  : AppColors.cupertinoSystemGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.textLight : AppColors.cupertinoSystemGrey6,
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
                subtitle: isDark ? AppStrings.userThemeDark : AppStrings.userThemeLight,
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
                onTap: () => ProfileDialogs.showAiSettings(context, isDark),
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
                onTap: () => ProfileDialogs.showDataManagement(context, isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.refresh_circled,
                iconBg: CupertinoColors.systemRed.withValues(alpha: 0.1),
                iconColor: CupertinoColors.systemRed,
                title: 'Reset Semua Data',
                subtitle: 'Hapus semua progres',
                onTap: () => ProfileDialogs.showResetConfirm(context, isDark),
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
            AppStrings.userBantuan,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: isDark
                  ? AppColors.cupertinoSystemGrey
                  : AppColors.cupertinoSystemGrey,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.cupertinoWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.textLight : AppColors.cupertinoSystemGrey6,
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
                onTap: () => ProfileDialogs.showBantuan(context, isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.shield_fill,
                iconBg: AppColors.toolTeal.withValues(alpha: 0.1),
                iconColor: AppColors.toolTeal,
                title: 'Kebijakan Privasi',
                onTap: () => ProfileDialogs.showPrivasi(context, isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.info_circle_fill,
                iconBg: AppColors.profileViolet.withValues(alpha: 0.1),
                iconColor: AppColors.profileViolet,
                title: 'Tentang Umma',
                subtitle: AppStrings.appVersionShort,
                onTap: () => ProfileDialogs.showTentang(context, isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.person_fill,
                iconBg: AppColors.toolIndigo.withValues(alpha: 0.1),
                iconColor: AppColors.toolIndigo,
                title: 'Pengembang Aplikasi',
                onTap: () => ProfileDialogs.showPengembang(context, isDark),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.envelope_fill,
                iconBg: AppColors.profileTeal.withValues(alpha: 0.1),
                iconColor: AppColors.profileTeal,
                title: 'Kirim Feedback',
                onTap: () => openUrl(ApiConfig.feedbackFormUrl, context),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.cloud_download_fill,
                iconBg: AppColors.heat4.withValues(alpha: 0.1),
                iconColor: AppColors.heat4,
                title: 'Cek Update Aplikasi',
                subtitle: '${AppStrings.appVersionShort} — ketuk untuk periksa',
                onTap: () => _checkUpdateManually(),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.square_favorites_alt_fill,
                iconBg: AppColors.primary.withValues(alpha: 0.1),
                iconColor: AppColors.primary,
                title: 'GitHub Repository',
                subtitle: 'Buka halaman proyek',
                onTap: () => openUrl(ApiConfig.githubUrl, context),
                showBorder: true,
              ),
              _buildMenuItem(
                isDark: isDark,
                icon: CupertinoIcons.heart_fill,
                iconBg: AppColors.profilePink.withValues(alpha: 0.1),
                iconColor: AppColors.profilePink,
                title: 'Do\'akan Developer',
                onTap: () => ProfileDialogs.showDoa(context, isDark),
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
                        : AppColors.cupertinoSystemGrey6,
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
                          ? AppColors.cupertinoWhite
                          : AppColors.textLight,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.cupertinoSystemGrey,
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
                        color: AppColors.cupertinoSystemGrey,
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
