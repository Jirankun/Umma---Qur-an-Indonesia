/// ============================================================
/// APP COLORS — Semua warna aplikasi dalam satu tempat
/// ============================================================
/// Gunakan AppColors.xxx daripada inline Color(0xFF...)
/// agar konsisten dan mudah diubah tema gelap/terang nantinya.
/// ============================================================
library;

import 'package:flutter/cupertino.dart';

class AppColors {
  // ─── BACKGROUND ─────────────────────────────────────────
  static const Color bgDark = Color(0xFF020617);
  static const Color bgLight = Color(0xFFF6F9FC);

  // ─── SURFACE / CARD ─────────────────────────────────────
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceLight = CupertinoColors.white;

  // ─── NAVBAR ─────────────────────────────────────────────
  static const Color navbarDark = Color(0xFF0F172A);
  static const Color navbarLight = CupertinoColors.systemBackground;

  // ─── BORDER ─────────────────────────────────────────────
  static const Color borderDark = Color(0xFF1E293B);
  static const Color borderSubtle = Color(0xFF334155);
  static const Color borderLight = CupertinoColors.systemGrey6;

  // ─── TEXT ───────────────────────────────────────────────
  static const Color textDark = CupertinoColors.white;
  static const Color textLight = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textSubtle = Color(0xFF64748B);
  static const Color textMuted = CupertinoColors.systemGrey;
  static const Color textOnPrimary = CupertinoColors.white;
  static const Color textOnDark = Color(0xFFF1F5F9);

  // ─── PRIMARY (Navy/Blue) ────────────────────────────────
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF312E81);
  static const Color primarySurface = Color(0xFF1E3A8A);
  static const Color primarySurfaceLight = Color(0xFFDBEAFE);
  static const Color primaryLight = Color(0xFFE0E7FF);

  // ─── ACCENT / SUCCESS (Emerald Green) ───────────────────
  static const Color accent = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentSurface = Color(0xFF059669);
  static const Color accentBgLight = Color(0xFFD1FAE5);
  static const Color accentBgDark = Color(0xFF064E3B);

  // ─── WARNING (Amber/Orange) ─────────────────────────────
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningBgLight = Color(0xFFFEF3C7);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFFDE68A);
  static const Color warningTextDark = Color(0xFF92400E);

  // ─── ERROR / DANGER ─────────────────────────────────────
  static const Color error = Color(0xFFE11D48);
  static const Color errorSurface = Color(0xFFE11D48);

  // ─── ZAKAT (Gold) ───────────────────────────────────────
  static const Color zakat = Color(0xFFCA8A04);
  static const Color zakatDark = Color(0xFFB45309);

  // ─── DOA (Pink/Red) ────────────────────────────────────
  static const Color doa = Color(0xFFE11D48);

  // ─── HADITS (Green) ─────────────────────────────────────
  static const Color hadits = Color(0xFF059669);

  // ─── SEARCH HIGHLIGHT ───────────────────────────────────
  /// Warna highlight untuk teks yang cocok dengan pencarian
  /// Light: kuning hangat, Dark: kuning gelap (kontras di kedua tema)
  static const Color searchHighlight = Color(0xFFFDE047);   // kuning terang
  static const Color searchHighlightText = Color(0xFF1E293B); // teks gelap di atas highlight

  // ─── FIQIH CATEGORY COLORS ──────────────────────────────
  static const Color fiqihThaharah = Color(0xFF0284C7);
  static const Color fiqihSholat = Color(0xFF2563EB);
  static const Color fiqihPuasa = Color(0xFF059669);
  static const Color fiqihZakat = Color(0xFFD97706);
  static const Color fiqihHaid = Color(0xFFDB2777);
  static const Color fiqihJenazah = Color(0xFF64748B);
  static const Color fiqihDoa = Color(0xFF7C3AED);
  static const Color fiqihAmalan = Color(0xFF0891B2);
  static const Color fiqihMuamalah = Color(0xFF059669);
  static const Color fiqihNikah = Color(0xFFEC4899);
  static const Color fiqihKurban = Color(0xFFB45309);
  static const Color fiqihAdab = Color(0xFF8B5CF6);

  // ─── TOOL ICON COLORS ───────────────────────────────────
  static const Color toolIndigo = Color(0xFF6366F1);
  static const Color toolPurple = Color(0xFF9333EA);
  static const Color toolOrange = Color(0xFFF97316);
  static const Color toolCyan = Color(0xFF0891B2);
  static const Color toolPink = Color(0xFFDB2777);
  static const Color toolTeal = Color(0xFF10B981);

  // ─── USER PROFILE ICON COLORS ───────────────────────────
  static const Color profileBlue = Color(0xFF3B82F6);
  static const Color profileTeal = Color(0xFF14B8A6);
  static const Color profilePink = Color(0xFFEC4899);
  static const Color profileIndigo = Color(0xFF6366F1);
  static const Color profileViolet = Color(0xFF8B5CF6);
  static const Color profileGradientStart = Color(0xFF818CF8);

  // ─── JOURNAL ────────────────────────────────────────────
  static const Color journalCyan = Color(0xFF0891B2);
  static const Color journalBlue = Color(0xFF1E3A8A);
  static const Color journalGreen = Color(0xFF059669);
  static const Color journalRed = Color(0xFFE11D48);
  static const Color journalYellow = Color(0xFFD97706);

  // ─── HEATMAP ────────────────────────────────────────────
  static const Color heatEmpty = CupertinoColors.systemGrey6;
  static const Color heat1 = Color(0xFF6EE7B7);
  static const Color heat2 = Color(0xFF34D399);
  static const Color heat3 = Color(0xFF10B981);
  static const Color heat4 = Color(0xFF059669);

  // ─── QUEST CARD ─────────────────────────────────────────
  static const Color questBgDark = Color(0xFF1C1917);
  static const Color questAccent = Color(0xFFFCD34D);
  static const Color questTextDark = Color(0xFF92400E);

  // ─── SHARED HELPERS ─────────────────────────────────────
  /// Ambil warna background sesuai tema
  static Color background(bool isDark) => isDark ? bgDark : bgLight;

  /// Ambil warna surface/card sesuai tema
  static Color surface(bool isDark) => isDark ? surfaceDark : surfaceLight;

  /// Ambil warna border sesuai tema
  static Color border(bool isDark) => isDark ? borderDark : borderLight;

  /// Ambil warna text utama sesuai tema
  static Color text(bool isDark) => isDark ? textDark : textLight;

  /// Ambil warna navbar sesuai tema
  static Color navbar(bool isDark) => isDark ? navbarDark : navbarLight;

  /// Primary color dengan alpha
  static Color primaryWithAlpha(double alpha) =>
      primary.withValues(alpha: alpha);

  /// Accent color dengan alpha
  static Color accentWithAlpha(double alpha) =>
      accent.withValues(alpha: alpha);

  /// Warning color dengan alpha
  static Color warningWithAlpha(double alpha) =>
      warning.withValues(alpha: alpha);

  /// Error color dengan alpha
  static Color errorWithAlpha(double alpha) =>
      error.withValues(alpha: alpha);

  // ─── SPECIALTY COLORS ────────────────────────────────────
  /// Dark pink untuk Haid tracker
  static const Color haidDark = Color(0xFFBE185D);
  /// Light purple untuk Tasbih ripple (dark bg)
  static const Color tasbihPurpleLight = Color(0xFFC084FC);
  /// Very light purple untuk Tasbih highlight
  static const Color tasbihPurpleHighlight = Color(0xFFE9D5FF);
  /// Light blue-gray untuk Tasbih bg light
  static const Color tasbihBgLight = Color(0xFFF0F5FA);
  /// Light pink untuk Haid bg light
  static const Color haidBgLight = Color(0xFFFDF2F8);
  /// Off-white untuk Jurnal bg light
  static const Color jurnalBgLight = Color(0xFFFAFAF7);
  /// Orange gelap untuk Tracker gradient
  static const Color trackerOrangeDark = Color(0xFFEA580C);
}
