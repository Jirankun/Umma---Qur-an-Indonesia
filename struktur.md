# 📂 Struktur Project Umma

## Root (umma/)

```
umma/
├── android/                          # Konfigurasi Android native
│   ├── app/
│   │   ├── build.gradle.kts          # compileSdk=36, minSdk=24, targetSdk=35
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # Permissions + activities
│   │       └── kotlin/app/umma/aokaze/MainActivity.kt
│   ├── build.gradle.kts             # Root gradle
│   ├── settings.gradle.kts          # Kotlin 2.2.20, AGP 9.0.1
│   └── gradle.properties            # JVM args
│
├── assets/
│   ├── font/
│   │   ├── Lateef-Regular.ttf       # Font arab untuk teks Al-Qur'an
│   │   └── ScheherazadeNew-Regular.ttf  # Font arab alternatif
│   └── audio/ (tidak di-git)
│       ├── bg_night.mp3             # Background sound malam
│       └── bg_sunrise.mp3           # Background sound siang
│
├── lib/
│   ├── main.dart                    # Entry point + 15+ MultiProvider
│   ├── app.dart                     # CupertinoApp + routing
│   │
│   ├── config/
│   │   └── api_config.dart          # API key, endpoint, konstanta (200+ line)
│   │
│   ├── models/                      # Data models (POJO)
│   │   ├── models.dart              # PrayerTime, DailyTracker, FiqihItem, dll
│   │   ├── quran.dart               # Surah, Ayat, LastRead, Bookmark
│   │   ├── hadits.dart              # HaditsBook, HaditsItem, Bookmark
│   │   └── doa.dart                 # DoaItem
│   │
│   ├── providers/                   # State management (ChangeNotifier)
│   │   ├── theme_provider.dart      # Dark/light mode
│   │   ├── prayer_times_provider.dart # Jadwal sholat + countdown
│   │   ├── quran_provider.dart      # Data surah, audio, bookmark, lastRead
│   │   ├── doa_provider.dart        # Bookmark, custom doa, settings
│   │   ├── hadits_provider.dart     # 9 kitab, pagination, bookmark
│   │   ├── fiqih_provider.dart      # Fiqih online + 47 offline fallback
│   │   ├── tracker_provider.dart    # Target harian + Ramadhan stats
│   │   ├── journal_provider.dart    # CRUD jurnal harian
│   │   ├── zakat_provider.dart      # Kalkulator 4 jenis zakat
│   │   ├── haid_provider.dart       # Log siklus haid + qadha
│   │   ├── tasbih_provider.dart     # Counter dzikir
│   │   ├── muslim_ai_provider.dart  # Chat history Muslim AI
│   │   ├── user_provider.dart       # Profil + foto + custom habits
│   │   ├── background_sound_provider.dart # Audio ambient (pagi/malam)
│   │   └── update_provider.dart     # Cek versi terbaru dari GitHub
│   │
│   ├── services/                    # Business logic + API calls
│   │   ├── api_service.dart         # HTTP client: EQuran + Hadits API
│   │   ├── ai_service.dart          # Groq AI: chat + system prompt
│   │   ├── ai_content_service.dart  # AI daily content: quotes, hadits, fiqih
│   │   ├── prayer_time_service.dart # Jadwal sholat dari EQuran API
│   │   ├── notification_service.dart # AwesomeNotifications + WorkManager
│   │   ├── quran_download_service.dart # Download audio + JSON offline
│   │   ├── quran_tracker_service.dart  # Khatam progress + stats
│   │   ├── background_service.dart   # Background audio + location
│   │   └── local_storage.dart       # SharedPreferences wrapper
│   │
│   ├── data/                        # Data offline/fallback
│   │   ├── doa_data.dart            # 8 kategori doa (64+ doa)
│   │   ├── fiqih_data.dart          # 47 topik fiqih Ramadhan
│   │   ├── hadits_data.dart         # 33 hadits Ramadhan
│   │   ├── quotes_data.dart         # 60+ quotes Islami
│   │   ├── study_data.dart          # 30 hari materi Ramadhan
│   │   └── juz_mapping.dart         # Mapping surah → juz
│   │
│   ├── screens/                     # UI screens
│   │   ├── home/
│   │   │   ├── home_screen.dart         # PageView (4 tabs) + bg sound
│   │   │   └── widgets/
│   │   │       ├── hero_card.dart          # Prayer times + countdown
│   │   │       ├── daily_goal_tracker.dart # Tracker summary card
│   │   │       ├── tool_grid.dart          # 11 fitur grid (4 kolom)
│   │   │       ├── daily_knowledge_card.dart # Hadits/tahukah kamu
│   │   │       ├── daily_quest_card.dart     # Quest harian
│   │   │       └── quote_card.dart         # Quotes daily
│   │   │
│   │   ├── quran/
│   │   │   ├── quran_index_screen.dart  # Index surah + juz tabs
│   │   │   ├── surah_reader_screen.dart # Reader surah (audio, tafsir, wakelock)
│   │   │   └── juz_reader_screen.dart   # Reader juz (audio, tafsir, wakelock)
│   │   │
│   │   ├── doa/doa_home_screen.dart     # 8 kategori doa + DoaListScreen (wakelock, pengaturan baca)
│   │   ├── hadits/hadits_home_screen.dart # 9 kitab + HaditsReaderScreen (wakelock, bookmark tab)
│   │   ├── fiqih/fiqih_home_screen.dart  # Kategori + search + detail (fallback pesan)
│   │   ├── zakat/zakat_screen.dart       # Kalkulator (fitrah hanya Ramadhan)
│   │   ├── tasbih/tasbih_screen.dart     # Counter digital
│   │   ├── tracker/tracker_screen.dart   # 8-9 target harian
│   │   ├── jurnal/jurnal_dashboard_screen.dart # CRUD + filter
│   │   ├── haid/haid_tracker_screen.dart # Log haid + cycle phase
│   │   ├── kompas/kompas_screen.dart     # Arah kiblat (1 jarum hijau)
│   │   ├── study/study_screen.dart       # 30 hari (Ramadhan only)
│   │   ├── muslim_ai/muslim_ai_screen.dart # Chat AI + bold + [Buka:] marker
│   │   ├── user/user_profile_screen.dart # Profil + foto + pilih kota + backup
│   │   ├── sync/p2p_sync_screen.dart     # QR code sync
│   │   └── _shared/
│   │       └── cupertino_progress_bar.dart # Reusable progress bar
│   │
│   └── utils/
│       └── date_helper.dart          # Hijri date + Ramadhan season check
│
├── test/
│   └── widget_test.dart              # Default test (belum diisi)
│
├── pubspec.yaml                      # Dependencies (20+ packages)
├── analysis_options.yaml             # flutter_lints
├── README.md                         # Dokumentasi lengkap
├── struktur.md                       # File ini
└── .gitignore
```

---

## 🔄 Data Flow Arsitektur

```
┌─────────────────────────────────────────────────────────┐
│                      UI Layer                            │
│  screens/ + screens/*/widgets/                          │
│  (CupertinoPageScaffold, CupertinoNavigationBar, dll)   │
└──────────────┬──────────────────────────────▲───────────┘
               │ Provider.of<T>(context)       │
               ▼                              │
┌─────────────────────────────────────────────────────────┐
│                   State Layer                             │
│  providers/ (ChangeNotifier)                             │
│  ├── Load data dari service                             │
│  ├── Cache di memory                                    │
│  └── notifyListeners() → UI rebuild                     │
└──────────────┬──────────────────────────────▲───────────┘
               │ Panggil method                │ Return data
               ▼                              │
┌─────────────────────────────────────────────────────────┐
│                  Service Layer                            │
│  services/                                               │
│  ├── api_service.dart  → HTTP → EQuran / Hadits API     │
│  ├── ai_service.dart   → HTTP → Groq AI                 │
│  ├── local_storage.dart → SharedPreferences              │
│  ├── prayer_time_service.dart → API → Schedule            │
│  └── quran_download_service.dart → CDN → File            │
└─────────────────────────────────────────────────────────┘
```

---

## 📦 Data Flow per Fitur

### Al-Qur'an

```
QuranIndexScreen
  ├── Load surah → api_service.getSurahs() → EQuran API
  ├── Cari surah → filter lokal (fallback pesan jika tidak ditemukan)
  ├── Tap surah → SurahReaderScreen(surahId)
  │   ├── Load ayat → api_service.getSurahDetail(id) → EQuran API
  │   ├── Audio → quran_download_service → EQuran CDN
  │   ├── Auto-scroll ke ayat target (alignment 0.5 → tengah layar)
  │   ├── Tafsir → api_service.getTafsir(id) → EQuran API
  │   └── Last read → session end modal
  └── Tap juz → JuzReaderScreen(juzNumber)
      └── Auto-scroll ke ayat target + wakelock
```

### Jadwal Sholat

```
PrayerTimesProvider
  ├── fetchPrayerTimes()
  │   └── prayer_time_service.getSchedule(city) → EQuran API
  │       ├── POST /shalat (provinsi, kabkota)
  │       └── Return: jadwal 1 bulan
  ├── Simpan kota ke storageKeyCity (SharedPrefs) — FIX: dulu tidak disimpan
  ├── Cari jadwal hari ini
  ├── Countdown ke sholat berikutnya
  └── NotificationService.startBackgroundCheck()
      └── WorkManager → cek tiap 30 menit → AwesomeNotifications
```

### Muslim AI Chat

```
MuslimAiScreen
  ├── User kirim pesan
  ├── ai_service.sendMessage(history, systemPrompt)
  │   └── POST /chat/completions → Groq (Llama 3.3 70B)
  │       ├── Model: llama-3.3-70b-versatile
  │       ├── Temperature: 0.75
  │       ├── Max tokens: 512 (ngobrol) / 256 (referensi)
  │       └── Marker hanya jika user minta konten spesifik
  ├── Parse response:
  │   ├── **bold** → RichText bold (FontWeight.w800)
  │   ├── [Buka:screen:param] → Tombol navigasi
  │   └── [Cari:QUERY] → Tombol Google Search
  ├── Navigasi: push target DI ATAS AI (back ke AI, bukan Beranda)
  │   ├── Audio cleanup: stop background sound + Quran audio
  │   └── Scroll presisi ke card target (alignment 0.5)
  └── Render chat bubble → CupertinoChatStyle
```

### Background Sound

```
BackgroundSoundProvider
  ├── loadSettings() → SharedPreferences (enabled/disabled)
  ├── start() → play audio sesuai waktu:
  │   ├── 05:00-17:59 → bg_sunrise.mp3
  │   └── 18:00-04:59 → bg_night.mp3
  ├── stop() → dispose player
  ├── Otomatis: start di Beranda tab, stop di tab lain
  └── Otomatis stop saat:
      ├── Navigasi dari Beranda ke screen lain
      ├── Navigasi dari AI ke screen lain (via [Buka:])
      ├── App di-minimize
      └── Pindah tab
```

### Tracker Harian

```
TrackerScreen
  ├── TrackerProvider.loadTrackers()
  │   └── local_storage.getJson → SharedPrefs
  ├── Render 8-9 item (tarawih hanya Ramadhan)
  ├── Tap item → toggleTracker(date, key)
  │   └── Save → SharedPrefs
  └── Header: summary (completed/total + percentage)
```

### Export / Backup Data

```
LocalStorage
  ├── collectAllExportData() → semua data dalam 1 JSON:
  │   ├── storageKeyUser          (profil + foto base64)
  │   ├── storageKeyQuranBookmarks
  │   ├── storageKeyQuranLastRead
  │   ├── storageKeyDoaBookmarks
  │   ├── storageKeyHaditsBookmarks
  │   ├── storageKeyArbainBookmarks
  │   ├── storageKeyTracker
  │   ├── storageKeyJournal
  │   ├── storageKeyTasbih
  │   └── ...dll
  ├── restoreFromExport() → restore semua data
  └── P2P sync via QR code (encode/decode JSON)
```

---

## 🔐 API Keys & Credentials

| Service | Key Location | Type |
|---------|-------------|------|
| **Groq AI** | `api_config.dart` → `String.fromEnvironment('GROQ_API_KEY')` | Opsional: build arg atau default embedded |
| **EQuran API** | Public API (no key required) | - |
| **Hadis API ID** | Public API (no key required) | - |
| **OpenStreetMap** | Public API (no key required) | - |

Build dengan custom API key:
```bash
flutter run --dart-define=GROQ_API_KEY=gsk_your_key_here
```

---

## 🧠 State Management Pattern

Semua state management menggunakan **Provider** dengan **ChangeNotifier**.

### Cara kerja:

```
1. ChangeNotifier → class yang meng-extend ChangeNotifier
2. State disimpan dalam field private: _state
3. Getter public: get state => _state
4. Setiap perubahan → panggil notifyListeners()
5. UI subscribe dengan Provider.of<T>(context) atau context.watch<T>()
6. Action tanpa rebuild → context.read<T>().method()
```

### Contoh:

```dart
// Provider
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners(); // UI rebuild otomatis
  }
}

// UI
final isDark = Provider.of<ThemeProvider>(context).isDark;
context.read<ThemeProvider>().toggleTheme();
```

---

## 🧪 Testing

Saat ini project memiliki 1 file test default (`test/widget_test.dart`) yang belum diisi.

Untuk menjalankan test:
```bash
cd umma
flutter test
```

---

## 📱 Android Build Configuration

| Parameter | Value | Keterangan |
|-----------|-------|------------|
| `compileSdk` | 36 | Android 16 |
| `minSdk` | 24 | Android 7.0 Nougat |
| `targetSdk` | 35 | Android 15 |
| `Kotlin` | 2.2.20 | Versi terbaru |
| `Java` | 17 | Java 17 |
| `Desugar` | Enabled | `desugar_jdk_libs:2.1.4` |
| `ApplicationId` | `app.umma.aokaze` | Package name |

---

## 🌐 44 Kota Didukung

Seluruh Indonesia:

**Sumatra:** Banda Aceh, Medan, Padang, Pekanbaru, Batam, Tanjungpinang, Jambi, Palembang, Bengkulu, Bandar Lampung, Pangkalpinang

**Jawa:** Jakarta, Bekasi, Bogor, Depok, Tangerang, Serang, Cirebon, Bandung, Semarang, Surakarta, Magelang, Madiun, Yogyakarta, Surabaya, Malang

**Bali & Nusa:** Denpasar, Mataram, Kupang

**Kalimantan:** Pontianak, Palangkaraya, Banjarmasin, Samarinda, Balikpapan, Tarakan

**Sulawesi:** Makassar, Manado, Palu, Gorontalo, Kendari

**Maluku & Papua:** Ambon, Ternate, Jayapura

---

## 📦 Package Dependencies

| Package | Versi | Fungsi |
|---------|-------|--------|
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `provider` | ^6.1.2 | State management |
| `http` | ^1.2.2 | HTTP client |
| `shared_preferences` | ^2.3.4 | Local storage |
| `path_provider` | ^2.1.5 | File paths |
| `geolocator` | ^13.0.2 | GPS location |
| `sensors_plus` | ^6.1.1 | Magnetometer/accelerometer |
| `audioplayers` | ^6.1.0 | Audio playback |
| `intl` | ^0.19.0 | Date formatting |
| `url_launcher` | ^6.3.1 | Open URLs |
| `share_plus` | ^10.1.4 | Share/export |
| `hijri_date` | ^0.6.1 | Hijri calendar |
| `qr_flutter` | ^4.1.0 | QR generation |
| `mobile_scanner` | ^6.0.5 | QR scanning |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `workmanager` | ^0.28.0 | Background tasks |
| `awesome_notifications` | ^0.9.3+1 | Local notifications |
| `wakelock_plus` | ^1.5.2 | Screen stay-on |
| `image_picker` | ^1.1.2 | Camera/gallery picker |
