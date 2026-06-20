# 📂 Struktur Project Umma

Dokumentasi ini disusun berdasarkan struktur folder yang ada di repo.

---

## Root (umma/)

```text
umma/
├── android/                          # Konfigurasi Android native
├── assets/
│   ├── audio/
│   │   ├── bg_night.mp3             # Background sound malam
│   │   └── bg_sunrise.mp3           # Background sound siang
│   ├── font/
│   │   ├── Lateef-Regular.ttf       # Font arab
│   │   └── ScheherazadeNew-Regular.ttf
│   └── generated/                   # JSON hasil generator (AI/fiqih/hadits/quotes)
├── lib/
│   ├── main.dart                     # entry point + inisialisasi notifikasi & provider
│   ├── app.dart                      # CupertinoApp + routes
│   ├── config/                      # konfigurasi (API/AI/warna/strings)
│   ├── providers/                   # state management (ChangeNotifier)
│   ├── services/                    # integrasi bisnis: API, AI, storage, notifikasi
│   ├── data/                        # data/fallback tertentu
│   ├── utils/                       # helper (mis. Hijri/Ramadhan)
│   └── screens/                     # seluruh halaman/UI
│       ├── home/
│       ├── quran/
│       ├── doa/
│       ├── hadits/
│       ├── fiqih/
│       ├── zakat/
│       ├── tasbih/
│       ├── tracker/
│       ├── jurnal/
│       ├── haid/
│       ├── kompas/
│       ├── muslim_ai/
│       ├── user/
│       ├── study/
│       └── sync/
├── test/
│   └── widget_test.dart
├── pubspec.yaml
├── README.md
└── TODO.md
```

---

## 🧠 Arsitektur Tingkat Tinggi

Pola umum aplikasi:

- **UI Layer**: `lib/screens/**`
- **State Layer**: `lib/providers/**` (ChangeNotifier + `notifyListeners()`)
- **Service Layer**: `lib/services/**` (API/AI/storage/notifikasi)
- **Config/Utils/Data**: `lib/config/**`, `lib/utils/**`, `lib/data/**`, serta `assets/generated/**`

---

## 🔁 Alur Startup (main.dart)

Di `lib/main.dart`:

1. Inisialisasi Flutter binding
2. Inisialisasi **AwesomeNotifications**
3. Inisialisasi `NotificationService` lalu jalankan background check jadwal sholat
4. Inisialisasi `LocalStorage` (wrapper shared_preferences)
5. Memuat Groq API key dari storage (jika ada)
6. `runApp()` dengan `MultiProvider` (ThemeProvider, PrayerTimesProvider, QuranProvider, dst)
7. Menampilkan `UmmaApp()`

---

## 📍 Routes & Navigasi (app.dart)

Routes ada di `lib/app.dart`:

- `'/quran'` → `QuranIndexScreen`
- `'/doa'` → `DoaHomeScreen`
- `'/hadits'` → `HaditsHomeScreen`
- `'/fiqih'` → `FiqihHomeScreen`
- `'/zakat'` → `ZakatScreen`
- `'/tasbih'` → `TasbihScreen`
- `'/kompas'` → `KompasScreen`
- `'/muslim-ai'` → `MuslimAiScreen`
- `'/tracker'` → `TrackerDashboardScreen`
- `'/tracker-harian'` → `TrackerScreen`
- `'/jurnal'` → `JurnalDashboardScreen`
- `'/haid'` → `HaidTrackerScreen`
- `'/user'` → `UserProfileScreen`
- `'/study'` → `StudyScreen`
- `'/sync-p2p'` → `P2pSyncScreen`

---

## 🏠 HomeScreen & Kontrol Background Sound

`lib/screens/home/home_screen.dart` mengatur:

- **Tab utama**: Beranda, Al-Qur’an, Doa, Akun (4 tab)
- Start/stop background sound:
  - start saat tab Beranda
  - stop saat pindah tab atau navigasi keluar Beranda
  - stop saat aplikasi dipause (`AppLifecycleState.paused`)

Alur ini penting untuk konsistensi dokumentasi.

---

## 🧾 Catatan Dokumentasi

- Dokumentasi ini menghindari “angka klaim” yang tidak terlihat langsung dari kode/asset.
- Jika kamu ingin klaim angka (mis. jumlah item dalam suatu fitur) ditampilkan, saya bisa menurunkannya dari JSON/generator di folder `assets/generated/` atau dari provider/service terkait.
