import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ai_config.dart';
import '../utils/date_helper.dart';

/// Service AI untuk auto-generate konten dinamis di HP user.
/// Menggunakan groqApiKeyDefault (built-in) — terpisah dari key chat user.
///
/// Cache system (hemat kredit AI):
/// - Quotes: 12 jam sekali update
/// - Hadits: 24 jam sekali update
/// - Fiqih: 48 jam sekali update
///
/// Konteks otomatis: Ramadhan → konten Ramadhan, non-Ramadhan → konten umum.
class AiContentService {
  static final AiContentService _instance = AiContentService._internal();
  factory AiContentService() => _instance;
  AiContentService._internal();

  // Cache duration dalam jam (dari AiConfig)
  static const int _cacheHoursHadits = AiConfig.cacheHoursHadits;
  static const int _cacheHoursFiqih = AiConfig.cacheHoursFiqih;
  static const int _cacheHoursQuest = AiConfig.cacheHoursQuest;
  static const int _cacheHoursBatch = AiConfig.cacheHoursBatch;

  // Cache keys (dari AiConfig)
  static const String _keyCacheFiqih = AiConfig.keyCacheFiqih;
  static const String _keyCacheFiqihTime = AiConfig.keyCacheFiqihTime;
  static const String _keyCacheBatchQuotes = AiConfig.keyCacheBatchQuotes;
  static const String _keyCacheBatchQuotesTime = AiConfig.keyCacheBatchQuotesTime;
  static const String _keyCacheBatchHadits = AiConfig.keyCacheBatchHadits;
  static const String _keyCacheBatchHaditsTime = AiConfig.keyCacheBatchHaditsTime;
  static const String _keyCacheBatchQuest = AiConfig.keyCacheBatchQuest;
  static const String _keyCacheBatchQuestTime = AiConfig.keyCacheBatchQuestTime;

  Future<bool> _isCacheFreshAsync(String timeKey, int maxHours) async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt(timeKey);
    if (lastTime == null) return false;
    final ageHours =
        (DateTime.now().millisecondsSinceEpoch - lastTime) / 3600000;
    return ageHours < maxHours;
  }

  Future<void> _saveCache(String dataKey, String timeKey, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dataKey, data);
    await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String?> _loadCache(String dataKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(dataKey);
  }

  // ─── API CALL ────────────────────────────────────────────

  Future<String?> _callGroq(
    String systemPrompt,
    String userPrompt, {
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    if (AiConfig.groqApiKeyDefault.isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(AiConfig.groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AiConfig.groqApiKeyDefault}',
        },
        body: jsonEncode({
          'model': AiConfig.groqModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': temperature,
          'max_tokens': maxTokens,
          'top_p': AiConfig.groqTopP,
        }),
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'];
    } catch (_) {
      return null;
    }
  }

  /// Parse JSON array dari response AI (handle markdown code fences)
  List<Map<String, dynamic>>? _parseJsonArray(String? text) {
    if (text == null || text.isEmpty) return null;

    var cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final parsed = jsonDecode(cleaned);
      if (parsed is List) {
        return parsed.cast<Map<String, dynamic>>();
      }
    } catch (_) {}

    // Coba cari array dalam teks
    final start = cleaned.indexOf('[');
    final end = cleaned.lastIndexOf(']');
    if (start != -1 && end > start) {
      try {
        final parsed = jsonDecode(cleaned.substring(start, end + 1));
        if (parsed is List) {
          return parsed.cast<Map<String, dynamic>>();
        }
      } catch (_) {}
    }

    return null;
  }

  // ─── BUILD CONTEXT ───────────────────────────────────────

  String _buildContext() {
    final now = DateTime.now();
    final isRamadhan = DateHelper.isRamadhanSeason(now);
    final month = DateHelper.getMonthName(now.month);
    return 'Hari ini: ${now.day} $month ${now.year}. ${isRamadhan ? "SEKARANG BULAN RAMADHAN! Konten harus fokus Ramadhan." : "Bukan Ramadhan. Konten Islam umum."}';
  }

  // ═══════════════════════════════════════════════════════════
  // 1. QUOTES — Batch 30 quotes, ganti 1 per hari berdasarkan tanggal
  // ═══════════════════════════════════════════════════════════

  /// Dapatkan quotes harian dari batch 30 quotes.
  /// Index = now.day % 30, cache 24 jam.
  Future<Map<String, String>> getDailyQuote() async {
    final batch = await _getBatchQuotes();
    final index = DateTime.now().day % batch.length;
    if (batch.isNotEmpty && batch[index]['text'] != null) {
      return {
        'text': batch[index]['text'].toString(),
        'author': batch[index]['author']?.toString() ?? '',
      };
    }
    return const {'text': '', 'author': ''};
  }

  /// Fetch or load cached batch of 30 quotes
  Future<List<Map<String, dynamic>>> _getBatchQuotes() async {
    // 1. Coba cache dulu
    if (await _isCacheFreshAsync(_keyCacheBatchQuotesTime, _cacheHoursBatch)) {
      final cached = await _loadCache(_keyCacheBatchQuotes);
      final parsed = _parseJsonArray(cached);
      if (parsed != null && parsed.length >= 30) return parsed;
    }

    // 2. Panggil API untuk 30 quotes
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final systemPrompt =
        '''
Kamu adalah penulis konten Islami untuk Muslim Indonesia.

Tugas: Hasilkan 30 kutipan Islami INSPIRATIF yang BERBEDA.
${isRamadhan ? 'FOKUS: RAMADHAN — puasa, sabar, ampunan, Lailatul Qadar, dll.' : 'FOKUS: ISLAM UMUM — kehidupan, kesabaran, syukur, taubat, ukhuwah.'}

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"text": "kutipan ke-1", "author": "sumber"}, {"text": "kutipan ke-2", "author": "sumber"}, ...]
BUAT 30 ITEM! JANGAN gunakan markdown.
''';

    final result = await _callGroq(
      systemPrompt,
      _buildContext(),
      temperature: 0.8,
      maxTokens: AiConfig.groqMaxTokensContent,
    );

    final parsed = _parseJsonArray(result);
    if (parsed != null && parsed.length >= 30) {
      await _saveCache(
        _keyCacheBatchQuotes,
        _keyCacheBatchQuotesTime,
        jsonEncode(parsed),
      );
      return parsed;
    }

    // 3. Fallback: 30 quotes statis
    return _staticQuotePool();
  }

  List<Map<String, dynamic>> _staticQuotePool() {
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final pool = isRamadhan ? _ramadhanQuoteFallback : _generalQuoteFallback;
    // Repeat the pool to reach 30 items
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < 30; i++) {
      final item = pool[i % pool.length];
      result.add({'text': item['text'], 'author': item['author']});
    }
    return result;
  }

  static const List<Map<String, String>> _generalQuoteFallback = [
    {
      'text': 'Sebaik-baik manusia adalah yang paling bermanfaat bagi manusia.',
      'author': 'HR. Ahmad',
    },
    {
      'text':
          'Barangsiapa bersabar, Allah akan memberikan kesabaran kepadanya.',
      'author': 'HR. Bukhari',
    },
    {
      'text': 'Senyummu di hadapan saudaramu adalah sedekah.',
      'author': 'HR. Tirmidzi',
    },
    {
      'text':
          'Cukuplah kebaikan seseorang dari melihat kekurangan dirinya sendiri.',
      'author': 'Umar bin Khattab',
    },
    {'text': 'Ilmu itu kehidupan hati dari kebodohan.', 'author': 'HR. Muslim'},
    {'text': 'Jangan marah, maka bagimu surga.', 'author': 'HR. Thabrani'},
    {
      'text': 'Ridha Allah tergantung pada ridha orang tua.',
      'author': 'HR. Tirmidzi',
    },
    {
      'text':
          'Barangsiapa menempuh jalan mencari ilmu, Allah mudahkan jalannya ke surga.',
      'author': 'HR. Muslim',
    },
  ];

  static const List<Map<String, String>> _ramadhanQuoteFallback = [
    {
      'text':
          'Ramadhan bukan tentang menahan lapar, tapi menahan diri dari segala yang dibenci Allah.',
      'author': 'Renungan Ramadhan',
    },
    {
      'text':
          'Puasa adalah perisai yang melindungi seorang hamba dari api neraka.',
      'author': 'HR. Muslim',
    },
    {
      'text':
          'Barangsiapa berpuasa Ramadhan dengan iman dan mengharap pahala, diampuni dosa-dosanya.',
      'author': 'HR. Bukhari & Muslim',
    },
    {
      'text':
          'Di surga ada pintu bernama Ar-Rayyan yang hanya dimasuki oleh orang yang berpuasa.',
      'author': 'HR. Bukhari & Muslim',
    },
    {
      'text':
          'Ramadhan adalah bulan diturunkannya Al-Qur\'an, petunjuk bagi manusia.',
      'author': 'QS. Al-Baqarah: 185',
    },
    {
      'text': 'Bersahurlah kalian, karena dalam sahur terdapat keberkahan.',
      'author': 'HR. Bukhari & Muslim',
    },
    {
      'text': 'Lailatul Qadar lebih baik dari seribu bulan.',
      'author': 'QS. Al-Qadr: 3',
    },
    {
      'text':
          'Awal Ramadhan rahmat, pertengahannya ampunan, akhirnya pembebasan dari neraka.',
      'author': 'HR. Baihaqi',
    },
  ];

  // ═══════════════════════════════════════════════════════════
  // 2. HADITS / NASEHAT — Batch 30, 24h cache, day-indexed
  // ═══════════════════════════════════════════════════════════

  /// Dapatkan nasehat/hadits harian dari batch 30 item.
  /// Index = now.day % 30, cache 24 jam.
  Future<Map<String, String>> getDailyNasehat() async {
    final batch = await _getBatchNasehat();
    final index = DateTime.now().day % batch.length;
    if (batch.isNotEmpty && batch[index]['content'] != null) {
      return {
        'title': batch[index]['title']?.toString() ?? '',
        'content': batch[index]['content'].toString(),
        'source': batch[index]['source']?.toString() ?? '',
      };
    }
    return const {'title': '', 'content': '', 'source': ''};
  }

  /// Fetch or load cached batch of 30 nasehat/hadits
  Future<List<Map<String, dynamic>>> _getBatchNasehat() async {
    // 1. Coba cache dulu
    if (await _isCacheFreshAsync(_keyCacheBatchHaditsTime, _cacheHoursHadits)) {
      final cached = await _loadCache(_keyCacheBatchHadits);
      final parsed = _parseJsonArray(cached);
      if (parsed != null && parsed.length >= 30) return parsed;
    }

    // 2. Panggil API untuk 30 nasehat
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final systemPrompt =
        '''
Kamu adalah pendakwah untuk Muslim Indonesia.

Tugas: Hasilkan 30 nasehat/pelajaran hadits yang BERBEDA dan INSPIRATIF.
${isRamadhan ? 'FOKUS: RAMADHAN — puasa, sabar, ampunan, sahur, berbuka, tarawih, Lailatul Qadar, zakat fitrah, i\'tikaf.' : 'FOKUS: ISLAM UMUM — shalat, sabar, syukur, sedekah, silaturahmi, ilmu, birrul walidain, taubat, ikhlas, tawakal, ukhuwah.'}

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"id": "1", "title": "judul nasehat", "content": "isi nasehat", "source": "sumber dalil"}]
BUAT 30 ITEM! Buat judul pendek dan menarik. Sumber bisa dari Al-Quran (QS. ...) atau Hadits (HR. ...).
JANGAN gunakan markdown.
''';

    final result = await _callGroq(
      systemPrompt,
      _buildContext(),
      temperature: 0.8,
      maxTokens: AiConfig.groqMaxTokensContent,
    );

    final parsed = _parseJsonArray(result);
    if (parsed != null && parsed.length >= 30) {
      await _saveCache(
        _keyCacheBatchHadits,
        _keyCacheBatchHaditsTime,
        jsonEncode(parsed),
      );
      return parsed;
    }

    // 3. Fallback
    return _staticNasehatPool();
  }

  List<Map<String, dynamic>> _staticNasehatPool() {
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final pool = isRamadhan ? _ramadhanHaditsFallback : _generalHaditsFallback;
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < 30; i++) {
      final item = pool[i % pool.length];
      result.add(Map<String, dynamic>.from(item));
    }
    return result;
  }

  static const List<Map<String, String>> _generalHaditsFallback = [
    {
      'id': 'fb_1',
      'title': 'Keutamaan Senyum',
      'content': 'Senyummu di hadapan saudaramu adalah sedekah.',
      'source': 'HR. Tirmidzi',
    },
    {
      'id': 'fb_2',
      'title': 'Bersyukur',
      'content':
          'Barangsiapa bersyukur atas nikmat, Allah akan menambah nikmat-Nya.',
      'source': 'QS. Ibrahim: 7',
    },
    {
      'id': 'fb_3',
      'title': 'Menjaga Lisan',
      'content':
          'Barangsiapa beriman kepada Allah dan hari akhir, hendaklah berkata baik atau diam.',
      'source': 'HR. Bukhari',
    },
    {
      'id': 'fb_4',
      'title': 'Keutamaan Ilmu',
      'content': 'Menuntut ilmu adalah kewajiban bagi setiap muslim.',
      'source': 'HR. Ibnu Majah',
    },
    {
      'id': 'fb_5',
      'title': 'Silaturahmi',
      'content':
          'Barangsiapa ingin dilapangkan rezekinya dan dipanjangkan umurnya, hendaklah ia menyambung silaturahmi.',
      'source': 'HR. Bukhari',
    },
    {
      'id': 'fb_6',
      'title': 'Tawakal',
      'content':
          'Seandainya kalian bertawakal kepada Allah dengan sebenar-benarnya, niscaya Dia akan memberi rezeki seperti burung.',
      'source': 'HR. Tirmidzi',
    },
    {
      'id': 'fb_7',
      'title': 'Keutamaan Ikhlas',
      'content':
          'Sesungguhnya amal itu tergantung niatnya, dan setiap orang mendapat balasan sesuai niatnya.',
      'source': 'HR. Bukhari & Muslim',
    },
  ];

  static const List<Map<String, String>> _ramadhanHaditsFallback = [
    {
      'id': 'fb_r1',
      'title': 'Keutamaan Sahur',
      'content':
          'Makan sahurlah kalian, karena dalam sahur terdapat keberkahan.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r2',
      'title': 'Puasa adalah Perisai',
      'content':
          'Puasa adalah perisai yang melindungi seorang hamba dari api neraka.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r3',
      'title': 'Pintu Ar-Rayyan',
      'content':
          'Di surga ada pintu bernama Ar-Rayyan yang hanya dimasuki oleh orang-orang yang berpuasa.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r4',
      'title': 'Ampunan Ramadhan',
      'content':
          'Barangsiapa berpuasa Ramadhan dengan iman dan mengharap pahala, diampuni dosa-dosanya yang telah lalu.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r5',
      'title': '10 Hari Terakhir',
      'content':
          'Rasulullah ﷺ pada 10 malam terakhir Ramadhan menghidupkan malam dengan ibadah dan membangunkan keluarganya.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r6',
      'title': 'Lailatul Qadar',
      'content':
          'Barangsiapa menghidupkan Lailatul Qadar dengan iman dan harap pahala, diampuni dosa-dosanya.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r7',
      'title': 'Menyegerakan Berbuka',
      'content':
          'Manusia akan senantiasa dalam kebaikan selama mereka menyegerakan berbuka.',
      'source': 'HR. Bukhari & Muslim',
    },
    {
      'id': 'fb_r8',
      'title': 'Doa Orang Berpuasa',
      'content':
          'Ada tiga doa yang tidak tertolak: doa orang yang berpuasa, doa pemimpin yang adil, dan doa orang terzalimi.',
      'source': 'HR. Tirmidzi',
    },
  ];

  // ═══════════════════════════════════════════════════════════
  // 3B. QUEST HARIAN — Batch 30, 24h cache, day-indexed
  // ═══════════════════════════════════════════════════════════

  /// Dapatkan quest harian dari batch 30 item.
  /// Index = now.day % 30, cache 24 jam.
  Future<Map<String, String>> getDailyQuest() async {
    final batch = await _getBatchQuest();
    final index = DateTime.now().day % batch.length;
    if (batch.isNotEmpty && batch[index]['title'] != null) {
      return {
        'title': batch[index]['title'].toString(),
        'description': batch[index]['description']?.toString() ?? '',
        'reward': batch[index]['reward']?.toString() ?? '',
      };
    }
    return const {'title': '', 'description': '', 'reward': ''};
  }

  /// Fetch or load cached batch of 30 daily quests
  Future<List<Map<String, dynamic>>> _getBatchQuest() async {
    // 1. Coba cache dulu
    if (await _isCacheFreshAsync(_keyCacheBatchQuestTime, _cacheHoursQuest)) {
      final cached = await _loadCache(_keyCacheBatchQuest);
      final parsed = _parseJsonArray(cached);
      if (parsed != null && parsed.length >= 30) return parsed;
    }

    // 2. Panggil API untuk 30 quest
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final systemPrompt =
        '''
Kamu adalah pembuat program tantangan ibadah harian untuk Muslim Indonesia.

Tugas: Hasilkan 30 tantangan/misi ibadah harian (daily quest/mission) yang BERBEDA dan MENARIK.
${isRamadhan ? 'FOKUS: RAMADHAN — target puasa sunnah, tarawih, tadarus, sedekah, i\'tikaf, doa berbuka, Lailatul Qadar.' : 'FOKUS: ISLAM UMUM — shalat tepat waktu, sedekah harian, dzikir pagi/petang, baca Quran, puasa sunnah, silaturahmi, menuntut ilmu.'}

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"id": "1", "title": "nama quest", "description": "penjelasan singkat apa yang harus dilakukan", "reward": "manfaat/keutamaan spiritual"}]
BUAT 30 ITEM! Buat judul quest pendek dan memotivasi. Deskripsi 1-2 kalimat.
JANGAN gunakan markdown.
''';

    final result = await _callGroq(
      systemPrompt,
      _buildContext(),
      temperature: 0.8,
      maxTokens: AiConfig.groqMaxTokensContent,
    );

    final parsed = _parseJsonArray(result);
    if (parsed != null && parsed.length >= 30) {
      await _saveCache(
        _keyCacheBatchQuest,
        _keyCacheBatchQuestTime,
        jsonEncode(parsed),
      );
      return parsed;
    }

    // 3. Fallback
    return _staticQuestPool();
  }

  List<Map<String, dynamic>> _staticQuestPool() {
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final pool = isRamadhan ? _ramadhanQuestFallback : _generalQuestFallback;
    final result = <Map<String, dynamic>>[];
    for (int i = 0; i < 30; i++) {
      final item = pool[i % pool.length];
      result.add(Map<String, dynamic>.from(item));
    }
    return result;
  }

  static const List<Map<String, String>> _generalQuestFallback = [
    {
      'id': 'q_1',
      'title': 'Sholat Tepat Waktu',
      'description':
          'Kerjakan semua sholat wajib tepat di awal waktu hari ini.',
      'reward': 'Mendapat cahaya di hari kiamat',
    },
    {
      'id': 'q_2',
      'title': 'Sedekah Harian',
      'description': 'Bersedekahlah meski hanya senyuman atau sebungkus nasi.',
      'reward': 'Harta yang diberkahi',
    },
    {
      'id': 'q_3',
      'title': 'Dzikir Pagi',
      'description': 'Baca dzikir pagi setelah sholat subuh.',
      'reward': 'Perlindungan hingga petang',
    },
    {
      'id': 'q_4',
      'title': 'Baca Al-Quran',
      'description': 'Luangkan 10 menit untuk membaca Al-Quran.',
      'reward': '10 pahala per huruf',
    },
    {
      'id': 'q_5',
      'title': 'Silaturahmi',
      'description': 'Hubungi atau kunjungi keluarga/kerabat hari ini.',
      'reward': 'Lapang rezeki & panjang umur',
    },
    {
      'id': 'q_6',
      'title': 'Puasa Sunnah',
      'description': 'Berpuasa sunnah Senin/Kamis atau Ayyamul Bidh.',
      'reward': 'Jauh dari api neraka',
    },
    {
      'id': 'q_7',
      'title': 'Menuntut Ilmu',
      'description': 'Baca buku Islam atau hadiri kajian selama 15 menit.',
      'reward': 'Dimudahkan jalan ke surga',
    },
    {
      'id': 'q_8',
      'title': 'Berkata Baik',
      'description': 'Jaga lisan hari ini: berkata baik atau diam.',
      'reward': 'Selamat dari kebinasaan',
    },
  ];

  static const List<Map<String, String>> _ramadhanQuestFallback = [
    {
      'id': 'qr_1',
      'title': 'Puasa Penuh',
      'description':
          'Jaga puasa dari terbit fajar hingga maghrib dengan sempurna.',
      'reward': 'Ampunan dosa yang telah lalu',
    },
    {
      'id': 'qr_2',
      'title': 'Tarawih Berjamaah',
      'description': 'Sholat tarawih berjamaah di masjid malam ini.',
      'reward': 'Pahala sholat semalam penuh',
    },
    {
      'id': 'qr_3',
      'title': 'Tadarus Al-Quran',
      'description': 'Baca 1 juz Al-Quran di bulan Ramadhan.',
      'reward': 'Syafaat Al-Quran di akhirat',
    },
    {
      'id': 'qr_4',
      'title': 'Sedekah Ramadhan',
      'description': 'Perbanyak sedekah, minimal memberi takjil untuk berbuka.',
      'reward': 'Pahala berlipat di bulan mulia',
    },
    {
      'id': 'qr_5',
      'title': 'Doa Berbuka',
      'description': 'Baca doa berbuka puasa dengan khusyuk.',
      'reward': 'Doa tidak tertolak',
    },
    {
      'id': 'qr_6',
      'title': 'Sahur Barokah',
      'description': 'Bangun sahur meski hanya seteguk air.',
      'reward': 'Keberkahan sepanjang hari',
    },
    {
      'id': 'qr_7',
      'title': 'I\'tikaf',
      'description':
          'Berdiam di masjid selama beberapa saat di 10 malam terakhir.',
      'reward': 'Mendapat Lailatul Qadar',
    },
    {
      'id': 'qr_8',
      'title': 'Perbanyak Istighfar',
      'description': 'Baca istighfar 100 kali hari ini.',
      'reward': 'Ampunan dan rezeki tak terduga',
    },
  ];

  // ═══════════════════════════════════════════════════════════
  // OLD HADITS METHODS — tetap untuk backward compat
  // ═══════════════════════════════════════════════════════════

  /// Legacy: getDailyHadits (untuk DailyKnowledgeCard yg masih pakai ini)
  Future<List<Map<String, dynamic>>> getDailyHadits() async {
    final batch = await _getBatchNasehat();
    return batch;
  }

  // ═══════════════════════════════════════════════════════════
  // 3. FIQIH — Auto-generate materi fiqih
  // ═══════════════════════════════════════════════════════════

  /// Dapatkan materi fiqih. Prioritas: cache → API → fallback
  Future<List<Map<String, dynamic>>> getFiqihItems() async {
    final context = _buildContext();

    // 1. Coba cache
    if (await _isCacheFreshAsync(_keyCacheFiqihTime, _cacheHoursFiqih)) {
      final cached = await _loadCache(_keyCacheFiqih);
      final parsed = _parseJsonArray(cached);
      if (parsed != null && parsed.isNotEmpty) return parsed;
    }

    // 2. Panggil API
    final isRamadhan = DateHelper.isRamadhanSeason(DateTime.now());
    final systemPrompt =
        '''
Kamu adalah ahli fiqih Islam untuk Muslim Indonesia.

Tugas: Hasilkan 20-40 item materi fiqih.
${isRamadhan ? 'FOKUS: FIQIH PUASA RAMADHAN — niat, batal, sunnah, qadha, fidyah, kafarat, tarawih, zakat fitrah, i\'tikaf, Lailatul Qadar.' : 'FOKUS: FIQIH UMUM — thaharah, shalat, zakat, muamalah, nikah, jenazah.'}

OUTPUT: Hanya array JSON, tanpa teks lain.
[{"id": "1", "title": "judul", "content": "isi materi", "category": "kategori", "source": "dalil"}]
GUNAKAN BAHASA INDONESIA. Sertakan dalil.
Category: ${isRamadhan ? 'salah satu dari: puasa, sholat, zakat, doa, amalan, thaharah, haid, muamalah, nikah, kurban, adab' : 'salah satu dari: thaharah, sholat, zakat, muamalah, nikah, jenazah, amalan, puasa, doa, kurban, adab, haid'}.
JANGAN gunakan markdown.
''';

    final result = await _callGroq(
      systemPrompt,
      context,
      temperature: 0.7,
      maxTokens: AiConfig.groqMaxTokensContent,
    );

    final parsed = _parseJsonArray(result);
    if (parsed != null && parsed.isNotEmpty) {
      await _saveCache(_keyCacheFiqih, _keyCacheFiqihTime, jsonEncode(parsed));
      return parsed;
    }

    // 3. Fallback statis
    return _fiqihFallback();
  }

  List<Map<String, dynamic>> _fiqihFallback() {
    return [
      {
        'id': '1',
        'title': 'Niat Puasa Ramadhan',
        'content':
            'Niat puasa Ramadhan termasuk rukun puasa yang wajib dilakukan setiap malam. Niat cukup di dalam hati, namun disunnahkan melafalkannya.',
        'category': 'puasa',
        'source': 'HR. Abu Dawud',
      },
      {
        'id': '2',
        'title': 'Hal-hal yang Membatalkan Puasa',
        'content':
            '1. Makan dan minum dengan sengaja\n2. Muntah dengan sengaja\n3. Haid dan nifas\n4. Keluar air mani dengan sengaja\n5. Gila\n6. Murtad\n7. Berhubungan suami istri di siang hari',
        'category': 'puasa',
      },
      {
        'id': '3',
        'title': 'Sunnah Puasa',
        'content':
            '1. Makan sahur\n2. Mengakhirkan sahur\n3. Menyegerakan berbuka\n4. Berbuka dengan kurma atau air\n5. Memperbanyak sedekah\n6. I\'tikaf\n7. Memperbanyak membaca Al-Qur\'an',
        'category': 'puasa',
      },
      {
        'id': '4',
        'title': 'Sholat Tarawih',
        'content':
            'Sholat Tarawih adalah sholat sunnah yang dikerjakan pada malam hari di bulan Ramadhan. Hukumnya sunnah muakkad.',
        'category': 'sholat',
      },
      {
        'id': '5',
        'title': 'Pengertian Jual Beli',
        'content':
            'Jual beli (al-bay\') hukumnya mubah dan dianjurkan jika dilakukan secara jujur. Rukun: penjual, pembeli, barang, ijab qabul. Dilarang: riba, gharar, dan tipuan.',
        'category': 'muamalah',
        'source': 'QS. Al-Baqarah: 275',
      },
      {
        'id': '6',
        'title': 'Riba dan Bahayanya',
        'content':
            'Riba adalah tambahan dalam utang piutang atau jual beli. Hukumnya haram dan termasuk dosa besar. Setiap utang yang mengambil manfaat adalah riba.',
        'category': 'muamalah',
        'source': 'QS. Al-Baqarah: 278-279',
      },
      {
        'id': '7',
        'title': 'Rukun Nikah',
        'content':
            'Rukun nikah ada 5: calon suami, calon istri, wali, dua saksi, dan ijab qabul. Syarat: baligh, berakal, tidak ada halangan syar\'i.',
        'category': 'nikah',
        'source': 'HR. Bukhari & Muslim',
      },
      {
        'id': '8',
        'title': 'Pengertian Kurban',
        'content':
            'Kurban (udhiyah) adalah menyembelih hewan ternak pada Idul Adha dan hari tasyrik. Hukumnya sunnah muakkad bagi yang mampu.',
        'category': 'kurban',
        'source': 'QS. Al-Kautsar: 2',
      },
      {
        'id': '9',
        'title': 'Adab Makan',
        'content':
            'Baca basmalah, gunakan tangan kanan, jangan berlebihan, jangan mencela makanan. Makan dari tepi dan jilat jari sebelum cuci tangan.',
        'category': 'adab',
        'source': 'HR. Bukhari & Muslim',
      },
      {
        'id': '10',
        'title': 'Zakat Fitrah',
        'content':
            'Zakat Fitrah wajib dikeluarkan oleh setiap muslim yang mampu pada bulan Ramadhan. Besarnya 1 sha\' (2,5 kg) makanan pokok.',
        'category': 'zakat',
      },
      {
        'id': '11',
        'title': 'I\'tikaf',
        'content':
            'I\'tikaf adalah berdiam diri di masjid dengan niat mendekatkan diri kepada Allah. Sunnah dilakukan terutama di 10 malam terakhir Ramadhan.',
        'category': 'amalan',
      },
      {
        'id': '12',
        'title': 'Lailatul Qadar',
        'content':
            'Lailatul Qadar (Malam Kemuliaan) lebih baik dari 1000 bulan. Terjadi pada 10 malam terakhir Ramadhan, terutama malam ganjil.',
        'category': 'amalan',
      },
      {
        'id': '13',
        'title': 'Haid dan Puasa',
        'content':
            'Wanita yang sedang haid atau nifas haram berpuasa dan wajib mengganti (qadha) di luar Ramadhan.',
        'category': 'haid',
      },
      {
        'id': '14',
        'title': 'Doa Berbuka Puasa',
        'content':
            '"Allahumma laka shumtu wa bika amantu wa \'ala rizqika afthartu, birrahmatika ya arhamar rahimin"',
        'category': 'doa',
      },
    ];
  }

  /// Paksa refresh cache untuk batch konten (reset waktu cache)
  Future<void> refreshFiqih() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCacheFiqihTime);
  }

  Future<void> refreshHadits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCacheBatchHaditsTime);
  }

  Future<void> refreshQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCacheBatchQuotesTime);
  }
}
