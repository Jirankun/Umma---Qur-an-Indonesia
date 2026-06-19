import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ai_config.dart';

/// Service untuk Muslim AI (Groq API)
class AiService {
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Send message to Groq AI with context
  Future<String> sendMessage({
    required String message,
    required String mode,
    String? journalContext,
    String? greeting,
    int day = 0,
    String timeString = '00:00',
  }) async {
    // Cek apakah API key sudah diatur
    if (AiConfig.groqApiKey.isEmpty) {
      throw Exception(
        'API key Groq belum diatur. Masukkan API key di menu Profil > Pengaturan AI.',
      );
    }

    final hijriContext =
        day > 0 ? 'Sekarang Ramadhan 1447 H (hari ke-$day).' : '';

    final modeInstructions = AiConfig.getModeInstruction(mode);

    final systemPrompt = AiConfig.buildSystemPrompt(
      greeting: greeting ?? 'Siang',
      modeInstructions: modeInstructions,
      hijriContext: hijriContext,
      journalContext: journalContext,
    );

    Future<String> callGroq() async {
      final response = await http
          .post(
            Uri.parse(AiConfig.groqBaseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${AiConfig.groqApiKey}',
            },
            body: jsonEncode({
              'model': AiConfig.groqModel,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': message},
              ],
              'temperature': mode == 'ngobrol'
                  ? AiConfig.groqTemperatureChat
                  : AiConfig.groqTemperatureReference,
              'max_tokens': mode == 'ngobrol'
                  ? AiConfig.groqMaxTokensChat
                  : AiConfig.groqMaxTokensReference,
              'top_p': AiConfig.groqTopP,
            }),
          )
          .timeout(const Duration(seconds: AiConfig.groqTimeoutSeconds));

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Groq error: ${errorData['error']?['message'] ?? errorData['error'] ?? response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);
      return data['choices']?[0]?['message']?['content'] ??
          'Maaf, aku lagi bingung jawabnya. Coba tanyain lagi ya 🙏';
    }

    try {
      return await callGroq();
    } catch (_) {
      try {
        return await callGroq();
      } catch (e) {
        throw Exception('Gagal terhubung ke AI: $e');
      }
    }
  }

  String getModeInstructions(String mode) => AiConfig.getModeInstruction(mode);
}
