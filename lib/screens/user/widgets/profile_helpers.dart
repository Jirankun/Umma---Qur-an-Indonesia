import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../providers/user_provider.dart';

// ═══════════════════════════════════════════════════════════════
// PROFILE HELPERS — Utility functions untuk User Profile Screen
// ═══════════════════════════════════════════════════════════════

/// Buka URL eksternal
Future<void> openUrl(String url, BuildContext context) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    if (context.mounted) {
      showToast(context, AppStrings.gagalBukaLink);
    }
  }
}

/// Tampilkan overlay toast
void showToast(BuildContext context, String message) {
  if (!context.mounted) return;
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
            color: AppColors.cupertinoWhite,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () {
    if (context.mounted) entry.remove();
  });
}

/// Bangun widget avatar
Widget buildAvatar(dynamic profile) {
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
      // Fallback gradient jika decode gagal
    }
  }
  return Container(
    width: 72,
    height: 72,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      CupertinoIcons.person_fill,
      size: 36,
      color: AppColors.cupertinoWhite,
    ),
  );
}

/// Pilih avatar (gallery / camera / delete)
Future<void> pickAvatar(
  BuildContext context,
  bool isDark,
  UserProvider userProvider,
) async {
  final action = await showCupertinoModalPopup<String>(
    context: context,
    builder: (ctx) => Container(
      height: userProvider.profile?.avatarUrl != null &&
              userProvider.profile!.avatarUrl!.isNotEmpty
          ? 240
          : 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.cupertinoSystemBackground,
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
                  color: AppColors.cupertinoSystemGrey4,
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
                    Icon(CupertinoIcons.trash_fill, color: AppColors.cupertinoSystemRed),
                    SizedBox(width: 8),
                    Text(AppStrings.hapusFoto, style: TextStyle(color: AppColors.cupertinoSystemRed)),
                  ],
                ),
                onPressed: () => Navigator.pop(ctx, 'delete'),
              ),
          ],
        ),
      ),
    ),
  );

  if (action == null) return;

  if (action == 'delete') {
    final profile = userProvider.profile;
    if (profile != null) {
      profile.avatarUrl = null;
      await userProvider.saveProfile(profile);
      if (!context.mounted) return;
      showToast(context, AppStrings.fotoProfilDihapus);
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
      imageQuality: 93,
    );
    if (pickedFile == null) return;

    if (!context.mounted) return;
    showToast(context, AppStrings.fotoProfilDiproses);

    final bytes = await pickedFile.readAsBytes();
    final base64Str = base64Encode(bytes);

    final profile = userProvider.profile;
    if (profile != null) {
      profile.avatarUrl = base64Str;
      await userProvider.saveProfile(profile);
      if (!context.mounted) return;
      showToast(context, AppStrings.fotoProfilDiperbarui);
    }
  } catch (e) {
    if (!context.mounted) return;
    showToast(context, 'Gagal memproses foto: $e');
  }
}

/// Bangun daftar hasil pencarian kota
Widget buildCitySearchResult(
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
            color: AppColors.cupertinoSystemGrey,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ditemukan kota untuk "$searchCity"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.cupertinoSystemGrey
                  : AppColors.cupertinoSystemGrey,
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
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
                  color: isDark ? AppColors.cupertinoWhite : AppColors.textLight,
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

/// Bangun tombol social (Portofolio/GitHub)
Widget buildSocialButton({
  required BuildContext context,
  required String url,
  required IconData icon,
  required String label,
}) {
  return GestureDetector(
    onTap: () => openUrl(url, context),
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
