/// ============================================================
/// AI CONFIG — Konfigurasi AI (Groq, prompts, system settings)
/// ============================================================
/// Semua data yang berkaitan dengan AI dipisah dari api_config.dart
/// agar lebih mudah dikelola dan tidak tercampur dengan API endpoint.
/// ============================================================
library;

class AiConfig {
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 1. API CONNECTION
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String groqBaseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  /// API key Groq default (built-in) untuk konten: quotes, nasehat, quest, fiqih
  static const String groqApiKeyDefault =
      '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';
  /// API key Groq untuk Muslim AI Chat — bisa diubah runtime via LocalStorage
  static String groqApiKey = '';
  static const String groqModel = 'llama-3.3-70b-versatile';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 2. TEMPERATURE & TOKENS
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// Chat mode (Muslim AI chat)
  static const double groqTemperatureChat = 0.75;
  static const int groqMaxTokensChat = 512;

  /// Reference mode (doa, surah, fiqih, hadits) — lebih hemat token
  static const double groqTemperatureReference = 0.4;
  static const int groqMaxTokensReference = 256;

  /// Content generation (quotes, nasehat, quest, fiqih items)
  static const int groqMaxTokensContent = 8192;

  static const double groqTopP = 0.9;
  static const int groqTimeoutSeconds = 30;
  static const int groqRetryCount = 1;

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 3. COOLDOWN (dynamic escalation)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String storageKeyAiNextAvailable = 'umma_ai_next_available';
  static const String storageKeyAiLastMessage = 'umma_ai_last_message';
  static const String storageKeyAiFastCount = 'umma_ai_fast_count';
  static const String storageKeyAiTotalMs = 'umma_ai_total_ms';
  static const Duration aiCooldownDuration = Duration(seconds: 3);

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 4. SYSTEM PROMPTS — Mode Instructions
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /// Base system prompt untuk Muslim AI chat
  static String buildSystemPrompt({
    required String greeting,
    required String modeInstructions,
    String hijriContext = '',
    String? journalContext,
  }) {
    final parts = <String>[
      'Kamu adalah Muslim AI, asisten ibadah dari aplikasi Umma untuk Muslim Indonesia.',
      '',
      'KONTEKS:',
      '- Waktu: $greeting',
      if (hijriContext.isNotEmpty) '- $hijriContext',
      if (journalContext != null) '',
      if (journalContext != null) 'JURNAL USER:',
      ?journalContext,
      '',
      modeInstructions,
      '',
      'ATURAN:',
      '- Respons singkat & padat. Jangan bertele-tele.',
      '- Markdown untuk penekanan, emoji secukupnya',
      '- Bukan dokter/psikolog/mufti',
      '',
      'MARKER APLIKASI (HANYA jika user minta konten spesifik):',
      'HANYA gunakan marker di bawah jika user MEMINTA konten yang ADA di aplikasi.',
      'JANGAN gunakan marker untuk sapaan, obrolan santai, atau pertanyaan umum.',
      'Jika user cuma sapa/nanya umum, jawab tanpa marker.',
      '',
      'Marker yang tersedia:',
      '[Buka:quran:SURAH:AYAH] — Contoh: [Buka:quran:2:255] buka Ayat Kursi',
      '[Buka:surah:N] — buka surah tertentu',
      '[Buka:doa:ID] — doa-sehari-hari, doa-sholat, doa-puasa, doa-taubat, doa-perlindungan, dzikir-pagi, doa-orangtua, doa-alam, doa-sakit, asmaul-husna',
      '[Buka:hadits:SLUG:NUMBER] — SLUG: bukhari, muslim, tirmidzi, nasai, abu-dawud, ibnu-majah, ahmad, malik, darimi',
      '[Buka:fiqih:N] — 1-10 Thaharah, 11-25 Sholat, 26-41 Puasa, 42-51 Zakat, 52-57 Haid, 58-64 Jenazah, 65-73 Amalan',
      '[Buka:zakat] [Buka:tasbih] [Buka:tracker] [Buka:jurnal]',
      '[Cari:QUERY] — Google Search untuk topik di luar Umma',
    ];
    return parts.join('\n');
  }

  /// Mode instructions berdasarkan mode chat
  static const Map<String, String> modeInstructions = {
    'doa':
        'MODE: PENCARI DOA. Format: Arab + Latin + Arti + Sumber. Tanpa alternatif.',
    'surah':
        'MODE: TAFSIR. Surah panjang: tanya range. Pendek: tampilkan. Format: Arab + Latin + Arti + QS.',
    'fiqih':
        'MODE: FIQIH. Format: Hukum > Dalil > Penjelasan. Sertakan perbedaan pendapat.',
    'hadits':
        'MODE: HADITS. Format: Arab + Arti + Perawi + Derajat. Faedah praktis.',
    'ngobrol':
        'MODE: SAHABAT. Empatik, hangat. Sesuaikan tone: Pagi=sabar, Siang=semangat, Malam=reflektif.',
  };

  /// Dapatkan mode instructions untuk mode tertentu
  static String getModeInstruction(String mode) =>
      modeInstructions[mode] ?? modeInstructions['ngobrol']!;

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 5. CONTENT GENERATION PROMPTS — Quotes, Hadits, Fiqih
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String promptQuotes = '''
Kamu adalah penulis konten Islami untuk Muslim Indonesia.

Tugas: Hasilkan 30 kutipan Islami INSPIRATIF yang BERBEDA.
FOKUS: Sesuaikan dengan konteks (Ramadhan atau umum).

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"text": "kutipan ke-1", "author": "sumber"}, ...]
BUAT 30 ITEM! JANGAN gunakan markdown.
''';

  static const String promptNasehat = '''
Kamu adalah pendakwah untuk Muslim Indonesia.

Tugas: Hasilkan 30 nasehat/pelajaran hadits yang BERBEDA dan INSPIRATIF.
FOKUS: Sesuaikan dengan konteks (Ramadhan atau umum).

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"id": "1", "title": "judul", "content": "isi", "source": "sumber dalil"}]
BUAT 30 ITEM! JANGAN gunakan markdown.
''';

  static const String promptQuest = '''
Kamu adalah pembuat program tantangan ibadah harian untuk Muslim Indonesia.

Tugas: Hasilkan 30 tantangan/misi ibadah harian (daily quest) yang BERBEDA dan MENARIK.
FOKUS: Sesuaikan dengan konteks (Ramadhan atau umum).

OUTPUT: Hanya array JSON dengan 30 objek, tanpa teks lain.
[{"id": "1", "title": "nama quest", "description": "penjelasan", "reward": "manfaat"}]
BUAT 30 ITEM! JANGAN gunakan markdown.
''';

  static const String promptFiqih = '''
Kamu adalah ahli fiqih Islam untuk Muslim Indonesia.

Tugas: Hasilkan 20-40 item materi fiqih.
FOKUS: Sesuaikan dengan konteks (Ramadhan atau umum).

OUTPUT: Hanya array JSON, tanpa teks lain.
[{"id": "1", "title": "judul materi", "content": "isi", "category": "kategori", "source": "dalil"}]
GUNAKAN BAHASA INDONESIA. Sertakan dalil.
JANGAN gunakan markdown.
''';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 6. CONTENT CACHE DURATIONS (jam)
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const int cacheHoursHadits = 24;
  static const int cacheHoursFiqih = 48;
  static const int cacheHoursQuest = 24;
  static const int cacheHoursBatch = 24;

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 7. CONTENT CACHE KEYS
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String keyCacheFiqih = 'ai_cache_fiqih';
  static const String keyCacheFiqihTime = 'ai_cache_fiqih_time';
  static const String keyCacheBatchQuotes = 'ai_cache_batch_quotes';
  static const String keyCacheBatchQuotesTime = 'ai_cache_batch_quotes_time';
  static const String keyCacheBatchHadits = 'ai_cache_batch_hadits';
  static const String keyCacheBatchHaditsTime = 'ai_cache_batch_hadits_time';
  static const String keyCacheBatchQuest = 'ai_cache_batch_quest';
  static const String keyCacheBatchQuestTime = 'ai_cache_batch_quest_time';

  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 8. MARKERS — Format untuk integrasi aplikasi
  //━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  static const String markerPattern = r'\[Buka:(\w+):?([\w-]+)?:?(\w+)?\]';
  static const String markerSearch = r'\[Cari:(.+?)\]';
}
