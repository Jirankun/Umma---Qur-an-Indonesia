<div align="center">
  <img src="https://img.icons8.com/fluency/96/islam.png" alt="Umma Logo" width="96"/>
  <h1>☪ Umma — Pendamping Ibadah</h1>
  <p><strong>Aplikasi Muslim iOS-style untuk ibadah sehari-hari & Ramadhan</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/iOS%20Style-Cupertino-000000?logo=apple" alt="iOS Style">
    <img src="https://img.shields.io/badge/Kotlin-2.2.20-7F52FF?logo=kotlin" alt="Kotlin">
    <img src="https://img.shields.io/badge/minSdk-24-brightgreen" alt="minSdk">
    <img src="https://img.shields.io/badge/targetSdk-35-brightgreen" alt="targetSdk">
    <img src="https://img.shields.io/badge/compileSdk-36-blue" alt="compileSdk">
    <img src="https://img.shields.io/badge/license-MIT-yellow" alt="License">
  </p>
</div>

---

## 📱 Tentang Umma

**Umma** adalah aplikasi Muslim yang berfokus pada pengalaman iOS-style (Cupertino) — bukan Material Design. Dibangun dengan Flutter, Umma membantu pengguna menjalankan ibadah sehari-hari dan ibadah khusus Ramadhan.

### ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🕌 **Al-Qur'an** | Baca 114 surah + 30 juz, audio 6 qari, tafsir Kemenag RI, bookmark, last read, khatam plan, scroll presisi ke ayat |
| 🤲 **Doa** | 8+ kategori doa (harian, puasa, sholat, taubat, perlindungan, dzikir, asmaul husna), doa kustom, pengaturan baca di screen doa |
| 📖 **Hadits** | 9 kitab dari API hadis-api-id (Bukhari, Muslim, Tirmidzi, dll), pagination, bookmark tab, backup/restore bookmark |
| 📚 **Fiqih** | 47+ topik fiqih Ramadhan (puasa, sholat, zakat, haid, amalan), search dengan fallback |
| 🧮 **Zakat** | Kalkulator: Fitrah, Maal, Penghasilan, Emas & Perak |
| 📿 **Tasbih** | Digital counter dengan history per sesi |
| 🧭 **Kiblat** | Arah kiblat real-time — 1 jarum (jarum Kiblat hijau) dari sensor magnetometer + GPS |
| 📊 **Tracker** | Target ibadah harian: puasa, 5 waktu + tarawih (Ramadhan), tilawah, sedekah |
| 📝 **Jurnal** | Catatan harian dengan kategori: reflektif, gratitude, goal, ramadhan |
| 🌙 **Studi Ramadhan** | 30 hari materi spiritual (hanya saat Ramadhan) |
| 💬 **Muslim AI** | Chat AI (Groq Llama 3.3) — bold markdown, navigasi langsung ke fitur + kembali ke AI, scroll presisi ke card target |
| 👤 **Profil** | Foto profil (gallery/camera), sync device, backup/restore data (JSON + QR), tema gelap/terang, pilih kota |
| 📡 **P2P Sync** | Sync data antar-device via QR code (peer-to-peer) |
| 🔔 **Notifikasi** | Jadwal sholat otomatis 5 waktu + imsak, background service tiap 30 menit |
| 🛌 **Screen Stay-on** | Wakelock aktif saat baca Quran, Doa, Hadits — layar tidak mati |
| 🔊 **Background Sound** | Audio ambient (pagi/siang/malam) otomatis di Beranda, stop saat navigasi keluar |

### 🎯 Target Pengguna

- Muslim Indonesia (bahasa Indonesia penuh)
- 44 kota di seluruh Indonesia
- 3 timezone: WIB (+7), WITA (+8), WIT (+9)

---

## 🏗️ Tech Stack

### Framework & Language

| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| **Flutter** | 3.12+ | Cross-platform UI framework |
| **Dart** | 3.12+ | Bahasa pemrograman |
| **Kotlin** | 2.2.20 | Android native plugin |
| **minSdk** | 24 (Android 7.0) | Minimum Android version |
| **targetSdk** | 35 | Target Android version |
| **compileSdk** | 36 | Compile SDK version |

### Package Dependencies

| Package | Fungsi |
|---------|--------|
| `cupertino_icons` | iOS-style icons (CupertinoIcons) |
| `provider` | State management (ChangeNotifier) |
| `http` | HTTP client untuk API calls |
| `shared_preferences` | Local storage key-value |
| `path_provider` | File path untuk dokumen |
| `geolocator` | GPS location untuk kompas kiblat |
| `sensors_plus` | Magnetometer/accelerometer sensor |
| `audioplayers` | Audio playback untuk murattal Quran & background sound |
| `intl` | Date/time formatting |
| `url_launcher` | Open external links |
| `share_plus` | Share/export data |
| `hijri_date` | Konversi Masehi ke Hijriyah (Umm al-Qura) |
| `qr_flutter` | Generate QR code untuk P2P sync |
| `mobile_scanner` | Scan QR code untuk P2P sync |
| `permission_handler` | Runtime permission management |
| `workmanager` | Background task untuk notifikasi sholat |
| `awesome_notifications` | Local notifications dengan custom channel |
| `wakelock_plus` | Screen stay-on saat baca Quran/Doa/Hadits |
| `image_picker` | Pilih foto profil dari gallery/camera |

### Data Sources (API)

| API | Endpoint | Digunakan Untuk |
|-----|----------|-----------------|
| **EQuran.id API v2** | `https://equran.id/api/v2` | Quran (surah, ayat, tafsir) |
| **EQuran.id Shalat** | `https://equran.id/api/v2/shalat` | Jadwal sholat 44 kota (Kemenag) |
| **Hadis API ID** | `https://hadis-api-id.vercel.app/hadith` | 9 kitab hadits dengan terjemahan |
| **Groq AI** | `https://api.groq.com/openai/v1` | Muslim AI (Llama 3.3 70B) |
| **OpenStreetMap** | `https://nominatim.openstreetmap.org` | Reverse geocoding lokasi |
| **EQuran CDN** | `https://cdn.equran.id/audio-full` | Audio murattal (6 qari) |

### App Identity

| Atribut | Nilai |
|---------|-------|
| **Package name** | `app.umma.aokaze` |
| **App name** | Umma |
| **Version** | 1.0.0+1 |
| **Android namespace** | `app.umma.aokaze` |

---

## 🗂️ Struktur Project

```
umma/
├── lib/
│   ├── main.dart              # Entry point + MultiProvider
│   ├── app.dart               # CupertinoApp + routing
│   ├── config/
│   │   └── api_config.dart    # Semua API key, endpoint, konstanta
│   ├── models/
│   │   ├── models.dart        # PrayerTime, DailyTracker, FiqihItem, dll
│   │   ├── quran.dart         # Surah, Ayat, LastRead, Bookmark
│   │   ├── hadits.dart        # HaditsBook, HaditsItem, Bookmark
│   │   └── doa.dart           # DoaItem
│   ├── providers/
│   │   ├── theme_provider.dart
│   │   ├── prayer_times_provider.dart
│   │   ├── quran_provider.dart
│   │   ├── doa_provider.dart
│   │   ├── hadits_provider.dart
│   │   ├── fiqih_provider.dart
│   │   ├── tracker_provider.dart
│   │   ├── journal_provider.dart
│   │   ├── zakat_provider.dart
│   │   ├── haid_provider.dart
│   │   ├── tasbih_provider.dart
│   │   ├── muslim_ai_provider.dart
│   │   ├── user_provider.dart
│   │   ├── background_sound_provider.dart
│   │   └── update_provider.dart
│   ├── services/
│   │   ├── api_service.dart       # EQuran + Hadits API client
│   │   ├── ai_service.dart        # Groq AI service
│   │   ├── ai_content_service.dart# AI content generator (doa, fiqih, hadits)
│   │   ├── prayer_time_service.dart
│   │   ├── notification_service.dart
│   │   ├── quran_download_service.dart
│   │   ├── quran_tracker_service.dart
│   │   ├── background_service.dart
│   │   └── local_storage.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart          # Main tab bar (4 tabs)
│   │   │   └── widgets/
│   │   │       ├── hero_card.dart        # Prayer times hero
│   │   │       ├── daily_goal_tracker.dart
│   │   │       ├── daily_knowledge_card.dart
│   │   │       ├── tool_grid.dart        # 11 fitur grid
│   │   │       └── quote_card.dart
│   │   ├── quran/
│   │   │   ├── quran_index_screen.dart   # Index surah + juz
│   │   │   ├── surah_reader_screen.dart  # Reader per surah (+wakelock)
│   │   │   └── juz_reader_screen.dart    # Reader per juz (+wakelock)
│   │   ├── doa/doa_home_screen.dart      # +DoaListScreen (+wakelock)
│   │   ├── hadits/hadits_home_screen.dart # +HaditsReaderScreen (+wakelock)
│   │   ├── fiqih/fiqih_home_screen.dart
│   │   ├── zakat/zakat_screen.dart
│   │   ├── tasbih/tasbih_screen.dart
│   │   ├── tracker/tracker_screen.dart
│   │   ├── jurnal/jurnal_dashboard_screen.dart
│   │   ├── haid/haid_tracker_screen.dart
│   │   ├── kompas/kompas_screen.dart
│   │   ├── study/study_screen.dart
│   │   ├── muslim_ai/muslim_ai_screen.dart # Chat AI + bold + scroll
│   │   ├── user/user_profile_screen.dart   # Foto profil, pilih kota
│   │   ├── sync/p2p_sync_screen.dart
│   │   └── _shared/
│   │       └── cupertino_progress_bar.dart
│   ├── data/
│   │   ├── doa_data.dart        # 8+ kategori doa
│   │   ├── fiqih_data.dart      # 47 topik fiqih offline
│   │   ├── hadits_data.dart     # 33 hadits Ramadhan
│   │   ├── quotes_data.dart     # 60+ quotes Islami
│   │   ├── study_data.dart      # 30 hari materi Ramadhan
│   │   └── juz_mapping.dart     # Mapping surah ke juz
│   └── utils/
│       └── date_helper.dart     # Helper tanggal Hijriyah
├── assets/
│   └── font/
│       ├── Lateef-Regular.ttf
│       └── ScheherazadeNew-Regular.ttf
├── android/
│   ├── app/build.gradle.kts
│   ├── build.gradle.kts
│   └── settings.gradle.kts
└── test/
    └── widget_test.dart
```

---

## 🚀 Alur Aplikasi

### 1. Startup Flow

```
main() 
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── AwesomeNotifications.initialize()        → Channel: umma_prayer_times
  ├── NotificationService.initialize()         → WorkManager background task
  ├── NotificationService.startBackgroundCheck()→ Cek jadwal sholat tiap 30 menit
  ├── LocalStorage.init()                      → Inisialisasi shared_preferences
  ├── SharedPreferences.getInstance()          → Baca tema tersimpan
  ├── MultiProvider (14+ providers)
  │   ├── ThemeProvider          (dark/light mode)
  │   ├── PrayerTimesProvider    (jadwal sholat 44 kota)
  │   ├── QuranProvider          (data surah, audio, bookmark, last read)
  │   ├── DoaProvider            (bookmark, doa kustom, settings)
  │   ├── HaditsProvider         (9 kitab, bookmark, settings)
  │   ├── FiqihProvider          (online + 47 offline fallback)
  │   ├── TrackerProvider        (target harian + Ramadhan stats)
  │   ├── JournalProvider        (catatan harian)
  │   ├── ZakatProvider          (kalkulator 4 jenis zakat)
  │   ├── HaidProvider           (log siklus haid)
  │   ├── TasbihProvider         (counter dzikir)
  │   ├── MuslimAiProvider       (chat history)
  │   ├── UserProvider           (profil + custom habits)
  │   ├── BackgroundSoundProvider (audio ambient)
  │   └── UpdateProvider         (cek update dari GitHub)
  └── UmmaApp() → CupertinoApp
      └── HomeScreen() → PageView (4 tabs)
          ├── Tab 0: Beranda  (_HomeContent)
          ├── Tab 1: Quran   (QuranIndexScreen)
          ├── Tab 2: Doa     (DoaHomeScreen)
          └── Tab 3: Akun    (UserProfileScreen)
```

### 2. Navigation Flow

```
HomeScreen (4 tabs — PageView)
  │
  ├── Beranda Tab
  │   ├── HeroCard → Prayer times + countdown
  │   ├── LastReadCard → SurahReaderScreen / JuzReaderScreen (scroll ke ayat)
  │   ├── ToolGrid (11 tools + FAB Arbain)
  │   │   ├── Al-Qur'an  → QuranIndexScreen
  │   │   ├── Doa        → DoaHomeScreen
  │   │   ├── Hadits     → HaditsHomeScreen
  │   │   ├── Fiqih      → FiqihHomeScreen
  │   │   ├── Zakat      → ZakatScreen
  │   │   ├── Tasbih     → TasbihScreen
  │   │   ├── Kiblat     → KompasScreen (1 jarum kiblat)
  │   │   ├── Muslim AI  → MuslimAiScreen
  │   │   ├── Tracker    → TrackerScreen
  │   │   ├── Jurnal     → JurnalDashboardScreen
  │   │   └── Haid       → HaidTrackerScreen
  │   └── DailyKnowledgeCard → Hadits / Quotes AI
  │
  ├── Quran Tab → QuranIndexScreen
  │   ├── Search surah → fallback message
  │   ├── Tap surah → SurahReaderScreen (scroll presisi + wakelock)
  │   │   ├── Audio player (6 qari)
  │   │   ├── Settings (arab font size, mode hafalan)
  │   │   ├── Tafsir bottom sheet
  │   │   └── Last read → session end modal
  │   └── Juz tab → JuzReaderScreen (scroll presisi + wakelock)
  │
  ├── Doa Tab → DoaHomeScreen
  │   ├── 8 kategori doa + search
  │   ├── Tap kategori → DoaListScreen (pengaturan baca DI SINI)
  │   ├── Bookmark doa (badge jumlah)
  │   └── Tambah doa kustom
  │
  └── Akun Tab → UserProfileScreen
      ├── Foto profil (gallery/camera, base64, ikut backup)
      ├── Edit profil → nama, kota (pencarian dengan fallback)
      ├── Backup & restore data (JSON)
      ├── P2P Sync → QR code
      ├── Tema (terang/gelap)
      ├── Export data JSON
      └── Bantuan, Privasi, Tentang
```

### 3. Muslim AI Navigation

```
User di MuslimAiScreen
  ├── AI respon dengan marker [Buka:screen:param]
  ├── User tap tombol "Buka ..."
  ├── Audio stop: background sound + Quran audio
  └── Push target screen DI ATAS AI (bukan ganti)
      └── User back → kembali ke AI (chat tetap tersimpan)
          └── User back lagi → kembali ke Beranda

Scroll presisi dari AI:
  ├── [Buka:quran:SURAH:AYAH] → SurahReaderScreen → scroll ke ayat (tengah layar)
  ├── [Buka:hadits:SLUG:NUM]  → HaditsReaderScreen → scroll ke hadits (tengah)
  ├── [Buka:doa:ID]           → DoaListScreen (langsung ke kategori)
  └── Semua menggunakan Scrollable.ensureVisible(alignment: 0.5)
```

### 4. Fitur Ramadhan (Hanya Saat Ramadhan)

| Fitur | Cara Gate | Keterangan |
|-------|-----------|------------|
| **Studi Ramadhan** (StudyScreen) | `DateHelper.isRamadhanSeason()` | Screen hanya bisa diakses saat Ramadhan |
| **Zakat Fitrah** (ZakatScreen) | `DateHelper.isRamadhanSeason()` | Card Zakat Fitrah disembunyikan di luar Ramadhan |
| **Sholat Tarawih** (TrackerScreen) | `DateHelper.isRamadhanSeason()` | Item tracker Tarawih hanya muncul saat Ramadhan |
| **Tracker stats** (TrackerProvider) | `DateHelper.isCurrentlyRamadhan()` | Statistik Ramadhan terpisah |
| **HeroCard badge** | `DateHelper.isRamadhanSeason()` | Badge "Ramadhan 1447 H" |
| **DailyKnowledgeCard** | `DateHelper.isRamadhanSeason()` | Konten hadits Ramadhan vs umum |
| **AI Content** | `DateHelper.isRamadhanSeason()` | Konten AI disesuaikan musim |

---

## 🧠 Muslim AI

Muslim AI menggunakan **Groq Cloud** dengan model **Llama 3.3 70B Versatile**.

### Fitur Khusus
- **Bold markdown** — `**teks**` → teks tebal di chat bubble
- **[Buka:screen:param]** — AI bisa output marker untuk navigasi
  - `[Buka:quran:1:7]` → Buka Surah Al-Fatihah Ayat 7 (scroll presisi)
  - `[Buka:doa:doa-taubat]` → Buka Doa Taubat
  - `[Buka:surah:36]` → Buka Surah Yaasin
  - `[Buka:hadits:muslim:20]` → Buka Hadits Muslim #20
  - `[Buka:fiqih:1]` → Buka Fiqih
  - `[Buka:zakat]` → Buka Zakat
  - `[Buka:tasbih]` → Buka Tasbih
  - `[Buka:tracker]` → Buka Tracker
  - `[Buka:jurnal]` → Buka Jurnal
- **[Cari:QUERY]** — Google Search untuk topik di luar fitur Umma
- **Navigasi**: push target di atas AI → back ke AI (chat tetap ada)
- **Audio cleanup**: stop background sound + Quran audio sebelum navigasi
- **Scroll presisi**: `Scrollable.ensureVisible(alignment: 0.5)` untuk card target di tengah layar

### Mode Chat

| Mode | ID | Kegunaan | Max Tokens |
|------|----|----------|------------|
| Ngobrol | `ngobrol` | Obrolan santai | 512 |
| Cari Doa | `doa` | Referensi doa spesifik | 256 |
| Cari Surah | `surah` | Referensi ayat Al-Qur'an | 256 |
| Tanya Fiqih | `fiqih` | Hukum/ fiqih Islam | 256 |
| Cari Hadits | `hadits` | Referensi hadits | 256 |

---

## 🔐 Konfigurasi

### Environment Variables

| Variable | Deskripsi | Default |
|----------|-----------|---------|
| `GROQ_API_KEY` | API key untuk Groq AI | (embedded key) |

### Android Permissions

| Permission | Kegunaan |
|------------|----------|
| `INTERNET` | API calls |
| `ACCESS_FINE_LOCATION` | Kompas kiblat (GPS) |
| `ACCESS_COARSE_LOCATION` | Kompas kiblat |
| `ACCESS_BACKGROUND_LOCATION` | Notifikasi sholat background |
| `CAMERA` | QR scanner P2P sync + foto profil |
| `POST_NOTIFICATIONS` (Android 13+) | Notifikasi sholat |
| `RECEIVE_BOOT_COMPLETED` | Reschedule notifikasi setelah reboot |
| `VIBRATE` | Notifikasi dengan vibrasi |
| `READ_EXTERNAL_STORAGE` | Backup data, foto profil |
| `WRITE_EXTERNAL_STORAGE` | Backup data, foto profil |

---

## 🛠️ Development

### Prerequisites

- Flutter SDK 3.12+
- Dart SDK 3.12+
- Android Studio / VS Code
- Java 17+ (untuk Android build)
- Chrome (untuk debugging web)

### Cara Run

```bash
cd umma
flutter pub get
flutter run
```

### Build APK

```bash
cd umma
flutter build apk --release
```

### Build dengan Custom API Key

```bash
cd umma
flutter run --dart-define=GROQ_API_KEY=gsk_your_key_here
```

### Analisis Kode

```bash
cd umma
flutter analyze
```

### Screen Stay-on (Wakelock)

Wakelock aktif otomatis di screen baca:
- SurahReaderScreen
- JuzReaderScreen
- DoaHomeScreen & DoaListScreen
- HaditsArbainScreen
- HaditsReaderScreen

Wakelock mati otomatis saat user keluar dari screen tersebut.

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah **MIT License**.

---

<div align="center">
  <p>Dibuat dengan ❤️ untuk umat Muslim Indonesia</p>
  <p><strong>☪ Umma v1.0.0</strong></p>
</div>
