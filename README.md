<div align="center">
  <img src="https://img.icons8.com/fluency/96/islam.png" alt="Umma Logo" width="96"/>
  <h1>☪ Umma — Pendamping Ibadah Muslim</h1>
  <p><strong>Aplikasi Flutter iOS-style (Cupertino) untuk ibadah sehari-hari & kebutuhan Ramadhan</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-3.12+-02569B?logo=flutter" alt="Flutter">
    <img src="https://img.shields.io/badge/Dart-3.12+-0175C2?logo=dart" alt="Dart">
    <img src="https://img.shields.io/badge/iOS%20Style-Cupertino-000000?logo=apple" alt="iOS Style">
    <img src="https://img.shields.io/badge/minSdk-24-brightgreen" alt="minSdk">
    <img src="https://img.shields.io/badge/license-MIT-yellow" alt="License">
    <img src="https://img.shields.io/badge/100%25%20Gratis-Tanpa%20Iklan-success" alt="Gratis">
  </p>
</div>

---

## 📖 Tentang Umma

**Umma** adalah aplikasi Muslim all-in-one yang dirancang untuk membantu ibadah sehari-hari. Dibangun dengan Flutter menggunakan gaya iOS (Cupertino) sehingga memberikan pengalaman native iOS yang mulus. Aplikasi ini **100% gratis tanpa iklan** dan semua data disimpan secara lokal di perangkat pengguna (Local-First).

---

## ✨ Fitur Lengkap

### 🏠 Beranda (HomeScreen)
- **4 Tab Navigasi**: Beranda, Al-Qur'an, Doa, Akun
- **Jadwal Sholat**: Menampilkan jadwal sholat hari ini dengan countdown ke sholat berikutnya
- **Hero Card**: Kartu sambutan dengan quotes motivasi harian
- **Grid Menu**: 12 tool (Quran, Doa, Hadits, Fiqih, Tasbih, Kiblat, Muslim AI, Tracker, Jurnal, Haid, Zakat, Studi Ramadhan)
- **Target Ibadah Harian**: Progress bar untuk target ibadah hari ini
- **Daily Quest**: Quest harian (tilawah, puasa sunnah, sedekah, dll)
- **Quote Card**: Quotes Islami harian dari AI
- **Update Popup**: Notifikasi update aplikasi otomatis
- **FAB Hadits Arba'in**: Tombol akses cepat ke Hadits Arba'in An-Nawawiyyah
- **Background Sound**: Suasana latar (pagi/siang/malam) otomatis saat di Beranda
- **Video Background**: Video latar belakang di hero card

### 📖 Al-Qur'an
- **Index Surah**: 114 surah lengkap dengan nomor, nama Arab-Latin, arti, jumlah ayat, dan golongan (Makkiyah/Madaniyah)
- **Index Juz**: 30 juz dengan daftar surah per juz
- **Surah Reader**: 
  - Ayat dengan teks Arab (font ScheherazadeNew), Latin, dan Terjemahan Kemenag RI
  - Audio 6 Qari (Abdurrahman As-Sudais, Mishary Rashid Alafasy, dll)
  - Download audio per surah (offline playback)
  - Tafsir Kemenag RI per ayat (bottom sheet)
  - Bookmark ayat dengan catatan
  - Scroll presisi ke ayat tertentu
- **Juz Reader**: Sama seperti Surah Reader, diorganisir per juz
- **Khatam Plan**: Program khatam 30 hari dengan target ayat harian

### 🤲 Doa & Dzikir
- **Kumpulan Doa**: 10+ kategori (Sehari-hari, Sholat, Puasa, Taubat, Perlindungan, Dzikir Pagi-Petang, Orang Tua, Alam & Perjalanan, Sakit & Meninggal, Asmaul Husna)
- **Tampilan Lengkap**: Arab, Latin, Arti, dan Sumber
- **Search & Filter**: Cari doa, filter berdasarkan kategori
- **Bookmark**: Simpan doa favorit

### 📜 Hadits
- **Kumpulan Kitab**: 9 kitab hadits (Bukhari, Muslim, Abu Dawud, Tirmidzi, Nasa'i, Ibnu Majah, Ahmad, Malik, Adab)
- **Hadits Reader**: Nomor hadits, teks Arab, terjemahan, kitab, bab
- **Search**: Cari hadits berdasarkan teks atau nomor
- **Bookmark**: Tandai hadits favorit
- **Hadits Arba'in An-Nawawiyyah**: Kumpulan 42 hadits dengan toggle Arab/Terjemahan, pengaturan ukuran font
- **Mode Baca**: Gulir vertikal dengan pengaturan tampilan

### ⚖️ Fiqih Islam
- **12 Kategori**: Thaharah, Sholat, Puasa, Zakat, Haid, Jenazah, Doa, Amalan, Muamalah, Nikah, Kurban, Adab
- **Konten Offline**: Materi fiqih lengkap dari Rumaysho.com
- **Search**: Cari topik fiqih
- **Tab Default "Semua"**: Menampilkan semua materi saat pertama kali masuk
- **Konten Detail**: Setiap materi memuat dalil Al-Quran dan Hadits, penjelasan ulama, dan panduan praktis

### 💰 Zakat
- **4 Kalkulator**: Zakat Fitrah, Zakat Maal, Zakat Penghasilan, Zakat Emas & Perak
- **Perhitungan Otomatis**: Input jumlah/nilai, hitung zakat dengan nisab terkini
- **Kalkulator Akurat**: Nishab emas 85gr, nishab perak 595gr, haul 1 tahun

### 📿 Tasbih Digital
- **Dzikir Digital**: Hitung dzikir dengan tap, counter otomatis
- **Target & Progress**: Set target dzikir, lihat progress
- **Getar & Suara**: Feedback haptic saat mencapai target

### 🧭 Arah Kiblat (Kompas)
- **Kompas Real-time**: Deteksi arah kiblat berdasarkan sensor magnetometer
- **Kiblat Indicator**: Panah dan teks status (menghadap/tidak)
- **Kalibrasi**: 3 mode (Kalibrasi, Normal, Balik 180°)
- **Lokasi Otomatis**: Deteksi lokasi via GPS

### 🤖 Muslim AI
- **5 Mode Chat**: Ngobrol, Cari Doa, Cari Surah, Tanya Fiqih, Cari Hadits
- **AI Chat**: Chat dengan AI berbasis Groq (Llama 3.3 70B)
- **Smart Actions**: Tombol navigasi ke surah/doa/hadits/fiqih dari chat
- **Google Search**: Cari di Google dari dalam chat
- **Cooldown Timer**: Batas pengiriman pesan (30 menit) untuk API key default
- **API Key Pribadi**: Bisa masukkan API key Groq sendiri di Pengaturan AI

### 📊 Tracker Ibadah
- **Tracker Harian**: Catat sholat 5 waktu (Subuh-Dzuhur-Ashar-Maghrib-Isya), Tarawih, Tilawah, Puasa, Sedekah
- **Dashboard**: Kalender bulanan, statistik, rata-rata ibadah
- **Riwayat Bulanan**: Lihat history tracker per hari

### 📝 Jurnal Refleksi
- **4 Kategori**: Refleksi Harian, Catatan Syukur, Ruang Ikhlas, Catatan Bebas
- **Tambah/Edit/Hapus**: Kelola catatan jurnal
- **Entri Terbaru**: 5 entri terakhir di dashboard
- **Penyimpanan Lokal**: Data jurnal aman di perangkat

### 🩸 Haid Tracker
- **Catat Siklus**: Mulai/akhiri periode haid
- **Riwayat Siklus**: Lihat riwayat siklus haid
- **Fase Siklus**: Informasi fase haid, nifas, istihadhah
- **Qadha Puasa**: Catat jumlah hari puasa yang perlu diqadha

### 🕌 Studi Ramadhan
- **30 Hari Materi**: Materi studi harian selama Ramadhan
- **Eksklusif Ramadhan**: Fitur hanya tersedia di bulan Ramadhan

### 🔄 Sinkronisasi P2P
- **QR Code**: Kirim data antar perangkat via QR
- **Backup File**: Export/import data ke file .json
- **Local-First**: Data 100% di perangkat, transfer langsung tanpa server

### 👤 Profil & Pengaturan
- **Edit Profil**: Ubah username, foto profil, kota
- **Tema**: Light/Dark mode
- **Background Sound**: On/off suasana latar
- **Pengaturan AI**: Masukkan API key Groq pribadi
- **Manajemen Data**: Backup & restore semua data
- **Reset Data**: Hapus semua data progres
- **Bantuan & FAQ**: Tanya jawab seputar aplikasi
- **Kebijakan Privasi**: Informasi privasi
- **Cek Update**: Periksa versi terbaru aplikasi

### 🎬 Onboarding
- **3 Slide Pengenalan**: Quran Digital, Amal Tracker, Semua Fitur
- **Pertama Kali**: Ditampilkan hanya saat pertama kali install

---

## 🏗️ Arsitektur Aplikasi

### Pola Umum
```
UI Layer (lib/screens/) → State Layer (lib/providers/) → Service Layer (lib/services/)
                                                                      ↓
                                                            Config/Data Layer
                                                        (lib/config/, lib/data/)
```

### State Management
- **Provider** (ChangeNotifier) untuk seluruh state aplikasi
- 16 Provider terdaftar di `main.dart` via `MultiProvider`

### Services
| Service | Fungsi |
|---------|--------|
| `ApiService` | HTTP client untuk API eksternal (Quran, Hadits, Jadwal Sholat, Tafsir) |
| `AiService` | Integrasi Groq API untuk Muslim AI Chat |
| `AiContentService` | Generate konten AI (quotes, quest, nasehat harian) |
| `QuranDownloadService` | Download & cache audio Quran offline |
| `PrayerTimeService` | Fetch & parse jadwal sholat |
| `NotificationService` | Notifikasi waktu sholat (background via WorkManager) |
| `BackgroundService` | Layanan background untuk sholat |
| `UpdateService` | Cek update aplikasi |
| `QuranTrackerService` | Tracker bacaan Quran (last read, progress) |
| `LocalStorage` | Wrapper SharedPreferences untuk penyimpanan lokal |

### Data (lib/data/)
| File | Konten |
|------|--------|
| `fiqih_data.dart` | Konten fiqih offline (40+ materi detail) |
| `doa_data.dart` | Kumpulan doa & dzikir (10+ kategori) |
| `hadits_data.dart` | Data kitab hadits (9 kitab) |
| `hadits_arbain_data.dart` | 42 hadits Arba'in An-Nawawiyyah |
| `quotes_data.dart` | Quotes Islami offline |
| `study_data.dart` | Materi studi Ramadhan |
| `juz_mapping.dart` | Mapping surah ke juz |

### Assets
| Asset | Lokasi |
|-------|--------|
| Font Arab | `assets/font/ScheherazadeNew-Regular.ttf`, `assets/font/Lateef-Regular.ttf` |
| Audio Background | `assets/audio/bg_night.mp3`, `assets/audio/bg_sunrise.mp3` |
| Video Background | `assets/video/` |
| AI Generated Content | `assets/generated/hadits/`, `assets/generated/fiqih/`, `assets/generated/quotes/` |

---

## 🚀 Cara Menjalankan

### Prasyarat
- Flutter SDK 3.12+
- Dart SDK 3.12+
- Android Studio / VS Code
- Emulator Android / Device fisik

### Install & Run
```bash
# Clone repositori
git clone https://github.com/Jirankun/Umma---Qur-an-Indonesia.git
cd umma

# Install dependencies
flutter pub get

# Run aplikasi
flutter run
```

### Build APK
```bash
flutter build apk --release
```

---

## 📍 Routes

| Route | Screen |
|-------|--------|
| `/quran` | QuranIndexScreen |
| `/doa` | DoaHomeScreen |
| `/hadits` | HaditsHomeScreen |
| `/fiqih` | FiqihHomeScreen |
| `/zakat` | ZakatScreen |
| `/tasbih` | TasbihScreen |
| `/kompas` | KompasScreen |
| `/muslim-ai` | MuslimAiScreen |
| `/tracker` | TrackerDashboardScreen |
| `/tracker-harian` | TrackerScreen |
| `/jurnal` | JurnalDashboardScreen |
| `/haid` | HaidTrackerScreen |
| `/user` | UserProfileScreen |
| `/study` | StudyScreen |
| `/sync-p2p` | P2pSyncScreen |

---

## 📦 Dependencies Utama

```yaml
provider        # State management
http            # HTTP client
shared_preferences # Local storage
geolocator      # GPS location
sensors_plus    # Magnetometer (kompas)
audioplayers    # Audio Quran & background
qr_flutter      # Generate QR Code
mobile_scanner  # Scan QR Code
workmanager     # Background tasks
awesome_notifications # Notifikasi sholat
intl            # Internasionalisasi
path_provider   # File paths
url_launcher    # Buka link
share_plus      # Share file
file_picker     # Pilih file backup
image_picker    # Pilih foto profil
wakelock_plus   # Jaga layar tetap nyala
video_player    # Video background
hijri_date      # Tanggal Hijriyah
permission_handler # Izin lokasi & storage
```

---

## 🛡️ Privasi & Keamanan

- **100% Local-First**: Semua data disimpan di perangkat pengguna
- **Tidak Ada Server Database**: Tidak ada pengumpulan data pribadi
- **Transfer Langsung**: Backup file ditransfer langsung antar perangkat (P2P)
- **Tanpa Iklan & Pelacakan**: Aplikasi bersih tanpa iklan pihak ketiga

---

## 👨‍💻 Pengembang

**ZHYLLAN FYLLAH**
- GitHub: [@jirankun](https://www.github.com/jirankun)
- Portofolio: [jirankun.github.io](https://jirankun.github.io/portofoliozhyllan)

---

## 📄 Lisensi

MIT License — silakan gunakan, modifikasi, dan sebarkan untuk kebaikan.

---

<p align="center">Dibuat dengan ❤️ untuk umat Islam di seluruh dunia 🤲</p>
