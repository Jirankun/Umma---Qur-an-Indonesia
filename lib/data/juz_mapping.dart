/// Mapping lengkap 30 Juz Al-Qur'an → surah dan range ayat
/// Format: (surahId, from, to) — to: null berarti sampai akhir surah
class JuzSegment {
  final int surahId;
  final int from;
  final int? to; // null = sampai akhir surah

  const JuzSegment({required this.surahId, required this.from, this.to});
}

const Map<int, List<JuzSegment>> juzMapping = {
  1: [
    JuzSegment(surahId: 1, from: 1, to: null),
    JuzSegment(surahId: 2, from: 1, to: 141),
  ],
  2: [JuzSegment(surahId: 2, from: 142, to: 252)],
  3: [
    JuzSegment(surahId: 2, from: 253, to: null),
    JuzSegment(surahId: 3, from: 1, to: 91),
  ],
  4: [
    JuzSegment(surahId: 3, from: 92, to: null),
    JuzSegment(surahId: 4, from: 1, to: 23),
  ],
  5: [JuzSegment(surahId: 4, from: 24, to: 147)],
  6: [
    JuzSegment(surahId: 4, from: 148, to: null),
    JuzSegment(surahId: 5, from: 1, to: 81),
  ],
  7: [
    JuzSegment(surahId: 5, from: 82, to: null),
    JuzSegment(surahId: 6, from: 1, to: 110),
  ],
  8: [
    JuzSegment(surahId: 6, from: 111, to: null),
    JuzSegment(surahId: 7, from: 1, to: 87),
  ],
  9: [
    JuzSegment(surahId: 7, from: 88, to: null),
    JuzSegment(surahId: 8, from: 1, to: 40),
  ],
  10: [
    JuzSegment(surahId: 8, from: 41, to: null),
    JuzSegment(surahId: 9, from: 1, to: 92),
  ],
  11: [
    JuzSegment(surahId: 9, from: 93, to: null),
    JuzSegment(surahId: 10, from: 1, to: null),
    JuzSegment(surahId: 11, from: 1, to: 5),
  ],
  12: [
    JuzSegment(surahId: 11, from: 6, to: null),
    JuzSegment(surahId: 12, from: 1, to: 52),
  ],
  13: [
    JuzSegment(surahId: 12, from: 53, to: null),
    JuzSegment(surahId: 13, from: 1, to: null),
    JuzSegment(surahId: 14, from: 1, to: null),
    JuzSegment(surahId: 15, from: 1, to: null),
  ],
  14: [
    JuzSegment(surahId: 16, from: 1, to: null),
    JuzSegment(surahId: 17, from: 1, to: 98),
  ],
  15: [
    JuzSegment(surahId: 17, from: 99, to: null),
    JuzSegment(surahId: 18, from: 1, to: 74),
  ],
  16: [
    JuzSegment(surahId: 18, from: 75, to: null),
    JuzSegment(surahId: 19, from: 1, to: null),
    JuzSegment(surahId: 20, from: 1, to: 135),
  ],
  17: [
    JuzSegment(surahId: 21, from: 1, to: null),
    JuzSegment(surahId: 22, from: 1, to: 78),
  ],
  18: [
    JuzSegment(surahId: 23, from: 1, to: null),
    JuzSegment(surahId: 24, from: 1, to: null),
    JuzSegment(surahId: 25, from: 1, to: 20),
  ],
  19: [
    JuzSegment(surahId: 25, from: 21, to: null),
    JuzSegment(surahId: 26, from: 1, to: null),
    JuzSegment(surahId: 27, from: 1, to: 55),
  ],
  20: [
    JuzSegment(surahId: 27, from: 56, to: null),
    JuzSegment(surahId: 28, from: 1, to: null),
    JuzSegment(surahId: 29, from: 1, to: 45),
  ],
  21: [
    JuzSegment(surahId: 29, from: 46, to: null),
    JuzSegment(surahId: 30, from: 1, to: null),
    JuzSegment(surahId: 31, from: 1, to: null),
    JuzSegment(surahId: 32, from: 1, to: null),
    JuzSegment(surahId: 33, from: 1, to: 30),
  ],
  22: [
    JuzSegment(surahId: 33, from: 31, to: null),
    JuzSegment(surahId: 34, from: 1, to: null),
    JuzSegment(surahId: 35, from: 1, to: null),
    JuzSegment(surahId: 36, from: 1, to: 27),
  ],
  23: [
    JuzSegment(surahId: 36, from: 28, to: null),
    JuzSegment(surahId: 37, from: 1, to: null),
    JuzSegment(surahId: 38, from: 1, to: null),
    JuzSegment(surahId: 39, from: 1, to: 31),
  ],
  24: [
    JuzSegment(surahId: 39, from: 32, to: null),
    JuzSegment(surahId: 40, from: 1, to: null),
    JuzSegment(surahId: 41, from: 1, to: 46),
  ],
  25: [
    JuzSegment(surahId: 41, from: 47, to: null),
    JuzSegment(surahId: 42, from: 1, to: null),
    JuzSegment(surahId: 43, from: 1, to: null),
    JuzSegment(surahId: 44, from: 1, to: null),
    JuzSegment(surahId: 45, from: 1, to: null),
  ],
  26: [
    JuzSegment(surahId: 46, from: 1, to: null),
    JuzSegment(surahId: 47, from: 1, to: null),
    JuzSegment(surahId: 48, from: 1, to: null),
    JuzSegment(surahId: 49, from: 1, to: null),
    JuzSegment(surahId: 50, from: 1, to: null),
    JuzSegment(surahId: 51, from: 1, to: 30),
  ],
  27: [
    JuzSegment(surahId: 51, from: 31, to: null),
    JuzSegment(surahId: 52, from: 1, to: null),
    JuzSegment(surahId: 53, from: 1, to: null),
    JuzSegment(surahId: 54, from: 1, to: null),
    JuzSegment(surahId: 55, from: 1, to: null),
    JuzSegment(surahId: 56, from: 1, to: null),
    JuzSegment(surahId: 57, from: 1, to: null),
  ],
  28: [
    JuzSegment(surahId: 58, from: 1, to: null),
    JuzSegment(surahId: 59, from: 1, to: null),
    JuzSegment(surahId: 60, from: 1, to: null),
    JuzSegment(surahId: 61, from: 1, to: null),
    JuzSegment(surahId: 62, from: 1, to: null),
    JuzSegment(surahId: 63, from: 1, to: null),
    JuzSegment(surahId: 64, from: 1, to: null),
    JuzSegment(surahId: 65, from: 1, to: null),
    JuzSegment(surahId: 66, from: 1, to: null),
  ],
  29: [
    JuzSegment(surahId: 67, from: 1, to: null),
    JuzSegment(surahId: 68, from: 1, to: null),
    JuzSegment(surahId: 69, from: 1, to: null),
    JuzSegment(surahId: 70, from: 1, to: null),
    JuzSegment(surahId: 71, from: 1, to: null),
    JuzSegment(surahId: 72, from: 1, to: null),
    JuzSegment(surahId: 73, from: 1, to: null),
    JuzSegment(surahId: 74, from: 1, to: null),
    JuzSegment(surahId: 75, from: 1, to: null),
    JuzSegment(surahId: 76, from: 1, to: null),
    JuzSegment(surahId: 77, from: 1, to: null),
  ],
  30: [
    JuzSegment(surahId: 78, from: 1, to: null),
    JuzSegment(surahId: 79, from: 1, to: null),
    JuzSegment(surahId: 80, from: 1, to: null),
    JuzSegment(surahId: 81, from: 1, to: null),
    JuzSegment(surahId: 82, from: 1, to: null),
    JuzSegment(surahId: 83, from: 1, to: null),
    JuzSegment(surahId: 84, from: 1, to: null),
    JuzSegment(surahId: 85, from: 1, to: null),
    JuzSegment(surahId: 86, from: 1, to: null),
    JuzSegment(surahId: 87, from: 1, to: null),
    JuzSegment(surahId: 88, from: 1, to: null),
    JuzSegment(surahId: 89, from: 1, to: null),
    JuzSegment(surahId: 90, from: 1, to: null),
    JuzSegment(surahId: 91, from: 1, to: null),
    JuzSegment(surahId: 92, from: 1, to: null),
    JuzSegment(surahId: 93, from: 1, to: null),
    JuzSegment(surahId: 94, from: 1, to: null),
    JuzSegment(surahId: 95, from: 1, to: null),
    JuzSegment(surahId: 96, from: 1, to: null),
    JuzSegment(surahId: 97, from: 1, to: null),
    JuzSegment(surahId: 98, from: 1, to: null),
    JuzSegment(surahId: 99, from: 1, to: null),
    JuzSegment(surahId: 100, from: 1, to: null),
    JuzSegment(surahId: 101, from: 1, to: null),
    JuzSegment(surahId: 102, from: 1, to: null),
    JuzSegment(surahId: 103, from: 1, to: null),
    JuzSegment(surahId: 104, from: 1, to: null),
    JuzSegment(surahId: 105, from: 1, to: null),
    JuzSegment(surahId: 106, from: 1, to: null),
    JuzSegment(surahId: 107, from: 1, to: null),
    JuzSegment(surahId: 108, from: 1, to: null),
    JuzSegment(surahId: 109, from: 1, to: null),
    JuzSegment(surahId: 110, from: 1, to: null),
    JuzSegment(surahId: 111, from: 1, to: null),
    JuzSegment(surahId: 112, from: 1, to: null),
    JuzSegment(surahId: 113, from: 1, to: null),
    JuzSegment(surahId: 114, from: 1, to: null),
  ],
};
