# 📂 Struktur Project Umma — Dokumentasi Lengkap

Dokumentasi ini menyajikan struktur folder, file, dan arsitektur project Umma secara detail dan menyeluruh.

---

## 🗂️ Root Directory

```
umma/
├── android/                          # Konfigurasi native Android
│   ├── app/
│   │   ├── build.gradle.kts          # Build config (minSdk 24, targetSdk 34)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # Izin: location, camera, notification, storage
│   │       └── kotlin/app/umma/aokaze/
│   │           ├── MainActivity.kt   # Entry point Activity
│   │           └── SplashActivity.kt # Native splash screen
│   ├── build.gradle.kts              # Root build config
│   ├── settings.gradle.kts           # Project settings
│   └── gradle.properties             # Gradle properties
│
├── assets/                           # Assets aplikasi
│   ├── audio/
│   │   ├── bg_night.mp3             # Background sound malam
│   │   └── bg_sunrise.mp3           # Background sound pagi/siang
│   ├── font/
│   │   ├── ScheherazadeNew-Regular.ttf  # Font Arab utama (Quran)
│   │   └── Lateef-Regular.ttf           # Font Arab alternatif
│   ├── video/                        # Video background untuk Home hero card
│   ├── update/
│   │   └── update_infos.txt         # Riwayat update aplikasi
│   └── generated/                    # Konten AI generated (cache/fallback)
│       ├── hadits/ai_hadits_items.json
│       ├── fiqih/ai_fiqih_items.json
│       └── quotes/ai_quotes_items.json
│
├── test/
│   └── widget_test.dart             # Test widget dasar
│
├── lib/                             # 📱 KODE UTAMA APLIKASI
├── pubspec.yaml                     # Dependencies & assets declarations
├── analysis_options.yaml            # Linter rules
├── README.md                        # Dokumentasi utama
├── struktur.md                      # Dokumentasi ini
├── TODO.md                          # Rencana pengembangan
├── LICENSE                          # MIT License
└── .gitignore                       # Git ignore rules
```

---

## 📱 lib/ — Kode Inti Aplikasi

```
lib/
├── main.dart                         # 🟢 Entry point aplikasi
├── app.dart                          # 🟢 CupertinoApp + routes + onboarding check
│
├── config/                           # ⚙️ Konfigurasi global
│   ├── api_config.dart               #   Endpoint API (Quran, Hadits, Sholat)
│   ├── ai_config.dart                #   Konfigurasi Groq AI (model, API key, system prompt)
│   ├── colors.dart                   #   Semua warna aplikasi (AppColors)
│   └── strings.dart                  #   Semua teks UI (AppStrings) — terpusat
│
├── models/                           # 📦 Model data
│   ├── models.dart                   #   Surah, Ayat, PrayerTime, dll
│   ├── quran.dart                    #   Model Quran spesifik
│   ├── hadits.dart                   #   HaditsBook, HaditsItem
│   └── doa.dart                      #   DoaItem, DoaCategory
│
├── providers/                        # 🧠 State Management (ChangeNotifier)
│   ├── theme_provider.dart           #   Tema Light/Dark
│   ├── prayer_times_provider.dart    #   Jadwal sholat harian
│   ├── quran_provider.dart           #   Data Quran, audio, progress
│   ├── doa_provider.dart             #   Doa, bookmark, kategori
│   ├── hadits_provider.dart          #   Kitab hadits, bookmark, search
│   ├── fiqih_provider.dart           #   Fiqih offline, filter kategori
│   ├── tracker_provider.dart         #   Tracker ibadah harian
│   ├── journal_provider.dart         #   Jurnal refleksi
│   ├── zakat_provider.dart           #   Kalkulator zakat
│   ├── haid_provider.dart            #   Tracker siklus haid
│   ├── tasbih_provider.dart          #   Dzikir digital counter
│   ├── muslim_ai_provider.dart       #   Muslim AI chat + cooldown
│   ├── user_provider.dart            #   Profil user
│   ├── background_sound_provider.dart #   Background sound kontrol
│   └── update_provider.dart          #   Cek update aplikasi
│
├── services/                         # 🔧 Layanan bisnis & integrasi
│   ├── api_service.dart              #   HTTP client: Quran, Hadits, Sholat, Tafsir
│   ├── ai_service.dart               #   Groq API untuk Muslim AI Chat
│   ├── ai_content_service.dart       #   Generate konten AI (quotes, quest, nasehat)
│   ├── quran_download_service.dart   #   Download & cache audio Quran
│   ├── prayer_time_service.dart      #   Fetch & parse jadwal sholat
│   ├── notification_service.dart     #   Notifikasi waktu sholat (WorkManager)
│   ├── background_service.dart       #   Service background periodik
│   ├── update_service.dart           #   Cek versi terbaru
│   ├── quran_tracker_service.dart    #   Tracker bacaan Quran (last read, bookmark)
│   └── local_storage.dart            #   Wrapper SharedPreferences + import/export
│
├── data/                             # 📊 Data offline
│   ├── fiqih_data.dart               #   40+ materi fiqih detail (Thaharah-Jenazah)
│   ├── doa_data.dart                 #   10+ kategori doa & dzikir
│   ├── hadits_data.dart              #   9 kitab hadits
│   ├── hadits_arbain_data.dart       #   42 hadits Arba'in An-Nawawiyyah
│   ├── quotes_data.dart              #   Quotes Islami offline
│   ├── study_data.dart               #   Materi studi Ramadhan (30 hari)
│   └── juz_mapping.dart              #   Mapping surah → juz
│
├── utils/                            # 🛠️ Helper & utility
│   └── date_helper.dart              #   Helper tanggal (Hijriah, Ramadhan, dll)
│
└── screens/                          # 🖥️ Semua halaman UI
    ├── home/                         # 🏠 Beranda (Tab 1)
    │   ├── home_screen.dart          #   Halaman utama + 4 tab navigasi
    │   └── widgets/
    │       ├── hero_card.dart        #   Kartu sambutan + video background
    │       ├── daily_knowledge_card.dart  #   Pengetahuan harian
    │       ├── tool_grid.dart        #   Grid 12 fitur utama
    │       ├── daily_goal_tracker.dart    #   Target ibadah harian
    │       ├── daily_quest_card.dart #   Quest harian
    │       ├── quote_card.dart       #   Quotes Islami
    │       └── update_popup.dart     #   Popup update aplikasi
    │
    ├── quran/                        # 📖 Al-Qur'an
    │   ├── quran_index_screen.dart   #   Index surah & juz (grid/list)
    │   ├── surah_reader_screen.dart  #   Reader surah (ayat, audio, tafsir)
    │   ├── juz_reader_screen.dart    #   Reader per juz
    │   └── widgets/
    │       └── khatam_plan_widget.dart   #   Program khatam 30 hari
    │
    ├── doa/                          # 🤲 Doa & Dzikir
    │   └── doa_home_screen.dart      #   Kumpulan doa + bookmark + search
    │
    ├── hadits/                       # 📜 Hadits
    │   ├── hadits_home_screen.dart   #   Kumpulan kitab + search + bookmark
    │   └── hadits_arbain_screen.dart #   42 Hadits Arba'in (toggle arab, font)
    │
    ├── fiqih/                        # ⚖️ Fiqih Islam
    │   └── fiqih_home_screen.dart    #   12 kategori fiqih + tab "Semua" + search
    │
    ├── zakat/                        # 💰 Zakat
    │   └── zakat_screen.dart         #   Kalkulator zakat (4 jenis)
    │
    ├── tasbih/                       # 📿 Tasbih Digital
    │   └── tasbih_screen.dart        #   Counter dzikir + target
    │
    ├── kompas/                       # 🧭 Arah Kiblat
    │   └── kompas_screen.dart        #   Kompas real-time + kalibrasi
    │
    ├── muslim_ai/                    # 🤖 Muslim AI
    │   └── muslim_ai_screen.dart     #   AI Chat (5 mode) + navigasi
    │
    ├── tracker/                      # 📊 Tracker Ibadah
    │   ├── tracker_screen.dart       #   Tracker harian (sholat, puasa, dll)
    │   └── tracker_dashboard_screen.dart  #   Dashboard kalender + statistik
    │
    ├── jurnal/                       # 📝 Jurnal Refleksi
    │   └── jurnal_dashboard_screen.dart   #   Jurnal (4 kategori) + CRUD
    │
    ├── haid/                         # 🩸 Haid Tracker
    │   └── haid_tracker_screen.dart  #   Siklus haid + riwayat
    │
    ├── study/                        # 🕌 Studi Ramadhan
    │   └── study_screen.dart         #   Materi 30 hari (eksklusif Ramadhan)
    │
    ├── sync/                         # 🔄 Sinkronisasi P2P
    │   └── p2p_sync_screen.dart      #   QR Code + Backup File transfer
    │
    ├── user/                         # 👤 Profil & Pengaturan
    │   └── user_profile_screen.dart  #   Profil, tema, backup, AI settings, dll
    │
    ├── onboarding/                   # 🎬 Onboarding
    │   └── onboarding_screen.dart    #   3 slide pengenalan (first launch)
    │
    └── _shared/                      # 🔄 Widget bersama
        └── cupertino_progress_bar.dart  #   Progress bar reusable
```

---

## 🔁 Arsitektur & Alur Data

### 1. Startup Flow (`main.dart`)
```
main()
├── WidgetsFlutterBinding.ensureInitialized()
├── AwesomeNotifications().initialize()          # Inisialisasi notifikasi
├── NotificationService().initialize()           # Register WorkManager
├── NotificationService().startBackgroundCheck() # Jadwal background sholat
├── LocalStorage().init()                        # Inisialisasi storage
├── Muat Groq API key dari storage               # API key AI
├── SharedPreferences.getInstance()              # Theme preferences
└── runApp(MultiProvider(...))                   # 16 Provider + UmmaApp
```

### 2. Routing (`app.dart`)
```
UmmaApp (StatefulWidget)
├── _checkOnboarding() → cek 'umma_onboarding_done'
├── home: OnboardingScreen (first launch) / HomeScreen (selanjutnya)
└── routes: 15 route bernama ke semua screen utama
```

### 3. Navigation Flow
```
HomeScreen (4 Tab)
├── Tab 1: Beranda (Hero + Grid + Tracker + Quotes)
├── Tab 2: Al-Qur'an → QuranIndexScreen
├── Tab 3: Doa → DoaHomeScreen
└── Tab 4: Akun → UserProfileScreen

Dari Grid Menu:
├── Quran → QuranIndexScreen
├── Doa → DoaHomeScreen
├── Hadits → HaditsHomeScreen
├── Fiqih → FiqihHomeScreen
├── Zakat → ZakatScreen
├── Tasbih → TasbihScreen
├── Kiblat → KompasScreen
├── Muslim AI → MuslimAiScreen
├── Tracker → TrackerDashboardScreen
├── Jurnal → JurnalDashboardScreen
├── Haid → HaidTrackerScreen
└── Studi → StudyScreen

Dari FAB:
└── Hadits Arba'in → HaditsArbainScreen
```

### 4. State Management Pattern
```dart
// Setiap provider mengikuti pola:
class ExampleProvider extends ChangeNotifier {
  // State private
  List<Item> _items = [];
  
  // Getter public
  List<Item> get items => _items;
  
  // Method untuk update state
  void loadData() {
    // fetch/load data
    _items = [...];
    notifyListeners(); // trigger UI rebuild
  }
}

// Di UI:
Consumer<ExampleProvider>(
  builder: (context, provider, _) => Widget(
    data: provider.items,
  ),
)
```

---

## 🎨 Tema & Styling

- **iOS Style penuh**: Menggunakan widget Cupertino (CupertinoPageScaffold, CupertinoNavigationBar, CupertinoTextField, dll)
- **Dark Mode support**: Semua screen mendukung tema gelap/terang via `ThemeProvider`
- **Warna terpusat**: Semua warna di `AppColors` (lib/config/colors.dart) — 200+ color constants
- **String terpusat**: Semua teks UI di `AppStrings` (lib/config/strings.dart) — 300+ string constants

---

## 📦 API Eksternal

| API | Endpoint | Fungsi | Format Response |
|-----|----------|--------|-----------------|
| EQuran.id | `/surah`, `/surah/{n}`, `/ayat`, `/tafsir/{n}` | Data Quran (surah, ayat, tafsir) | JSON |
| EQuran.id | `/juz/{n}` | Data per juz | JSON |
| Hadits API | `/books`, `/book/{slug}/{n}` | Kitab & hadits | JSON |
| MyRamadhan API | Tergantung implementasi | Konten Ramadhan | JSON |
| Groq API | `/v1/chat/completions` | Muslim AI Chat (Llama 3.3 70B) | JSON (OpenAI-compatible) |
| Prayer Time API | Berdasarkan koordinat | Jadwal sholat harian | JSON |

---

## 🔐 Izin Aplikasi (Android)

```xml
<!-- AndroidManifest.xml -->
INTERNET                          # API requests
ACCESS_FINE_LOCATION              # GPS untuk lokasi sholat & kompas
ACCESS_COARSE_LOCATION            # Lokasi kasar
CAMERA                            # Scan QR & foto profil
RECORD_AUDIO                      # (cadangan)
POST_NOTIFICATIONS                # Notifikasi sholat
FOREGROUND_SERVICE                # Background service
RECEIVE_BOOT_COMPLETED            # Restart service setelah reboot
VIBRATE                           # Haptic feedback
WAKE_LOCK                         # Jaga proses background
```

---

## 📊 Provider Dependencies

```
ThemeProvider           → Tidak ada dependensi
PrayerTimesProvider     → UserProvider (city)
QuranProvider           → QuranDownloadService
DoaProvider             → LocalStorage
HaditsProvider          → ApiService, LocalStorage
FiqihProvider           → (data offline)
TrackerProvider         → LocalStorage
JournalProvider         → LocalStorage
ZakatProvider           → LocalStorage
HaidProvider            → LocalStorage
TasbihProvider          → LocalStorage
MuslimAiProvider        → AiService, LocalStorage
UserProvider            → LocalStorage
BackgroundSoundProvider → SharedPreferences
UpdateProvider          → UpdateService
```

---

## 🧪 Testing

- File: `test/widget_test.dart`
- Test widget dasar menggunakan `flutter_test`
- Jalankan: `flutter test`

---

## 🔄 Build & Deploy

```bash
# Development
flutter run                              # Run di emulator/device
flutter run --release                    # Run release mode

# Android
flutter build apk --release              # Build APK
flutter build appbundle --release        # Build AAB (Play Store)

# Analysis
flutter analyze                          # Static analysis
dart format .                            # Format kode
```

---

## 📝 Catatan Pengembangan

1. **Local-First**: Semua data utama disimpan di SharedPreferences via `LocalStorage`
2. **Cupertino Only**: Aplikasi menggunakan Cupertino widgets secara eksklusif (tidak ada Material widgets)
3. **Offline Support**: Quran (teks), Hadits (teks), Doa, Fiqih, Quotes bisa diakses offline
4. **Internet Required**: Muslim AI, jadwal sholat (update), audio Quran (download), konten AI
5. **Single Activity**: Android menggunakan single Activity pattern (MainActivity)
6. **Konten Generated**: Konten AI untuk quotes, nasehat, quest digenerate otomatis oleh `AiContentService`

---

<p align="center">📜 Dokumentasi ini diperbarui secara berkala mengikuti perkembangan kode.</p>
