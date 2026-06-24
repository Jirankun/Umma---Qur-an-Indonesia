import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../config/colors.dart';
import '../../../config/strings.dart';
import '../../../config/api_config.dart';
import '../../../models/quran.dart';
import '../../../providers/theme_provider.dart';
import '../../../services/api_service.dart';

/// Tafsir sheet — load + display tafsir dari Kemenag RI
///
/// Tafsir disimpan sebagai file JSON permanen di:
///   {appDocDir}/quran/tafsir/{surahId}.json
///
/// Data tetap ada sampai aplikasi di-uninstall, tanpa perlu
/// di-download ulang setiap kali buka surah.
///
/// Panggil [TafsirSheet.prefetch] setelah surah dimuat agar tafsir
/// tersedia langsung tanpa loading saat user mengetuk tombol tafsir.
class TafsirSheet extends StatefulWidget {
  final Ayat ayat;
  final Surah surah;

  const TafsirSheet({super.key, required this.ayat, required this.surah});

  /// Prefetch tafsir untuk seluruh surah — simpan ke disk sebagai JSON + cache.
  /// Panggil saat user masuk surah.
  static Future<void> prefetch(int surahId) async {
    // Cek dulu apakah file JSON sudah ada di disk
    final file = await _tafsirFile(surahId);
    if (await file.exists()) return;

    try {
      final ayatMap = await _fetchFromApi(surahId);
      // Simpan ke disk sebagai JSON permanen
      await file.writeAsString(jsonEncode(ayatMap));
      // Simpan ke in-memory cache untuk akses instan
      _TafsirSheetState._cache[surahId] = ayatMap;
    } catch (_) {
      // Gagal prefetch — tidak masalah, nanti di-load saat tafsir dibuka
    }
  }

  /// Path file tafsir di disk: {appDocDir}/quran/tafsir/{surahId}.json
  static Future<File> _tafsirFile(int surahId) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDocDir.path}/${ApiConfig.tafsirStorageDir}');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File('${dir.path}/$surahId.json');
  }

  /// Load tafsir dari disk (prioritas) → in-memory cache → API
  static Future<Map<int, String>> _loadFromDisk(int surahId) async {
    try {
      final file = await _tafsirFile(surahId);
      if (await file.exists()) {
        final raw = await file.readAsString();
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(int.parse(k), v as String));
      }
    } catch (_) {
      // Gagal baca disk — lanjut ke API
    }
    return {};
  }

  /// Shared: fetch tafsir dari API dan parse ke `Map<int, String>`
  static Future<Map<int, String>> _fetchFromApi(int surahId) async {
    final data = await ApiService().getTafsir(surahId);
    final List<dynamic> tafsirList = data['tafsir'] ?? [];
    final ayatMap = <int, String>{};
    for (final item in tafsirList) {
      final ayatNum = item['ayat'] as int? ?? 0;
      final teks = (item['teks'] as String? ?? '').trim();
      if (ayatNum > 0 && teks.isNotEmpty) {
        ayatMap[ayatNum] = teks;
      }
    }
    return ayatMap;
  }

  @override
  State<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends State<TafsirSheet> {
  /// In-memory cache (sesi) untuk akses cepat setelah disk load
  static final Map<int, Map<int, String>> _cache = {};

  bool _loading = true;
  String _tafsirText = '';
  String? _sourceLabel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final surahId = widget.surah.nomor;
      Map<int, String> ayatMap;

      // 1. Cek in-memory cache dulu (paling cepat)
      if (_cache.containsKey(surahId)) {
        ayatMap = _cache[surahId]!;
      } else {
        // 2. Cek file JSON di disk (persistent)
        ayatMap = await TafsirSheet._loadFromDisk(surahId);
        if (ayatMap.isEmpty) {        // 3. Fallback ke API, lalu simpan ke disk + cache
          ayatMap = await TafsirSheet._fetchFromApi(surahId);
          _cache[surahId] = ayatMap;
          try {
            final file = await TafsirSheet._tafsirFile(surahId);
            await file.writeAsString(jsonEncode(ayatMap));
          } catch (_) {}
        }
        // Simpan ke in-memory cache
        _cache[surahId] = ayatMap;
      }

      final text = ayatMap[widget.ayat.nomorAyat] ?? '';
      if (mounted) {
        setState(() {
          _loading = false;
          _tafsirText = text;
          _sourceLabel = 'Tafsir ${widget.surah.namaLatin} \u2014 Kemenag RI';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _tafsirText = '';
          _sourceLabel = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDark;

    if (_loading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.cupertinoSystemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(child: CupertinoActivityIndicator(radius: 14)),
      );
    }

    return Container(
      height: 460,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark
            : AppColors.cupertinoSystemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cupertinoSystemGrey4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.heat4.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    AppStrings.quranTafsir,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.surah.namaLatin} \u2014 Ayat ${widget.ayat.nomorAyat}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color:
                        isDark ? AppColors.cupertinoWhite : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _tafsirText,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.7,
                    color:
                        isDark ? AppColors.cupertinoWhite : AppColors.textLight,
                  ),
                ),
              ),
            ),
            if (_sourceLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                _sourceLabel!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cupertinoSystemGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
