import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';

/// AudioHandler untuk Murattal — memungkinkan playback tetap jalan
/// saat app di-minimize atau layar dimatikan (Android foreground service).
///
/// UI screen bisa akses via [instance] static getter.
class MurattalAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  /// Instance global — di-set waktu [AudioService.init]
  static MurattalAudioHandler? _instance;
  static MurattalAudioHandler? get instance => _instance;

  // ── Exposed streams untuk UI ──────────────────────────────
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;
  Stream<PlayerState> get onPlayerStateChanged =>
      _player.onPlayerStateChanged;
  Stream<void> get onPlayerComplete => _player.onPlayerComplete;
  PlayerState get currentState => _player.state;
  bool get isActuallyPlaying => _player.state == PlayerState.playing;

  MurattalAudioHandler() {
    _instance = this;

    // Sinkronisasi state player ke AudioService untuk OS integration
    _player.onPlayerStateChanged.listen((state) {
      playbackState.add(playbackState.value.copyWith(
        playing: state == PlayerState.playing,
        processingState: state == PlayerState.playing
            ? AudioProcessingState.ready
            : AudioProcessingState.idle,
      ));
    });

    _player.onPositionChanged.listen((pos) {
      playbackState.add(playbackState.value.copyWith(
        updatePosition: pos,
      ));
    });

    _player.onDurationChanged.listen((dur) {
      playbackState.add(playbackState.value.copyWith(
        bufferedPosition: dur,
      ));
    });
  }

  /// Memuat dan memainkan audio dari URL lokal atau remote.
  Future<void> setSource({
    required String source,
    required String title,
    String? artist,
    Duration? duration,
    bool isLocal = false,
  }) async {
    await _player.stop();

    mediaItem.add(MediaItem(
      id: source,
      title: title,
      artist: artist ?? '',
      duration: duration,
    ));

    if (isLocal) {
      await _player.play(DeviceFileSource(source));
    } else {
      await _player.play(UrlSource(source));
    }
  }

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToPrevious() async {}

  @override
  Future<void> skipToNext() async {}

  /// Bersihkan player (dipanggil saat keluar screen)
  Future<void> reset() async {
    await _player.stop();
  }

  /// Bersihkan resource internal (audio_service tidak punya dispose())
  void shutdown() {
    _player.dispose();
  }
}
