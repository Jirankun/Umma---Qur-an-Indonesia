/// ============================================================
/// APP STRINGS — Semua teks UI dalam satu tempat
/// ============================================================
/// Gunakan AppStrings.xxx untuk semua teks yang tampil di UI.
/// Memudahkan translasi dan konsistensi bahasa.
/// ============================================================
library;

class AppStrings {
  // ─── APP ─────────────────────────────────────────────────
  static const String appName = 'Umma';
  static const String packageName = 'app.umma.aokaze';

  // ─── QURAN ───────────────────────────────────────────────
  static const String quranTitle = "Al-Qur'an";
  static const String quranTabSurah = 'Surah';
  static const String quranTabJuz = 'Juz';
  static const String quranSearchSurah = 'Cari surah...';
  static const String quranSearchJuz = 'Cari Juz (1-30)...';
  static const String quranSearchBookmark = 'Cari bookmark...';
  static const String quranLastRead = 'TERAKHIR DIBACA';
  static const String quranAudioReady = 'Audio siap offline ✓';
  static const String quranDownloading = 'Mengunduh audio...';
  static const String quranDownloadAll = 'Download Semua Surah';
  static const String quranDownloadedAll = 'Semua surah tersimpan';
  static const String quranWaitingInternet = 'Menunggu internet...';
  static const String quranRetry = 'Coba Lagi';
  static const String quranNoBookmark = 'Belum ada ayat yang di-bookmark';
  static const String quranBookmarkHint =
      'Tap icon bookmark di setiap ayat untuk menyimpan';
  static const String quranBookmarkNotFound = 'Bookmark tidak ditemukan';
  static const String quranSearchHint = 'Coba kata kunci lain';
  static const String quranBookmarkCount = 'tersimpan';
  static const String quranFilterAll = 'Semua Surah';
  static const String quranFilterBookmark = 'Bookmark';
  static const String quranSettings = 'Pengaturan Baca';
  static const String quranSettingArab = 'Teks Arab';
  static const String quranSettingLatin = 'Teks Latin';
  static const String quranSettingTerjemahan = 'Terjemahan';
  static const String quranSettingHafalan = 'Mode Hafalan';
  static const String quranSettingFontSize = 'Ukuran Arab';
  static const String quranSelectQari = 'Pilih Qari';
  static const String quranAudio = 'Audio';
  static const String quranTafsir = 'TAFSIR';
  static const String quranTafsirNotAvailable = 'Tafsir tidak tersedia';
  static const String quranSaving = 'Batas Bacaan Disimpan';
  static const String quranKhatam = "Alhamdulillah, Khatam! 🎉";
  static const String quranKhatamDesc =
      "MasyaAllah, kamu telah menyelesaikan bacaan seluruh Al-Qur'an.";
  static const String quranSessionSaved = 'Posisi bacaan terakhir sudah disimpan.';
  static const String quranErrorLoad = 'Gagal Memuat';
  static const String quranErrorNoInternet = 'Internet Tidak Tersedia';
  static const String quranErrorNoInternetDesc =
      'Aktifkan internet untuk memuat Surah';

  // ─── HADITS ──────────────────────────────────────────────
  static const String haditsTitle = 'Hadits';
  static const String haditsArbainTitle = "Hadits Arba'in";
  static const String haditsFilterAll = 'Semua';
  static const String haditsFilterBookmark = 'Bookmark';
  static const String haditsSaved = 'tersimpan';
  static const String haditsNoBookmark = 'Belum ada hadits yang di-bookmark';

  // ─── DOA ─────────────────────────────────────────────────
  static const String doaTitle = 'Doa';
  static const String doaBookmark = 'Bookmark Doa';
  static const String doaCustom = 'Doa Saya';

  // ─── ZAKAT ───────────────────────────────────────────────
  static const String zakatTitle = 'Zakat';

  // ─── FIQIH ───────────────────────────────────────────────
  static const String fiqihTitle = 'Fiqih';

  // ─── HAID ────────────────────────────────────────────────
  static const String haidTitle = 'Tracker Haid';

  // ─── TASBIH ──────────────────────────────────────────────
  static const String tasbihTitle = 'Tasbih';

  // ─── JURNAL ──────────────────────────────────────────────
  static const String jurnalTitle = 'Jurnal';

  // ─── TRACKER ─────────────────────────────────────────────
  static const String trackerTitle = 'Tracker';

  // ─── KOMPAS ──────────────────────────────────────────────
  static const String kompasTitle = 'Kiblat';
  static const String kompasNoGps = 'Lokasi tidak aktif. Aktifkan GPS untuk arah kiblat akurat.';
  static const String kompasNoPermission = 'Izin lokasi ditolak. Beri izin untuk arah kiblat akurat.';
  static const String kompasNoPermissionPermanent =
      'Izin lokasi ditolak permanen. Aktifkan dari pengaturan.';

  // ─── MUSLIM AI ───────────────────────────────────────────
  static const String aiTitle = 'Muslim AI';
  static const String aiGreeting = 'Assalamu\'alaikum! Ada yang bisa saya bantu tentang Islam?';

  // ─── USER ────────────────────────────────────────────────
  static const String userProfile = 'Profil';
  static const String userSettings = 'Pengaturan';

  // ─── COMMON ──────────────────────────────────────────────
  static const String loading = 'Memuat...';
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String done = 'Selesai';
  static const String retry = 'Coba Lagi';
  static const String search = 'Cari';
  static const String noData = 'Tidak ada data';
  static const String noInternet = 'Tidak ada koneksi internet';
  static const String bookmark = 'Bookmark';
  static const String bookmarks = 'Bookmark';
  static const String emptyBookmark = 'Belum ada bookmark';
  static const String errorGeneral = 'Terjadi kesalahan';
  static const String errorNetwork = 'Gagal memuat data. Periksa koneksi internet.';

  // ─── PRAYER TIMES ────────────────────────────────────────
  static const String prayerImsak = 'Imsak';
  static const String prayerSubuh = 'Subuh';
  static const String prayerDzuhur = 'Dzuhur';
  static const String prayerAshar = 'Ashar';
  static const String prayerMaghrib = 'Maghrib';
  static const String prayerIsya = 'Isya';
  static const List<String> prayerNames = [
    prayerImsak,
    prayerSubuh,
    prayerDzuhur,
    prayerAshar,
    prayerMaghrib,
    prayerIsya,
  ];
}
