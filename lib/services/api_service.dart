import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/ai_config.dart';

/// Generic API Service untuk semua endpoint
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'User-Agent': 'UmmaApp/1.0',
  };

  // ─── GROQ AI ─────────────────────────────────────────────
  Future<Map<String, dynamic>> chatWithGroq({
    required String systemPrompt,
    required String userMessage,
    double temperature = 0.75,
  }) async {
    final response = await http.post(
      Uri.parse(AiConfig.groqBaseUrl),
      headers: {
        ..._defaultHeaders,
        'Authorization': 'Bearer ${AiConfig.groqApiKey}',
      },
      body: jsonEncode({
        'model': AiConfig.groqModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'temperature': temperature,
        'max_tokens': AiConfig.groqMaxTokensChat,
        'top_p': AiConfig.groqTopP,
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException('Groq API Error: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }

  // ─── QURAN API (equran.id) ──────────────────────────────
  Future<List<dynamic>> getSurahs() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.eQuranBaseUrl}${ApiConfig.surahEndpoint}'),
    );
    if (response.statusCode != 200) {
      throw HttpException('Gagal fetch surah');
    }
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  Future<Map<String, dynamic>> getSurahDetail(int number) async {
    final endpoint = ApiConfig.surahDetailEndpoint.replaceAll(
      '{number}',
      number.toString(),
    );
    final response = await http.get(
      Uri.parse('${ApiConfig.eQuranBaseUrl}$endpoint'),
    );
    if (response.statusCode != 200) {
      throw HttpException('Gagal fetch detail surah');
    }
    final data = jsonDecode(response.body);
    return data['data'] ?? {};
  }

  // ─── PRAYER TIMES API (EQuran.id - HTTPS, data Kemenag RI) ─
  Future<List<Map<String, dynamic>>> getPrayerTimes({
    required int year,
    required int month,
    required String city,
  }) async {
    final mapping = ApiConfig.cityToShalatMapping[city];
    if (mapping == null) {
      throw HttpException(
        'Kota "$city" tidak ditemukan dalam mapping jadwal sholat',
      );
    }

    final response = await http.post(
      Uri.parse(
        '${ApiConfig.equranShalatBaseUrl}${ApiConfig.equranShalatEndpoint}',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'provinsi': mapping['provinsi'],
        'kabkota': mapping['kabkota'],
        'bulan': month,
        'tahun': year,
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal fetch jadwal sholat: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> jadwal = decoded['data']?['jadwal'] ?? [];
    return jadwal.cast<Map<String, dynamic>>();
  }

  // ─── TAFSIR API (equran.id) ───────────────────────────────
  Future<Map<String, dynamic>> getTafsir(int surahNumber) async {
    final endpoint = ApiConfig.tafsirEndpoint.replaceAll(
      '{number}',
      surahNumber.toString(),
    );
    final response = await http.get(
      Uri.parse('${ApiConfig.eQuranBaseUrl}$endpoint'),
    );
    if (response.statusCode != 200) {
      throw HttpException('Gagal fetch tafsir');
    }
    final data = jsonDecode(response.body);
    return data['data'] ?? {};
  }

  // ─── HADITS API (hadis-api-id) ───────────────────────────
  Future<List<dynamic>> getHaditsBooks() async {
    final response = await http.get(Uri.parse(ApiConfig.haditsApiBaseUrl));
    if (response.statusCode != 200) {
      throw HttpException('Gagal fetch kitab hadits');
    }
    final data = jsonDecode(response.body);
    return data as List? ?? [];
  }

  Future<Map<String, dynamic>> getHadithRange({
    required String book,
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.haditsApiBaseUrl}${ApiConfig.haditsRangeEndpoint.replaceAll('{book}', book)}'
        '?page=$page&limit=$limit',
      ),
    );
    if (response.statusCode != 200) {
      throw HttpException('Gagal fetch hadits');
    }
    return jsonDecode(response.body);
  }

  // ─── REVERSE GEOCODING ──────────────────────────────────
  Future<Map<String, dynamic>> reverseGeocode(double lat, double lng) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.osmBaseUrl}${ApiConfig.osmReverseEndpoint}'
        '?lat=$lat&lon=$lng&format=json',
      ),
      headers: {'User-Agent': 'UmmaApp/1.0'},
    );
    if (response.statusCode != 200) {
      throw HttpException('Gagal reverse geocode');
    }
    return jsonDecode(response.body);
  }
}
