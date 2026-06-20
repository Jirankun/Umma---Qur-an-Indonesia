<div align="center">
  <img src="https://img.icons8.com/fluency/96/islam.png" alt="Umma Logo" width="96"/>
  <h1>☪ Umma — Pendamping Ibadah</h1>
  <p><strong>Aplikasi Muslim iOS-style untuk ibadah sehari-hari & kebutuhan Ramadhan</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/iOS%20Style-Cupertino-000000?logo=apple" alt="iOS Style">
    <img src="https://img.shields.io/badge/minSdk-24-brightgreen" alt="minSdk">
    <img src="https://img.shields.io/badge/license-MIT-yellow" alt="License">
  </p>
</div>

---

## 📌 Ringkasan

**Umma** adalah aplikasi Flutter dengan gaya iOS (Cupertino). Aplikasi ini menyediakan navigasi utama berbasis **4 tab** dan fitur-fitur ibadah, seperti jadwal sholat, bacaan Al-Qur’an (surah & juz), doa, hadits, fiqih, zakat, tasbih, tracker ibadah, jurnal, haid, kompas kiblat, Muslim AI, serta sinkronisasi data via QR.

> Catatan: Angka klaim seperti jumlah surah/juz/qari/kitab, serta daftar endpoint API spesifik, tidak saya hardcode jika tidak terlihat jelas dari kode/asset yang ada. Dokumentasi ini dibuat mengikuti struktur file dan alur yang ada di repo.

---

## 🧩 Fitur Utama (sesuai struktur kode)

Dari struktur `lib/` dan routes di `lib/app.dart`, fitur utama yang disediakan meliputi:

- **Beranda** (`HomeScreen`)
  - Menampilkan ringkasan waktu sholat & countdown.
  - Menampilkan kartu “lanjut baca” (menggunakan data `lastRead`).
  - Menampilkan grid menu menuju screen fitur lain.
  - Memiliki FAB “Hadits An-Nawawiyyah” (route `'/arbain'`).
- **Al-Qur’an**
  - Index surah/juz: `QuranIndexScreen`
  - Reader surah: `SurahReaderScreen`
  - Reader juz: `JuzReaderScreen`
- **Doa**
  - Home doa: `DoaHomeScreen`
- **Hadits**
  - Home hadits: `HaditsHomeScreen`
  - Hadits An-Nawawiyyah: `HaditsArbainScreen`
- **Fiqih**
  - `FiqihHomeScreen`
- **Zakat**
  - `ZakatScreen`
- **Tasbih**
  - `TasbihScreen`
- **Kompas Kiblat**
  - `KompasScreen`
- **Tracker**
  - Dashboard: `TrackerDashboardScreen`
  - Tracker harian: `TrackerScreen`
- **Jurnal**
  - Dashboard: `JurnalDashboardScreen`
- **Haid**
  - `HaidTrackerScreen`
- **Study Ramadhan**
  - `StudyScreen` (route `'/study'`)
- **Muslim AI**
  - `MuslimAiScreen`
- **Profil & Sinkronisasi**
  - `UserProfileScreen`
  - Sinkronisasi P2P via QR: `P2pSyncScreen` (route `'/sync-p2p'`)

---

## 🗂️ Struktur Project

Struktur utama folder mengikuti kode Flutter standar:

```text
lib/
  main.dart                          # entry point + MultiProvider
  app.dart                           # CupertinoApp + routes
  config/
    api_config.dart
    ai_config.dart
    colors.dart / strings.dart
  providers/
  services/
  data/
  utils/
  screens/
    home/
    quran/
    doa/
    hadits/
    fiqih/
    zakat/
    tasbih/
    tracker/
    jurnal/
    haid/
    kompas/
    muslim_ai/
    user/
    study/
    sync/
assets/
  audio/bg_night.mp3
  audio/bg_sunrise.mp3
  font/Lateef-Regular.ttf
  font/ScheherazadeNew-Regular.ttf
  generated/...
android/
  (konfigurasi Android)
test/
  widget_test.dart
```

---

## 🔐 Background Sound (sesuai implementasi)

Background sound dikendalikan melalui `BackgroundSoundProvider`.

- Dimulai saat user berada di **tab Beranda**.
- Dihentikan saat user berpindah tab.
- Dihentikan juga ketika navigasi keluar dari Beranda.
- Saat aplikasi di-minimize (`AppLifecycleState.paused`), sound dihentikan.

File referensi: `lib/screens/home/home_screen.dart`.

Audio yang disediakan di `assets/audio/`:
- `bg_sunrise.mp3`
- `bg_night.mp3`

---

## 🧠 Muslim AI

Muslim AI ada pada `MuslimAiScreen` dan dijalankan lewat layanan di `lib/services/ai_service.dart`.

Konten AI berhubungan dengan navigasi ke fitur lain sesuai marker/logic yang di-implementasikan di screen.

---

## 🧱 Dependency & Asset (mengacu `pubspec.yaml`)

### Package dependencies penting

Berikut dependency yang terdaftar di `pubspec.yaml` (contoh):
- `provider`
- `http`
- `shared_preferences`
- `geolocator`
- `sensors_plus`
- `audioplayers`
- `wakelock_plus`
- `qr_flutter`, `mobile_scanner`
- `permission_handler`
- `workmanager` dan `awesome_notifications`
- `hijri_date`

### Fonts

- `assets/font/Lateef-Regular.ttf` (family: `Lateef`)
- `assets/font/ScheherazadeNew-Regular.ttf` (family: `ScheherazadeNew`)

### Assets

- `assets/audio/` di-include di `pubspec.yaml`

---

## 🚀 Cara Menjalankan

```bash
cd umma
flutter pub get
flutter run
```

---

## 📍 Routes Utama

Routes didefinisikan di `lib/app.dart`. Contoh route:
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

## 📝 Catatan Pengembangan

- Format dokumentasi ini dibuat agar mengikuti struktur file dan alur yang ada di repo.
- Beberapa klaim angka yang sebelumnya ada di README versi lama dihilangkan/dinetralisir jika tidak tampak jelas di repo (mis. jumlah item tertentu dari file generator atau API) untuk mencegah dokumentasi “ngarang”.

