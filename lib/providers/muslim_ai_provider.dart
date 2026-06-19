import 'dart:async';
import 'package:flutter/cupertino.dart';
import '../config/ai_config.dart';
import '../models/models.dart';
import '../services/ai_service.dart';
import '../services/local_storage.dart';
import '../utils/date_helper.dart';

class MuslimAiProvider extends ChangeNotifier {
  static const String _welcomeMessage =
      'Assalamualaikum! 👋\n\nAku Muslim AI. Mau ngobrol santai atau cari info ibadah spesifik? Pilih mode di atas dan tanyain aja ke aku!';

  // Simple response cache: key = normalized user message, value = AI reply
  final Map<String, String> _responseCache = {};
  static const int _maxCacheSize = 50;

  final List<ChatMessage> _messages = [
    ChatMessage(id: 'welcome', role: 'ai', text: _welcomeMessage),
  ];
  bool _isLoading = false;
  String _activeMode = 'ngobrol';
  String? _journalContext;

  // ─── Fixed 5-Second Cooldown ─────────────────────────────
  static const int _cooldownMs = 5000;
  DateTime? _cooldownStartedAt;
  double _cooldownProgress = 0.0;
  Timer? _cooldownTimer;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String get activeMode => _activeMode;
  double get cooldownProgress => _cooldownProgress;
  int get cooldownSeconds => _cooldownMs ~/ 1000;

  bool get canSend {
    if (_isLoading) return false;
    if (_cooldownStartedAt == null) return true;
    return DateTime.now().difference(_cooldownStartedAt!).inMilliseconds >=
        _cooldownMs;
  }

  /// Load cooldown state from storage
  Future<void> loadCooldown() async {
    final storage = LocalStorage();
    final raw = storage.getString(AiConfig.storageKeyAiNextAvailable);

    if (raw != null) {
      final next = DateTime.tryParse(raw);
      if (next != null && next.isAfter(DateTime.now())) {
        _cooldownStartedAt = next.subtract(
          const Duration(milliseconds: _cooldownMs),
        );
        _startCooldownTimer();
      }
    }
    notifyListeners();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _updateCooldownProgress();
    });
    _updateCooldownProgress();
  }

  void _updateCooldownProgress() {
    if (_cooldownStartedAt == null) {
      _cooldownProgress = 0.0;
      _cooldownTimer?.cancel();
      notifyListeners();
      return;
    }

    final elapsed = DateTime.now()
        .difference(_cooldownStartedAt!)
        .inMilliseconds;

    if (elapsed >= _cooldownMs) {
      _cooldownProgress = 1.0;
      _cooldownStartedAt = null;
      _cooldownTimer?.cancel();
      LocalStorage().remove(AiConfig.storageKeyAiNextAvailable);
      notifyListeners();
      return;
    }

    _cooldownProgress = (elapsed / _cooldownMs).clamp(0.0, 1.0);
    notifyListeners();
  }

  void setMode(String mode) {
    _activeMode = mode;
    notifyListeners();
  }

  void setJournalContext(String? context) {
    _journalContext = context;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (!canSend) return;

    final now = DateTime.now();

    // Fixed 5 detik cooldown
    _cooldownStartedAt = now;

    final storage = LocalStorage();
    await storage.setString(
      AiConfig.storageKeyAiNextAvailable,
      now.add(const Duration(milliseconds: _cooldownMs)).toIso8601String(),
    );

    _startCooldownTimer();

    final userMessage = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      role: 'user',
      text: text,
    );
    _messages.add(userMessage);

    _isLoading = true;
    notifyListeners();

    // Cek cache dulu untuk hemat token (hanya setelah cooldown selesai)
    final journalHash = _journalContext?.hashCode ?? 0;
    final cacheKey = '$_activeMode:${text.trim().toLowerCase()}:$journalHash';
    final cachedReply = _responseCache[cacheKey];
    if (cachedReply != null) {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'ai',
          text: cachedReply,
        ),
      );
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final greeting = now.hour < 11
          ? 'Pagi'
          : now.hour < 15
          ? 'Siang'
          : now.hour < 18
          ? 'Sore'
          : 'Malam';

      final reply = await AiService().sendMessage(
        message: text,
        mode: _activeMode,
        journalContext: _journalContext,
        greeting: greeting,
        day: _calculateHijriDay(),
        timeString:
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      );

      // Simpan ke cache (limit ukuran cache)
      if (_responseCache.length >= _maxCacheSize) {
        _responseCache.remove(_responseCache.keys.first);
      }
      _responseCache[cacheKey] = reply;

      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'ai',
          text: reply,
        ),
      );
    } catch (e) {
      final errorMsg = AiConfig.groqApiKey.isEmpty
          ? 'API key Groq belum diatur.\n\nMasukkan API key di menu Profil > Pengaturan AI untuk menggunakan Muslim AI.'
          : 'Yah, koneksi terputus. Cek internetmu ya 🙏';
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'ai',
          text: errorMsg,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int _calculateHijriDay() {
    final now = DateTime.now();
    if (DateHelper.isRamadhanSeason(now)) {
      final ramadhanStart = DateTime(2026, 2, 19);
      final diff = now.difference(ramadhanStart).inDays + 1;
      return diff > 0 && diff <= 30 ? diff : 0;
    }
    return 0;
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void clearMessages() {
    _messages
      ..clear()
      ..add(ChatMessage(id: 'welcome', role: 'ai', text: _welcomeMessage));
    _journalContext = null;
    _responseCache.clear();
    notifyListeners();
  }
}
