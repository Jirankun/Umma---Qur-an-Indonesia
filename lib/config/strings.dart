/// ============================================================
/// APP STRINGS — Semua teks UI dalam satu tempat
/// ============================================================
/// Gunakan AppStrings.xxx untuk semua teks yang tampil di UI.
/// Memudahkan translasi dan konsistensi bahasa.
/// ============================================================
library;

import '../utils/app_info.dart';

class AppStrings {
  // ─── APP ─────────────────────────────────────────────────
  static const String appName = 'Umma';
  static const String packageName = 'app.umma.aokaze';

  /// Versi aplikasi — baca dari native build (Gradle) via PackageInfo
  static String get appVersion => AppInfo.version;

  /// Display string: "v1.0.1"
  static String get appVersionShort => 'v${AppInfo.version}';

  /// Display string: "Umma v1.0.1" — single source of truth untuk semua UI
  static String get appVersionDisplay => '$appName v${AppInfo.version}';

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
  static const String quranKhatamPlan = 'Program Khatam';
  static const String quranKhatamDescEmpty = 'Buat target khatam Al-Quran dan pantau progress harianmu.';
  static const String quranJuz = 'Juz';
  static const String quranKhatamStart = 'Mulai Program';
  static const String quranKhatamProgress = 'Progres Khatam';
  static const String quranKhatamResetTitle = 'Reset Program Khatam?';
  static const String quranKhatamResetContent = 'Apakah kamu yakin ingin mereset target khatam?';
  static const String quranFinishRestart = 'Selesai & Mulai Ulang';
  static const String quranRemainingTime = 'Sisa Waktu';
  static const String quranDayCap = 'Hari';
  static const String quranAyatCap = 'Ayat';
  static const String quranStats = 'Statistik Bacaan';
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

  // ─── MURATTAL ────────────────────────────────────────────
  static const String murattalTitle = 'Murattal';
  static const String murattalNowPlaying = 'Sedang Diputar';
  static const String murattalDownloadAll = 'Mengunduh semua audio...';

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

  // ─── HOME ─────────────────────────────────────────────────
  static const String homeTitle = 'Beranda';
  static const String homeGreetingMorning = 'Selamat Pagi';
  static const String homeGreetingAfternoon = 'Selamat Siang';
  static const String homeGreetingEvening = 'Selamat Sore';
  static const String homeGreetingNight = 'Selamat Malam';
  static const String homePrayerSchedule = 'Jadwal Sholat';
  static const String homeToward = 'Menuju';
  static const String homeFailedLoadPrayer = 'Gagal memuat jadwal sholat';
  static const String homeCheckInternet = 'Periksa koneksi internet';
  static const String homeReload = 'Muat Ulang';
  static const String homeToolQuran = "Al-Qur'an";
  static const String homeToolDoa = 'Doa';
  static const String homeToolHadits = 'Hadits';
  static const String homeToolFiqih = 'Fiqih';
  static const String homeToolTasbih = 'Tasbih';
  static const String homeToolKiblat = 'Kiblat';
  static const String homeToolMuslimAi = 'Muslim AI';
  static const String homeToolTracker = 'Tracker';
  static const String homeToolJurnal = 'Jurnal';
  static const String homeToolHaidTracker = 'Haid Tracker';
  static const String homeToolZakat = 'Zakat';
  static const String homeNotificationActive = 'Notif Aktif';
  static const String homeArbainTitle = "Hadits Arba'in";
  static const String homeTargetHarian = 'Target Ibadah Harian';

  // ─── TRACKER ─────────────────────────────────────────────
  static const String trackerTargetHarian = 'Target Harian';
  static const String trackerDashboard = 'Tracker Dashboard';
  static const String trackerPuasa = 'Puasa (Sunah/Wajib)';
  static const String trackerSubuh = 'Sholat Subuh';
  static const String trackerDzuhur = 'Sholat Dzuhur';
  static const String trackerAshar = 'Sholat Ashar';
  static const String trackerMaghrib = 'Sholat Maghrib';
  static const String trackerIsya = 'Sholat Isya';
  static const String trackerTarawih = 'Sholat Tarawih';
  static const String trackerTilawah = "Tilawah Qur'an";
  static const String trackerSedekah = 'Sedekah Harian';
  static const String trackerCountFormat = '{count} dari {total} selesai';
  static const String trackerHariIni = 'Hari Ini';
  static const String trackerHariTerisi = 'Hari Terisi';
  static const String trackerRataRata = 'Rata-rata';
  static const String trackerBacaQuran = 'Baca Quran';
  static const String trackerPuasaLabel = 'Puasa';
  static const String trackerHaidLabel = 'Haid';
  static const String trackerTargetSelesai = 'Target selesai';
  static const String trackerBelumDicatat = 'Belum dicatat';
  static const String trackerCatatHarian = 'Catat Target Harian';
  static const String trackerLihatDetail = 'Lihat Detail';
  static const String trackerSelesai = 'Selesai';
  static const String trackerSebagian = 'Sebagian';
  static const String trackerTerisi = 'Terisi';
  static const String trackerBacaQuranLegend = 'Baca Quran';

  // ─── JURNAL ──────────────────────────────────────────────
  static const String jurnalRefleksi = 'Jurnal Refleksi';
  static const String jurnalKosong = 'Apa yang ada di benakmu hari ini?';
  static const String jurnalBuatBaru = 'Buat catatan baru';
  static const String jurnalTanpaJudul = 'Tanpa Judul';
  static const String jurnalHapusCatatan = 'Hapus Catatan';
  static const String jurnalYakinHapus = 'Yakin ingin menghapus catatan ini?';
  static const String jurnalEditCatatan = 'Edit Catatan';
  static const String jurnalTulis = 'Tulis Jurnal';
  static const String jurnalPerbarui = 'Perbarui';
  static const String jurnalSimpan = 'Simpan';
  static const String jurnalPlaceholderJudul = 'Judul (opsional)';
  static const String jurnalPlaceholderIsi = 'Tulis sesuatu...';
  static const String jurnalRefleksiHarian = 'Refleksi Harian';
  static const String jurnalCatatanSyukur = 'Catatan Syukur';
  static const String jurnalRuangIkhlas = 'Ruang Ikhlas';
  static const String jurnalCatatanBebas = 'Catatan Bebas';
  static const String jurnalFormatCatatan = 'Catatan {category}';

  // ─── FIQIH ───────────────────────────────────────────────
  static const String fiqihIslam = 'Fiqih Islam';
  static const String fiqihPanduan = 'Panduan Fiqih Islam';
  static const String fiqihCari = 'Cari topik fiqih...';
  static const String fiqihKategori = 'Kategori';
  static const String fiqihAll = 'SEMUA MATERI';
  static const String fiqihMateriCountSuffix = 'materi tentang puasa, sholat, zakat, dan lainnya';
  static const String fiqihNotFound = 'Tidak ditemukan topik untuk';

  // ─── HADITS ──────────────────────────────────────────────
  static const String haditsPilihan = 'Hadits Pilihan';
  static const String haditsKitab = 'Kitab';
  static const String haditsKumpulan = 'Kumpulan Hadits';
  static const String haditsKitabDesc = 'Dari berbagai kitab hadits terpercaya';
  static const String haditsSearchKitab = 'Cari kitab hadits...';
  static const String haditsNotFoundKitab = 'Tidak ditemukan kitab untuk';
  static const String haditsNoBookmarkHint = 'Buka kitab hadits, lalu ketuk ikon bookmark di setiap hadits';
  static const String haditsNeedConnection = 'Koneksi diperlukan';
  static const String haditsNeedConnectionDesc = 'Hadits dimuat dari server.\nPastikan terhubung ke internet.';
  static const String haditsSearchHadits = 'Cari hadits (nomor/teks)...';
  static const String haditsNotFound = 'Tidak ditemukan hadits untuk';

  // ─── DOA ─────────────────────────────────────────────────
  static const String doaKumpulan = 'Kumpulan Doa';
  static const String doaKumpulanDanDzikir = 'Kumpulan Doa & Dzikir';
  static const String doaLengkap = 'Lengkap dengan Arab, Latin, dan Artinya';
  static const String doaSearch = 'Cari doa...';
  static const String doaSource = 'Sumber:';
  static const String doaFilterKategori = 'Kategori';
  static const String doaNotFound = 'Tidak ditemukan doa untuk';
  static const String doaBookmarkEmpty = 'Belum ada doa yang tersimpan';
  static const String doaCount = 'doa';
  static const String doaBookmarkHint =
      'Buka kategori doa, lalu ketuk ikon bookmark di setiap doa';

  // ─── ZAKAT ───────────────────────────────────────────────
  static const String zakatKalkulator = 'Kalkulator Zakat';
  static const String zakatFitrah = 'Zakat Fitrah';
  static const String zakatMaal = 'Zakat Maal';
  static const String zakatMaalDesc = 'Harta & tabungan';
  static const String zakatPenghasilan = 'Zakat Penghasilan';
  static const String zakatPenghasilanDesc = 'Gaji bulanan';
  static const String zakatEmas = 'Zakat Emas & Perak';
  static const String zakatEmasDesc = 'Logam mulia';
  static const String zakatRamadhanOnly = 'Zakat akan tersedia\nmenjelang akhir Ramadhan ☪️';
  static const String zakatTagline = 'Tunaikan Zakat, Bersihkan Harta 🤍';
  static const String zakatSubtitle = 'Hitung zakat dengan mudah & akurat';
  static const String zakatNisab = 'Nisab: Rp5.240.000/bulan';
  static const String zakatHitung = 'Hitung Zakat';
  static const String zakatJumlahJiwa = 'Jumlah Jiwa';
  static const String zakatHargaBeras = 'Harga Beras per Kg (Rp)';
  static const String zakatBerasJiwa = 'Beras per Jiwa (kg)';
  static const String zakatOrang = 'Orang';
  static const String zakatTabungan = 'Tabungan (Rp)';
  static const String zakatInvestasi = 'Investasi (Rp)';
  static const String zakatPiutang = 'Piutang (Rp)';
  static const String zakatHutang = 'Hutang (Rp)';
  static const String zakatPenghasilanBulan = 'Penghasilan per Bulan (Rp)';
  static const String zakatPendapatanLain = 'Pendapatan Lain (Rp)';
  static const String zakatCicilan = 'Cicilan (Rp)';
  static const String zakatEmasGram = 'Emas (gram)';
  static const String zakatPerakGram = 'Perak (gram)';
  static const String zakatTotalBeras = 'Total Beras';
  static const String zakatTotalUang = 'Total Uang';
  static const String zakatPerJiwa = 'Per Jiwa';
  static const String zakatTotalHarta = 'Total Harta';
  static const String zakatTotalPendapatan = 'Total Pendapatan';
  static const String zakatNisabLabel = 'Nisab';
  static const String zakatProsen = 'Zakat (2.5%)';
  static const String zakatBelumNisab = 'Belum mencapai nisab, belum wajib zakat.';
  static const String zakatEmasLabel = 'Zakat Emas';
  static const String zakatPerakLabel = 'Zakat Perak';
  static const String zakatEmasNisab = 'Emas belum capai nisab 85 gr.';
  static const String zakatPerakNisab = 'Perak belum capai nisab 595 gr.';

  // ─── TASBIH ──────────────────────────────────────────────
  static const String tasbihDzikirDigital = 'Dzikir Digital';
  static const String tasbihSelesai = 'Dzikir Selesai!';

  // ─── HAID ────────────────────────────────────────────────
  static const String haidTracker = 'Haid Tracker';
  static const String haidSedang = 'Sedang Haid';
  static const String haidDay = 'Hari';
  static const String haidTidak = 'Tidak Haid';
  static const String haidFaseSiklus = 'Fase siklus saat ini';
  static const String haidAkhiri = 'Akhiri Haid';
  static const String haidMulai = 'Mulai Haid';
  static const String haidTotalSiklus = 'Total Siklus';
  static const String haidQadha = 'Qadha Puasa';
  static const String haidRiwayat = 'RIWAYAT';
  static const String haidKosong = 'Belum ada riwayat. Mulai catat siklus haid pertama.';
  static const String haidBerlangsung = 'Sedang berlangsung';
  static const String haidTanggalMulai = 'Tanggal Mulai';
  static const String haidTanggalSelesai = 'Tanggal Selesai';

  // ─── KOMPAS ──────────────────────────────────────────────
  static const String kompasHeading = 'HEADING';
  static const String kompasKiblat = 'KIBLAT';
  static const String kompasSelisih = 'SELISIH';
  static const String kompasMenghadap = '✓ Menghadap Kiblat!';
  static const String kompasMendeteksi = 'Mendeteksi lokasi...';
  static const String kompasGagalLokasi = 'Gagal mendapatkan lokasi';
  static const String kompasKalibrasi = 'Kalibrasi';
  static const String kompasNormal = 'Normal';
  static const String kompasBalik = 'Balik 180°';
  static const String kompasCobaLagi = 'Coba Lagi';

  // ─── MUSLIM AI ───────────────────────────────────────────
  static const String aiMengetik = 'Mengetik...';
  static const String aiKetikPesan = 'Ketik pesan...';
  static const String aiModeNgobrol = 'Ngobrol';
  static const String aiModeDoa = 'Cari Doa';
  static const String aiModeSurah = 'Cari Surah';
  static const String aiModeFiqih = 'Tanya Fiqih';
  static const String aiModeHadits = 'Cari Hadits';
  static const String aiCariGoogle = 'Cari di Google';
  static const String aiBukaBrowser = 'Tidak bisa membuka browser';
  static const String aiLabelSurah = 'Surah';
  static const String aiLabelDoa = 'Doa';
  static const String aiLabelHadits = 'Hadits';
  static const String aiLabelFiqih = 'Fiqih';
  static const String aiLabelZakat = 'Zakat';
  static const String aiLabelTasbih = 'Tasbih';
  static const String aiLabelTracker = 'Tracker';
  static const String aiLabelJurnal = 'Jurnal';
  static const String aiLabelAyat = 'Ayat';
  static const String aiBuka = 'Buka';

  // ─── SYNC ────────────────────────────────────────────────
  static const String syncP2P = 'Sync P2P';
  static const String syncKirim = 'Kirim';
  static const String syncTerima = 'Terima';
  static const String syncSiapkanQR = 'Siapkan QR Code';
  static const String syncMenyiapkan = 'Menyiapkan data...';
  static const String syncBuatUlang = 'Buat Ulang QR';
  static const String syncBagikanFile = 'Bagikan sebagai File';
  static const String syncScan = 'Scan Lagi';
  static const String syncCobaLagi = 'Coba Lagi';
  static const String syncDataTerlaluBesar = 'Data terlalu besar untuk QR Code';
  static const String syncGunakanFile = 'Gunakan opsi Backup File untuk mengirim data.';
  static const String syncPeerInfo = '100% Peer-to-Peer';
  static const String syncPeerDesc = 'Data tidak dikirim ke server';
  static const String syncArahkan = 'Arahkan kamera ke QR Code';

  // ─── STUDY ───────────────────────────────────────────────
  static const String studyTitle = 'Studi Ramadhan';
  static const String studyDay = 'Hari ke-';
  static const String studyOnlyRamadhan = 'Fitur ini hanya tersedia selama bulan Ramadhan.\n\nTunggu kedatangan bulan suci untuk mengakses materi studi harian selama 30 hari.';

  // ─── USER ────────────────────────────────────────────────
  static const String userEditProfile = 'Edit Profil';
  static const String userUsername = 'Username';
  static const String userKota = 'Kota';
  static const String userMasukkanNama = 'Masukkan nama';
  static const String userCariKota = 'Cari kota...';
  static const String userSimpan = 'Simpan Perubahan';
  static const String deleteKey = 'Hapus Key';
  static const String saveKey = 'Simpan Key';
  static const String pilihGaleri = 'Pilih dari Galeri';
  static const String ambilFoto = 'Ambil Foto';
  static const String hapusFoto = 'Hapus Foto';
  static const String fotoProfilDihapus = 'Foto profil dihapus';
  static const String fotoProfilDiproses = 'Memproses foto...';
  static const String fotoProfilDiperbarui = '✅ Foto profil diperbarui';
  static const String gagalBukaLink = 'Gagal membuka link';
  static const String userPreferensi = 'PREFERENSI APLIKASI';
  static const String userBantuan = 'BANTUAN & INFO';
  static const String userDefaultName = 'Hamba Allah';
  static const String userDefaultCity = 'Jakarta';
  static const String userThemeDark = 'Gelap';
  static const String userThemeLight = 'Terang';

  // ─── DATE/MONTH ──────────────────────────────────────────
  static const String monthJanuari = 'Januari';
  static const String monthFebruari = 'Februari';
  static const String monthMaret = 'Maret';
  static const String monthApril = 'April';
  static const String monthMei = 'Mei';
  static const String monthJuni = 'Juni';
  static const String monthJuli = 'Juli';
  static const String monthAgustus = 'Agustus';
  static const String monthSeptember = 'September';
  static const String monthOktober = 'Oktober';
  static const String monthNovember = 'November';
  static const String monthDesember = 'Desember';

  static const String daySenin = 'Senin';
  static const String daySelasa = 'Selasa';
  static const String dayRabu = 'Rabu';
  static const String dayKamis = 'Kamis';
  static const String dayJumat = 'Jumat';
  static const String daySabtu = 'Sabtu';
  static const String dayMinggu = 'Minggu';
  static const String dayMinPendek = 'Min';
  static const String daySenPendek = 'Sen';
  static const String daySelPendek = 'Sel';
  static const String dayRabPendek = 'Rab';
  static const String dayKamPendek = 'Kam';
  static const String dayJumPendek = 'Jum';
  static const String daySabPendek = 'Sab';

  // ─── HOME SCREEN ─────────────────────────────────────────
  /// Label untuk banner lanjut baca Quran di Home
  static const String homeLanjutBaca = 'LANJUT BACA';
  /// Label section fitur ibadah di Home
  static const String homeFiturIbadah = 'FITUR IBADAH';
  /// Label misi harian di Home
  static const String homeMisiHarian = 'MISI HARIAN';
  static const String homeTahukahKamu = 'TAHUKAH KAMU?';
  static const String homeHaditsRamadhan = 'HADITS RAMADHAN';
  /// Format: "Ayat 5 dari 286"
  static const String homeAyatDariFormat = 'Ayat {number} dari {total}';
  /// Format: "Ayat 5"
  static const String homeAyatFormat = 'Ayat {number}';
  /// Label reward di quest card: "Hadiah: ..."
  static const String homeHadiahLabel = 'Hadiah:';
  /// Label hari di quote card: "Hari 15"
  static const String homeHariFormat = 'Hari {day}';

  // ─── USER / PROFILE ────────────────────────────────────
  static const String userTemaAplikasi = 'Tema Aplikasi';
  static const String userBackgroundSound = 'Background Sound';
  static const String userBgSoundDesc = 'Suasana latar di Beranda';
  static const String userPengaturanAI = 'Pengaturan AI Chat';
  static const String userAiDesc = 'API key Groq untuk Muslim AI Chat';
  static const String userAiDescription = 'Masukkan API key Groq pribadi Anda untuk mengaktifkan Muslim AI Chat.\n\nKonten AI lainnya (quotes, nasehat, quest) sudah aktif secara default.\n\nDapatkan API key gratis di console.groq.com';
  static const String userBukaGroqConsole = 'Buka console.groq.com';
  static const String userSyncP2P = 'Sync P2P (QR)';
  static const String userSyncP2PDesc = 'Kirim data via QR Code';
  static const String userManajemenData = 'Manajemen Data';
  static const String userManajemenDataDesc = 'Pindahkan data Jurnal, Tracker, dan preferensi Anda jika ingin berpindah perangkat.';
  static const String userBackupRestore = 'Backup & Restore';
  static const String userExportBackup = 'Export (Backup) Data';
  static const String userExportDesc = 'Unduh semua progres ke file .json';
  static const String userBuatBackup = 'Buat Backup';
  static const String userImportRestore = 'Import (Restore) Data';
  static const String userImportDesc = 'Pulihkan data dari file backup';
  static const String userPilihFileBackup = 'Pilih File Backup';
  static const String userResetSemuaData = 'Reset Semua Data';
  static const String userResetDesc = 'Hapus semua progres';
  static const String userResetTitle = 'Reset Semua Data?';
  static const String userResetWarning = 'Semua data tracker, jurnal, bookmark, dan preferensi akan dihapus secara permanen.';
  static const String userBantuanFAQ = 'Bantuan & FAQ';
  static const String userKebijakanPrivasi = 'Kebijakan Privasi';
  static const String userTentangUmma = 'Tentang Umma';
  static const String userPengembang = 'Pengembang Aplikasi';
  static const String userKirimFeedback = 'Kirim Feedback';
  static const String userCekUpdate = 'Cek Update Aplikasi';
  static const String userGitHubRepo = 'GitHub Repository';
  static const String userGitHubDesc = 'Buka halaman proyek';
  static const String userDoakanDeveloper = "Do'akan Developer";
  static const String userIkutiSaya = 'Ikuti Saya';
  static const String userPortofolio = 'Portofolio';
  static const String userGitHub = 'GitHub';
  static const String userDataBackup = 'Backup Data Umma';
  static const String userPrivacyHeader = 'Kenyamanan dan privasi Anda adalah prioritas mutlak kami:';
  static const String userPrivacyNoServer = 'Tidak Ada Database Server';
  static const String userPrivacyNoServerDesc = 'Semua data Anda disimpan sepenuhnya secara lokal di memori perangkat Anda.';
  static const String userPrivacyNoCollect = 'Tidak Ada Koleksi Data';
  static const String userPrivacyNoCollectDesc = 'Kami tidak mengumpulkan, melihat, atau menyimpan data pribadi Anda di server mana pun.';
  static const String userPrivacyDirectTransfer = 'Transfer Data Langsung';
  static const String userPrivacyDirectTransferDesc = 'Saat Anda memindahkan data ke perangkat baru, file backup ditransfer langsung tanpa perantara server.';
  static const String userPrivacyNoAds = 'Tanpa Iklan & Pelacakan';
  static const String userPrivacyNoAdsDesc = 'Aplikasi ini bersih dari iklan pihak ketiga dan skrip pelacak.';
  static const String userTentangDesc1 = 'Umma adalah aplikasi Muslim all-in-one yang dirancang untuk membantu ibadah sehari-hari dengan gaya iOS yang elegan.';
  static const String userTentangDesc2 = 'Aplikasi ini 100% gratis tanpa iklan. Data Anda aman tersimpan secara lokal di perangkat.';
  static const String userTentangDesc3 = 'Semoga menjadi amal jariyah dan bermanfaat bagi kita semua. 🤲';
  static const String userCityNotFound = 'Tidak ditemukan kota untuk "{city}"';
  // AI settings placeholder
  static const String userGroqApiPlaceholder = 'gsk_...';

  // ─── MURATTAL ────────────────────────────────────────────
  static const String murattalCariSurah = 'Cari surah...';
  static const String murattalPilihQari = 'Pilih Qari';
  static const String murattalOffline = 'OFFLINE';
  static const String murattalSurahNotFound = 'Surah tidak ditemukan';
  static const String murattalSearchHint = 'Coba kata kunci lain';
  static const String murattalDownloadingSurah = 'Mengunduh surah...';
  static const String murattalDownloadCount = '{downloaded} dari {total} surah tersimpan';
  static const String murattalActiveLabel = 'Aktif';

  // ─── QURAN (tambahan) ─────────────────────────────────────
  static const String quranModeHafalan = 'Mode Hafalan — ketuk untuk melihat ayat';
  static const String quranAudioSiapOffline = 'Semua audio siap offline ({count})';
  static const String quranDownloadAudio = 'Download Semua Audio ({downloaded}/{total})';
  static const String quranAyatFormat = 'Ayat {number}';
  static const String quranJuzFormat = 'Juz {number}';
  static const String quranTotalAyat = '{total} Ayat';
  static const String quranJuzLoadError = 'Gagal memuat Juz {number}';
  static const String quranErrorNeedInternet = 'Aktifkan internet untuk memuat Surah "{name}" dari server';
  static const String quranSurahNameList = '{surahs}';
  static const String quranDoaSetelahBaca = 'Doa Setelah Membaca Al-Qur\'an';

  // ─── ONBOARDING ────────────────────────────────────────────
  static const String onboardingWelcomeTitle = 'Selamat Datang di Umma';
  static const String onboardingQuranTitle = "Al-Qur'an Digital dengan Tafsir";
  static const String onboardingShalatTitle = 'Jadwal Shalat & Dzikir Harian';
  static const String onboardingFiturTitle = 'Fitur Lengkap untuk Muslim';
  static const String onboardingUpdateTitle = 'Catatan Update';
  static const String onboardingLanjut = 'Lanjut';
  static const String onboardingMulai = 'Mulai';
  static const String onboardingLewati = 'Lewati';
  static const String onboardingVersionLoading = 'Memuat catatan update...';
  // Onboarding page subtitles
  static const String onboardingPage1Sub = 'Segala puji bagi Allah. Umma hadir untuk memudahkan Anda dalam menuntut ilmu syar\'i dan mengamalkannya. Aplikasi ini menyediakan Al-Qur\'an dengan tafsir, kumpulan hadits shahih, doa & dzikir pilihan, serta panduan fikih praktis. Semoga menjadi wasilah istiqomah Anda dalam beribadah.';
  static const String onboardingPage2Sub = 'Baca Al-Qur\'an 114 surah dengan terjemah dan tafsir lengkap. Dilengkapi audio murottal, bookmark ayat, catatan pribadi, dan target khatam. Nikmati pengalaman membaca yang khusyuk dengan tampilan mushaf yang nyaman di mata.';
  static const String onboardingPage3Sub = 'Jadwal shalat otomatis untuk kota Anda dengan notifikasi yang akurat. Lengkap dengan dzikir pagi-petua, doa sehari-hari, hadits Arbain, dan kompas kiblat. Jangan lewatkan waktu shalat dengan alarm yang tepat.';
  static const String onboardingPage4Sub = 'Tracker ibadah harian, jurnal muhasabah, kalkulator zakat, tracker haid untuk muslimah, dan Muslim AI untuk tanya jawab agama. Semua fitur dirancang untuk membantu Anda lebih dekat dengan Allah.';
  static const String onboardingSalam = 'السلام عليكم ورحمة الله';
  static const String onboardingQuranArab = 'القرآن كلام الله';
  static const String onboardingShalatArab = 'أقم الصلاة لذكري';
  static const String onboardingIlmuArab = 'طلب العلم فريضة';

  // ─── COMMON ACTIONS ─────────────────────────────────────
  static const String yesHapus = 'Ya, Hapus';
  static const String update = 'Update';
  static const String mengunduh = 'Mengunduh Update';
  static const String izinDiperlukan = 'Izin Diperlukan';
  static const String reset = 'Reset';
  static const String bukaPengaturan = 'Buka Pengaturan';
  static const String versiBaru = 'Versi baru tersedia, silahkan update aplikasi Umma';
  static const String updateVersi = 'Silahkan Update aplikasi Umma ke versi {version}';

  // ─── UPDATE POPUP ──────────────────────────────────────────
  static const String gagalMengunduh = 'Gagal Mengunduh';
  static const String updateError = 'Terjadi kesalahan saat mengunduh pembaruan. Coba lagi nanti.';
  static const String updateChecking = 'Memeriksa Update';
  static const String updateCheckWait = 'Mohon tunggu...';
  static const String updateAlreadyLatest = 'Aplikasi sudah versi terbaru';
  static const String updateCheckError = 'Gagal memeriksa pembaruan. Pastikan koneksi internet aktif.';
  static const String updateCheckFailed = 'Gagal';
  static const String updateLatest = 'Terbaru';
  static const String tutup = 'Tutup';
  static const String installPermission = 'Aktifkan "Izinkan Install dari sumber tidak dikenal" di pengaturan, lalu kembali ke aplikasi untuk melanjutkan install.';

  // ─── JURNAL ───────────────────────────────────────────────
  static const String jurnalEntriTerbaru = 'ENTRI TERBARU';
  static const String jurnalEntriTersimpan = '{count} entri tersimpan';
}

