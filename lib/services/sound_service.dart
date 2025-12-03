import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class SoundService extends ChangeNotifier {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Logger _logger = Logger();

  bool _isMusicMuted = false;
  bool _isSfxMuted = false;
  bool _isDolphSfxMuted = false;
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;

  bool get isMusicMuted => _isMusicMuted;
  bool get isSfxMuted => _isSfxMuted;
  bool get isDolphSfxMuted => _isDolphSfxMuted;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  String? _currentAssetPath;

  SoundService() {
    _musicPlayer.setLoopMode(LoopMode.one);
  }

  /// Plays background music from an asset.
  /// [assetPath] should be the full path, e.g., 'assets/audio/music.mp3'
  Future<void> playMusic(String assetPath) async {
    // If the requested music is already playing, do nothing to avoid restart.
    if (_currentAssetPath == assetPath && _musicPlayer.playing) {
      return;
    }

    try {
      // Only load the asset if it's different from the current one
      if (_currentAssetPath != assetPath) {
        _currentAssetPath = assetPath;
        await _musicPlayer.setAsset(assetPath);
      }

      _musicPlayer.setVolume(_isMusicMuted ? 0 : _musicVolume);
      await _musicPlayer.play();
    } catch (e) {
      _logger.e("Error playing music: $e");
      _currentAssetPath = null;
    }
  }

  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (!_musicPlayer.playing) {
      await _musicPlayer.play();
    }
  }

  /// Plays a sound effect from an asset.
  /// Creates a new player instance to allow overlapping sounds.
  Future<void> playSfx(String assetPath) async {
    if (_isSfxMuted) return;
    if (assetPath.contains('dolph_sound.wav') && _isDolphSfxMuted) return;

    final player = AudioPlayer();
    try {
      await player.setAsset(assetPath);
      player.setVolume(_sfxVolume);
      await player.play();

      // Dispose the player after playback finishes
      await player.dispose();
    } catch (e) {
      _logger.e("Error playing SFX: $e");
      await player.dispose();
    }
  }

  AudioPlayer? _celebrationPlayer;

  /// Plays the celebration sound.
  /// Stops any existing celebration sound first.
  Future<void> playCelebration() async {
    if (_isSfxMuted) return;

    await stopCelebration();
    _celebrationPlayer = AudioPlayer();
    try {
      await _celebrationPlayer!.setAsset('assets/audio/celebration.mp3');
      _celebrationPlayer!.setVolume(_sfxVolume);
      await _celebrationPlayer!.play();
    } catch (e) {
      _logger.e("Error playing celebration: $e");
    }
  }

  /// Stops the celebration sound if it's playing.
  Future<void> stopCelebration() async {
    if (_celebrationPlayer != null) {
      try {
        await _celebrationPlayer!.stop();
        await _celebrationPlayer!.dispose();
      } catch (e) {
        _logger.e("Error stopping celebration: $e");
      }
      _celebrationPlayer = null;
    }
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (!_isMusicMuted) {
      _musicPlayer.setVolume(_musicVolume);
    }
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  void toggleMusicMute() {
    _isMusicMuted = !_isMusicMuted;
    _musicPlayer.setVolume(_isMusicMuted ? 0 : _musicVolume);
    notifyListeners();
  }

  void toggleSfxMute() {
    _isSfxMuted = !_isSfxMuted;
    notifyListeners();
  }

  void toggleDolphSfxMute() {
    _isDolphSfxMuted = !_isDolphSfxMuted;
    notifyListeners();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }
}
