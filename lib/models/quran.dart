class Surah {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;
  final String tempatTurun;
  final String arti;
  final String deskripsi;
  final AudioInfo audio;

  Surah({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
    required this.tempatTurun,
    required this.arti,
    this.deskripsi = '',
    required this.audio,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
      tempatTurun: json['tempatTurun'] ?? '',
      arti: json['arti'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      audio: AudioInfo.fromJson(json['audioFull'] ?? {}),
    );
  }
}

class AudioInfo {
  /// Map qariId -> audio URL (menampung semua Qari 01-06)
  final Map<String, String?> urls;

  AudioInfo({required this.urls});

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      urls: json.map((key, value) => MapEntry(key, value as String?)),
    );
  }

  /// Helper untuk mengambil URL per-ayat berdasarkan qariId
  String? urlForQari(String qariId) => urls[qariId];
}

class Ayat {
  final int nomorAyat;
  final String teksArab;
  final String teksLatin;
  final String teksIndonesia;
  final SurahInfo surah;
  final AudioInfo audio;

  Ayat({
    required this.nomorAyat,
    required this.teksArab,
    required this.teksLatin,
    required this.teksIndonesia,
    required this.surah,
    required this.audio,
  });

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      nomorAyat: json['nomorAyat'] ?? 0,
      teksArab: json['teksArab'] ?? '',
      teksLatin: json['teksLatin'] ?? '',
      teksIndonesia: json['teksIndonesia'] ?? '',
      surah: SurahInfo.fromJson(json['surah'] ?? {}),
      audio: AudioInfo.fromJson(json['audio'] ?? {}),
    );
  }
}

class SurahInfo {
  final int nomor;
  final String nama;
  final String namaLatin;
  final int jumlahAyat;

  SurahInfo({
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.jumlahAyat,
  });

  factory SurahInfo.fromJson(Map<String, dynamic> json) {
    return SurahInfo(
      nomor: json['nomor'] ?? 0,
      nama: json['nama'] ?? '',
      namaLatin: json['namaLatin'] ?? '',
      jumlahAyat: json['jumlahAyat'] ?? 0,
    );
  }
}

class QuranBookmark {
  final int surahId;
  final int ayahNumber;
  final String surahName;
  final bool isJuz;
  final int? juzNumber;
  final DateTime createdAt;

  QuranBookmark({
    required this.surahId,
    required this.ayahNumber,
    required this.surahName,
    this.isJuz = false,
    this.juzNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'surahId': surahId,
    'ayahNumber': ayahNumber,
    'surahName': surahName,
    'isJuz': isJuz,
    'juzNumber': juzNumber,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QuranBookmark.fromJson(Map<String, dynamic> json) {
    return QuranBookmark(
      surahId: json['surahId'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      surahName: json['surahName'] ?? '',
      isJuz: json['isJuz'] ?? false,
      juzNumber: json['juzNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class LastRead {
  final int surahId;
  final String surahName;
  final int ayahNumber;
  final bool isJuz;
  final int? juzNumber;
  final DateTime lastReadAt;

  LastRead({
    required this.surahId,
    required this.surahName,
    required this.ayahNumber,
    this.isJuz = false,
    this.juzNumber,
    DateTime? lastReadAt,
  }) : lastReadAt = lastReadAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'surahId': surahId,
    'surahName': surahName,
    'ayahNumber': ayahNumber,
    'isJuz': isJuz,
    'juzNumber': juzNumber,
    'lastReadAt': lastReadAt.toIso8601String(),
  };

  factory LastRead.fromJson(Map<String, dynamic> json) {
    return LastRead(
      surahId: json['surahId'] ?? 0,
      surahName: json['surahName'] ?? '',
      ayahNumber: json['ayahNumber'] ?? 0,
      isJuz: json['isJuz'] ?? false,
      juzNumber: json['juzNumber'],
      lastReadAt: json['lastReadAt'] != null
          ? DateTime.parse(json['lastReadAt'])
          : DateTime.now(),
    );
  }
}

class JuzInfo {
  final int juz;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  JuzInfo({
    required this.juz,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });
}

class QuranReadingHistory {
  final Map<String, int> dailyDurations; // date string -> seconds

  QuranReadingHistory({Map<String, int>? dailyDurations})
    : dailyDurations = dailyDurations ?? {};

  Map<String, dynamic> toJson() => {'dailyDurations': dailyDurations};
  factory QuranReadingHistory.fromJson(Map<String, dynamic> json) {
    return QuranReadingHistory(
      dailyDurations: Map<String, int>.from(json['dailyDurations'] ?? {}),
    );
  }
}

class KhatamPlan {
  final int targetDays;
  final int progressAyat;
  final DateTime startDate;

  KhatamPlan({
    required this.targetDays,
    this.progressAyat = 0,
    DateTime? startDate,
  }) : startDate = startDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'targetDays': targetDays,
    'progressAyat': progressAyat,
    'startDate': startDate.toIso8601String(),
  };

  factory KhatamPlan.fromJson(Map<String, dynamic> json) {
    return KhatamPlan(
      targetDays: json['targetDays'] ?? 30,
      progressAyat: json['progressAyat'] ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
    );
  }
}
