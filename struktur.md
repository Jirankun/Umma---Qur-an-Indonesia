# 📂 Struktur Proyek Umma

Gambaran umum struktur proyek Umma — aplikasi Muslim all-in-one berbasis Flutter.

---

## 🗂️ Sekilas Proyek

```
umma/
├── android/            # Konfigurasi native Android
├── assets/             # Font Arab, audio background, video, dan konten AI
├── lib/                # Kode utama aplikasi
├── test/               # File testing
├── pubspec.yaml        # Daftar dependencies
└── README.md           # Dokumentasi utama
```

---

## 📱 Bagian Kode Utama (`lib/`)

```
lib/
├── main.dart               # Entry point aplikasi
├── app.dart                # Konfigurasi routing & onboarding
│
├── config/                 # Pengaturan global
│   ├── api_config.dart     # URL API dan konstanta
│   ├── colors.dart         # Semua warna (200+)
│   └── strings.dart        # Semua teks UI (300+)
│
├── models/                 # Struktur data
│   ├── models.dart         # Model umum
│   ├── quran.dart          # Data surah & ayat
│   ├── hadits.dart         # Data hadits
│   └── doa.dart            # Data doa
│
├── providers/              # Pengelola state (16 provider)
│   └── (theme, quran, doa, hadits, fiqih, tracker,
│        journal, zakat, haid, tasbih, muslim_ai,
│        user, prayer_times, background_sound, update)
│
├── services/               # Layanan
│   ├── api_service.dart        # Koneksi API eksternal
│   ├── ai_service.dart         # Integrasi Groq AI
│   ├── local_storage.dart      # Penyimpanan lokal
│   ├── notification_service.dart   # Notifikasi sholat
│   ├── quran_download_service.dart  # Download audio
│   ├── prayer_time_service.dart     # Jadwal sholat
│   ├── murattal_audio_handler.dart  # Background playback
│   └── ...
│
├── data/                  # Data offline
│   ├── fiqih_data.dart        # 40+ materi fiqih
│   ├── doa_data.dart          # 10+ kategori doa
│   ├── hadits_data.dart       # 9 kitab hadits
│   └── ...
│
├── utils/                 # Helper
│   ├── app_info.dart      # Info versi aplikasi
│   └── date_helper.dart   # Tanggal & Hijriah
│
└── screens/               # Semua halaman
    ├── home/              # Beranda (tab utama)
    ├── quran/             # Al-Qur'an
    ├── murattal/          # Pemutar audio Quran
    ├── doa/               # Doa & dzikir
    ├── hadits/            # Hadits
    ├── fiqih/             # Fiqih Islam
    ├── zakat/             # Kalkulator zakat
    ├── tasbih/            # Dzikir digital
    ├── kompas/            # Arah kiblat
    ├── muslim_ai/         # AI chat
    ├── tracker/           # Tracker ibadah
    ├── jurnal/            # Jurnal refleksi
    ├── haid/              # Tracker haid
    ├── study/             # Studi Ramadhan
    ├── sync/              # Sinkronisasi P2P
    ├── user/              # Profil & pengaturan
    ├── onboarding/        # Halaman pengenalan
    └── _shared/           # Widget bersama
```

---

## 🔁 Alur Navigasi

```
HomeScreen (4 Tab Bawah)
├── 🏠 Beranda      → Grid 12 fitur + target ibadah + quest
├── 📖 Al-Qur'an    → Index surah/juz + bookmark
├── 🤲 Doa          → Kumpulan doa & dzikir
└── 👤 Akun         → Profil & pengaturan

Tombol cepat (FAB) di Beranda:
├── 📜 Hadits Arba'in
└── 🎵 Murattal
```

---

## 🎨 Tema & Tampilan

- **Gaya iOS penuh** — menggunakan widget Cupertino di seluruh aplikasi
- **Dark Mode** — semua screen mendukung tema gelap/terang
- **Warna terpusat** — 200+ warna di `config/colors.dart`
- **Teks terpusat** — 300+ string UI di `config/strings.dart`

---

## 🔗 API Eksternal

| Layanan | Kegunaan |
|---------|----------|
| EQuran.id | Data Al-Qur'an, ayat, tafsir |
| Hadits API | Kitab & teks hadits |
| Groq API | Muslim AI Chat (Llama 3.3 70B) |
| Prayer Time API | Jadwal sholat berdasarkan lokasi |

---

## 📝 Catatan Penting

- **Local-First** — Semua data di perangkat pengguna, tidak ada server
- **Offline Support** — Quran, Hadits, Doa, Fiqih bisa dibaca tanpa internet
- **Internet Required** — Muslim AI, download audio, update jadwal sholat
- **100% Gratis** — Tidak ada iklan, tidak ada pembelian dalam aplikasi

---

<p align="center">📜 Dokumentasi untuk kontributor dan pengguna.</p>
