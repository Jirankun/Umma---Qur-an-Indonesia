/// ============================================================
/// ============================================================
/// API CONFIG — Endpoint API & data mapping
/// ============================================================
/// Endpoint API eksternal (EQuran, Hadits, OpenStreetMap),
/// mapping kota, storage keys, dan konstanta offline.
/// ============================================================
library;

class ApiConfig {
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. EQURAN.ID (Quran, Doa, Hadits)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String eQuranBaseUrl = 'https://equran.id/api/v2';
  static const String surahEndpoint = '/surat';
  static const String surahDetailEndpoint = '/surat/{number}';
  static const String ayahEndpoint = '/ayat';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. EQURAN.ID SHALAT (Jadwal Sholat, HTTPS)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Sumber data: Bimas Islam Kementerian Agama RI
  // Dokumentasi: https://equran.id/apidev/shalat
  static const String equranShalatBaseUrl = 'https://equran.id/api/v2/shalat';
  static const String equranShalatEndpoint = ''; // POST endpoint: /shalat
  static const String equranShalatProvinsiEndpoint = '/provinsi'; // GET
  static const String equranShalatKabkotaEndpoint = '/kabkota'; // POST

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. HADITS API (hadis-api-id — 9 perawi, terjemahan Indonesia)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Sumber: https://github.com/renomureza/hadis-api-id
  static const String haditsApiBaseUrl =
      'https://hadis-api-id.vercel.app/hadith';
  static const String haditsBookEndpoint = ''; // GET / → daftar perawi
  static const String haditsRangeEndpoint =
      '/{book}'; // GET /{slug}?page={n}&limit={n}

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. OPENSTREETMAP (Reverse Geocoding)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String osmBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String osmReverseEndpoint = '/reverse';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2.5. TAFSIR (EQuran.id — per surah)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String tafsirEndpoint = '/tafsir/{number}';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. CONSTANTS
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String appName = 'Umma';
  static const String packageName = 'app.umma.aokaze';

  // Ka'bah coordinates
  static const double kabahLatitude = 21.422487;
  static const double kabahLongitude = 39.826206;

  // Quran total verses
  static const int totalQuranVerses = 6236;

  // Prayer names
  static const List<String> prayerNames = [
    'Imsak',
    'Subuh',
    'Dzuhur',
    'Ashar',
    'Maghrib',
    'Isya',
  ];

  // ─── TIMEZONE MAPPING ──────────────────────────────────────
  // Indonesia has 3 timezones: WIB (+7), WITA (+8), WIT (+9)
  // The API returns times in local city time, but we store the timezone
  // for display and verification purposes.
  static const Map<String, String> cityTimezone = {
    'Jakarta': 'WIB',
    'Bandung': 'WIB',
    'Bekasi': 'WIB',
    'Bogor': 'WIB',
    'Depok': 'WIB',
    'Tangerang': 'WIB',
    'Serang': 'WIB',
    'Cirebon': 'WIB',
    'Semarang': 'WIB',
    'Surakarta': 'WIB',
    'Magelang': 'WIB',
    'Madiun': 'WIB',
    'Yogyakarta': 'WIB',
    'Surabaya': 'WIB',
    'Malang': 'WIB',
    'Banjarmasin': 'WITA',
    'Palangkaraya': 'WIB',
    'Pontianak': 'WIB',
    'Samarinda': 'WITA',
    'Balikpapan': 'WITA',
    'Tarakan': 'WITA',
    'Pekanbaru': 'WIB',
    'Padang': 'WIB',
    'Medan': 'WIB',
    'Banda Aceh': 'WIB',
    'Bandar Lampung': 'WIB',
    'Palembang': 'WIB',
    'Jambi': 'WIB',
    'Bengkulu': 'WIB',
    'Pangkalpinang': 'WIB',
    'Tanjungpinang': 'WIB',
    'Batam': 'WIB',
    'Denpasar': 'WITA',
    'Mataram': 'WITA',
    'Kupang': 'WITA',
    'Makassar': 'WITA',
    'Manado': 'WITA',
    'Palu': 'WITA',
    'Gorontalo': 'WITA',
    'Kendari': 'WITA',
    'Ambon': 'WIT',
    'Ternate': 'WIT',
    'Jayapura': 'WIT',
  };

  /// Get timezone abbreviation for a city
  static String getTimezone(String city) => cityTimezone[city] ?? 'WIB';

  /// Get UTC offset in hours for a city
  /// WIB = +7, WITA = +8, WIT = +9
  static int getUtcOffset(String city) {
    final tz = cityTimezone[city] ?? 'WIB';
    switch (tz) {
      case 'WITA':
        return 8;
      case 'WIT':
        return 9;
      default:
        return 7; // WIB
    }
  }

  // Notification channel IDs
  static const String notifChannelId = 'umma_prayer_times';
  static const String notifChannelName = 'Waktu Sholat';
  static const String notifChannelDesc = 'Notifikasi waktu sholat harian';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. QURAN OFFLINE STORAGE
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Base directory: {appDocDir}/quran/ (via getApplicationDocumentsDirectory)
  static const String quranStorageDir = 'quran';
  static const String quranJsonDir = 'quran/json';
  static const String quranAudioDir = 'quran/audio';
  static const String quranSurahsFile = 'surahs.json';

  // EQuran CDN for audio — per Qari
  // Format: https://cdn.equran.id/audio-full/{qari_name}/{surah_number_padded_3}.mp3
  static const String quranAudioCdn = 'https://cdn.equran.id/audio-full';
  static const String quranDefaultQari = 'Misyari-Rasyid-Al-Afasi';
  static const String quranDefaultQariId = '05';

  // Map of qariId -> folder name on CDN
  static const Map<String, String> qariCdnNames = {
    '01': 'Abdullah-Al-Juhany',
    '02': 'Abdul-Muhsin-Al-Qasim',
    '03': 'Abdurrahman-as-Sudais',
    '04': 'Ibrahim-Al-Dossari',
    '05': 'Misyari-Rasyid-Al-Afasi',
    '06': 'Yasser-Al-Dosari',
  };

  // List of available Qari (reciters)
  static const List<Map<String, String>> qariList = [
    {'id': '01', 'name': 'Abdullah Al-Juhany', 'nameAr': 'عبد الله الجهني'},
    {
      'id': '02',
      'name': 'Abdul Muhsin Al-Qasim',
      'nameAr': 'عبد المحسن القاسم',
    },
    {
      'id': '03',
      'name': 'Abdurrahman as-Sudais',
      'nameAr': 'عبد الرحمن السديس',
    },
    {'id': '04', 'name': 'Ibrahim Al-Dossari', 'nameAr': 'إبراهيم الدوسري'},
    {
      'id': '05',
      'name': 'Misyari Rasyid Al-Afasi',
      'nameAr': 'مشاري راشد العفاسي',
    },
    {'id': '06', 'name': 'Yasser Al-Dosari', 'nameAr': 'ياسر الدوسري'},
  ];

  /// Get Qari name from ID
  static String getQariName(String id) {
    return qariList.firstWhere(
      (q) => q['id'] == id,
      orElse: () => qariList[4], // default: Misyari
    )['name']!;
  }

  // Storage keys
  static const String storageKeyUser = 'umma_user';
  static const String storageKeyTheme = 'umma_theme';
  static const String storageKeyCity = 'umma_city';
  static const String storageKeyPrayerTimes = 'umma_prayer_times';
  static const String storageKeyTracker = 'umma_tracker';
  static const String storageKeyJournal = 'umma_journal';
  static const String storageKeyHaid = 'umma_haid';
  static const String storageKeyQuranBookmarks = 'umma_quran_bookmarks';
  static const String storageKeyQuranLastRead = 'umma_quran_last_read';
  static const String storageKeyDoaBookmarks = 'umma_doa_bookmarks';
  static const String storageKeyDoaCustom = 'umma_doa_custom';
  static const String storageKeyDoaSettings = 'umma_doa_settings';
  static const String storageKeyHaditsBookmarks = 'umma_hadits_bookmarks';
  static const String storageKeyHaditsLastRead = 'umma_hadits_last_read';
  static const String storageKeyHaditsSettings = 'umma_hadits_settings';
  static const String storageKeyFiqihBookmarks = 'umma_fiqih_bookmarks';
  static const String storageKeyArbainBookmarks = 'umma_arbain_bookmarks';
  static const String storageKeyQuranReadingHistory = 'quran_reading_history';
  static const String storageKeyKhatamPlan = 'quran_khatam_plan';
  static const String storageKeyPrayerTimesSchedule =
      'umma_prayer_times_schedule';
  static const String storageKeyQuranReaderSettings =
      'umma_quran_reader_settings';
  static const String storageKeyZakat = 'umma_zakat';
  static const String storageKeyTasbih = 'umma_tasbih';
  static const String storageKeyGroqApiKey = 'umma_groq_api_key';

  // ─── COMPLETE LIST OF DATA KEYS FOR EXPORT/IMPORT ────────────
  /// All storage keys that should be included in backup, QR sync, etc.
  /// NOTE: storageKeyTheme & storageKeyCity are handled separately
  ///       as plain strings (not JSON) in collectAllExportData().
  static const List<String> exportDataKeys = [
    storageKeyTracker,
    storageKeyJournal,
    storageKeyUser,
    storageKeyQuranBookmarks,
    storageKeyQuranLastRead,
    storageKeyDoaBookmarks,
    storageKeyDoaCustom,
    storageKeyHaditsBookmarks,
    storageKeyHaditsLastRead,
    storageKeyFiqihBookmarks,
    storageKeyArbainBookmarks,
    storageKeyKhatamPlan,
    storageKeyQuranReadingHistory,
    storageKeyHaditsSettings,
    storageKeyDoaSettings,
    storageKeyQuranReaderSettings,
    storageKeyHaid,
    storageKeyZakat,
    storageKeyTasbih,
    storageKeyPrayerTimes,
    storageKeyPrayerTimesSchedule,
    storageKeyGroqApiKey,
  ];

  /// Keys whose values are stored as plain strings (SharedPrefs),
  /// NOT as JSON files. These need special handling in export/import.
  static const List<String> stringStorageKeys = [
    storageKeyTheme,
    storageKeyCity,
    storageKeyGroqApiKey,
  ];

  // Indonesian cities for prayer times (display names)
  static const List<String> indonesianCities = [
    'Ambon',
    'Balikpapan',
    'Banda Aceh',
    'Bandar Lampung',
    'Bandung',
    'Banjarmasin',
    'Batam',
    'Bekasi',
    'Bengkulu',
    'Bogor',
    'Cirebon',
    'Denpasar',
    'Depok',
    'Gorontalo',
    'Jakarta',
    'Jambi',
    'Jayapura',
    'Kendari',
    'Kupang',
    'Madiun',
    'Magelang',
    'Makassar',
    'Malang',
    'Manado',
    'Mataram',
    'Medan',
    'Padang',
    'Palangkaraya',
    'Palembang',
    'Palu',
    'Pangkalpinang',
    'Pekanbaru',
    'Pontianak',
    'Samarinda',
    'Semarang',
    'Serang',
    'Surabaya',
    'Surakarta',
    'Tangerang',
    'Tanjungpinang',
    'Tarakan',
    'Ternate',
    'Yogyakarta',
  ];

  /// Mapping kota display name → {provinsi, kabkota} untuk equran.id API
  /// Sumber data: Bimas Islam Kemenag RI via https://equran.id/apidev/shalat
  static const Map<String, Map<String, String>> cityToShalatMapping = {
    'Ambon': {'provinsi': 'Maluku', 'kabkota': 'Kota Ambon'},
    'Balikpapan': {
      'provinsi': 'Kalimantan Timur',
      'kabkota': 'Kota Balikpapan',
    },
    'Banda Aceh': {'provinsi': 'Aceh', 'kabkota': 'Kota Banda Aceh'},
    'Bandar Lampung': {'provinsi': 'Lampung', 'kabkota': 'Kota Bandar Lampung'},
    'Bandung': {'provinsi': 'Jawa Barat', 'kabkota': 'Kota Bandung'},
    'Banjarmasin': {
      'provinsi': 'Kalimantan Selatan',
      'kabkota': 'Kota Banjarmasin',
    },
    'Batam': {'provinsi': 'Kepulauan Riau', 'kabkota': 'Kota Batam'},
    'Bekasi': {'provinsi': 'Jawa Barat', 'kabkota': 'Kota Bekasi'},
    'Bengkulu': {'provinsi': 'Bengkulu', 'kabkota': 'Kota Bengkulu'},
    'Bogor': {'provinsi': 'Jawa Barat', 'kabkota': 'Kota Bogor'},
    'Cirebon': {'provinsi': 'Jawa Barat', 'kabkota': 'Kota Cirebon'},
    'Denpasar': {'provinsi': 'Bali', 'kabkota': 'Kota Denpasar'},
    'Depok': {'provinsi': 'Jawa Barat', 'kabkota': 'Kota Depok'},
    'Gorontalo': {'provinsi': 'Gorontalo', 'kabkota': 'Kota Gorontalo'},
    'Jakarta': {'provinsi': 'DKI Jakarta', 'kabkota': 'Kota Jakarta'},
    'Jambi': {'provinsi': 'Jambi', 'kabkota': 'Kota Jambi'},
    'Jayapura': {'provinsi': 'Papua', 'kabkota': 'Kota Jayapura'},
    'Kendari': {'provinsi': 'Sulawesi Tenggara', 'kabkota': 'Kota Kendari'},
    'Kupang': {'provinsi': 'Nusa Tenggara Timur', 'kabkota': 'Kota Kupang'},
    'Madiun': {'provinsi': 'Jawa Timur', 'kabkota': 'Kota Madiun'},
    'Magelang': {'provinsi': 'Jawa Tengah', 'kabkota': 'Kota Magelang'},
    'Makassar': {'provinsi': 'Sulawesi Selatan', 'kabkota': 'Kota Makassar'},
    'Malang': {'provinsi': 'Jawa Timur', 'kabkota': 'Kota Malang'},
    'Manado': {'provinsi': 'Sulawesi Utara', 'kabkota': 'Kota Manado'},
    'Mataram': {'provinsi': 'Nusa Tenggara Barat', 'kabkota': 'Kota Mataram'},
    'Medan': {'provinsi': 'Sumatera Utara', 'kabkota': 'Kota Medan'},
    'Padang': {'provinsi': 'Sumatera Barat', 'kabkota': 'Kota Padang'},
    'Palangkaraya': {
      'provinsi': 'Kalimantan Tengah',
      'kabkota': 'Kota Palangkaraya',
    },
    'Palembang': {'provinsi': 'Sumatera Selatan', 'kabkota': 'Kota Palembang'},
    'Palu': {'provinsi': 'Sulawesi Tengah', 'kabkota': 'Kota Palu'},
    'Pangkalpinang': {
      'provinsi': 'Kepulauan Bangka Belitung',
      'kabkota': 'Kota Pangkalpinang',
    },
    'Pekanbaru': {'provinsi': 'Riau', 'kabkota': 'Kota Pekanbaru'},
    'Pontianak': {'provinsi': 'Kalimantan Barat', 'kabkota': 'Kota Pontianak'},
    'Samarinda': {'provinsi': 'Kalimantan Timur', 'kabkota': 'Kota Samarinda'},
    'Semarang': {'provinsi': 'Jawa Tengah', 'kabkota': 'Kota Semarang'},
    'Serang': {'provinsi': 'Banten', 'kabkota': 'Kota Serang'},
    'Surabaya': {'provinsi': 'Jawa Timur', 'kabkota': 'Kota Surabaya'},
    'Surakarta': {'provinsi': 'Jawa Tengah', 'kabkota': 'Kota Surakarta'},
    'Tangerang': {'provinsi': 'Banten', 'kabkota': 'Kota Tangerang'},
    'Tanjungpinang': {
      'provinsi': 'Kepulauan Riau',
      'kabkota': 'Kota Tanjungpinang',
    },
    'Tarakan': {'provinsi': 'Kalimantan Utara', 'kabkota': 'Kota Tarakan'},
    'Ternate': {'provinsi': 'Maluku Utara', 'kabkota': 'Kota Ternate'},
    'Yogyakarta': {'provinsi': 'D.I. Yogyakarta', 'kabkota': 'Kota Yogyakarta'},
  };
}
