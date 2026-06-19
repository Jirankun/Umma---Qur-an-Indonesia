import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for background ambient sound on the Home screen.
/// Plays one of two looping audio files based on time of day:
/// - bg_night.mp3: from Maghrib (18:00) to Subuh (05:00)
/// - bg_sunrise.mp3: from Subuh (05:00) to Maghrib (18:00)
class BackgroundSoundProvider extends ChangeNotifier {
  static const String _storageKey = 'umma_bg_sound_enabled';

  AudioPlayer? _player;
  bool _isEnabled = false;
  bool _initialized = false;
  final Completer<void> _initCompleter = Completer<void>();
  String? _currentAudioType; // 'night' or 'sunrise'

  bool get isEnabled => _isEnabled;
  String? get currentAudioType => _currentAudioType;
  bool get isPlaying => _player?.state == PlayerState.playing;
  bool get isInitialized => _initialized;
  /// Future that completes when loadSettings() has finished.
  Future<void> get ready => _initCompleter.future;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_storageKey) ?? false;
    } catch (_) {
      _isEnabled = false;
    } finally {
      _initialized = true;
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      notifyListeners();
    }
  }

  /// Toggle background sound on/off
  Future<void> toggle() async {
    _isEnabled = !_isEnabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, _isEnabled);

    if (!_isEnabled) {
      await _stopPlayer();
    }
    notifyListeners();
  }

  /// Start playing the appropriate audio based on time of day.
  /// Called when user is on the Home screen.
  /// Akan menunggu loadSettings() selesai jika belum diinisialisasi.
  Future<void> start() async {
    if (!_initialized) {
      await _initCompleter.future;
    }
    if (!_isEnabled) return;

    final audioType = _getAudioType();
    final assetPath = _getAssetPath(audioType);

    // If already playing the correct audio, do nothing
    if (_currentAudioType == audioType &&
        _player?.state == PlayerState.playing) {
      return;
    }

    await _stopPlayer();

    _player = AudioPlayer();
    _player!.setReleaseMode(ReleaseMode.loop);
    _player!.onPlayerComplete.listen((_) {
      // Loop: AudioPlayer dengan ReleaseMode.loop akan loop otomatis
    });

    try {
      await _player!.setSource(AssetSource(assetPath));
      await _player!.setVolume(0.5);
      await _player!.resume();
      _currentAudioType = audioType;
    } catch (e) {
      debugPrint('BackgroundSound: Gagal play audio — $e');
      _currentAudioType = null;
    }
    notifyListeners();
  }

  /// Stop audio. Called when user leaves the Home screen or disables sound.
  Future<void> stop() async {
    await _stopPlayer();
    notifyListeners();
  }

  Future<void> _stopPlayer() async {
    await _player?.stop();
    await _player?.dispose();
    _player = null;
    _currentAudioType = null;
  }

  /// Determine time of day based on fixed schedule:
  /// Night: 18:00 - 04:59
  /// Sunrise: 05:00 - 17:59
  String _getAudioType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 18) {
      return 'sunrise';
    }
    return 'night';
  }

  String _getAssetPath(String type) {
    return type == 'night' ? 'audio/bg_night.mp3' : 'audio/bg_sunrise.mp3';
  }

  @override
  void dispose() {
    _player?.stop();
    _player?.dispose();
    super.dispose();
  }
}
