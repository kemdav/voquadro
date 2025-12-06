import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService extends ChangeNotifier {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final Logger _logger = Logger();

  bool _isMusicMuted = false;
  bool _isSfxMuted = false;
  bool _isDolphSfxMuted = false;
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;

  bool _isDucked = false;

  bool get isMusicMuted => _isMusicMuted;
  bool get isSfxMuted => _isSfxMuted;
  bool get isDolphSfxMuted => _isDolphSfxMuted;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  String? _currentAssetPath;

  SoundService() {
    _musicPlayer.setLoopMode(LoopMode.one);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isMusicMuted = prefs.getBool('music_muted') ?? false;
      _isSfxMuted = prefs.getBool('sfx_muted') ?? false;
      _isDolphSfxMuted = prefs.getBool('dolph_sfx_muted') ?? false;
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
      _sfxVolume = prefs.getDouble('sfx_volume') ?? 1.0;
      
      _updateMusicVolume();
      notifyListeners();
    } catch (e) {
      _logger.e("Error loading sound settings: $e");
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('music_muted', _isMusicMuted);
      await prefs.setBool('sfx_muted', _isSfxMuted);
      await prefs.setBool('dolph_sfx_muted', _isDolphSfxMuted);
      await prefs.setDouble('music_volume', _musicVolume);
      await prefs.setDouble('sfx_volume', _sfxVolume);
    } catch (e) {
      _logger.e("Error saving sound settings: $e");
    }
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

      _updateMusicVolume();
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

  /// Lowers the background music volume temporarily (ducking)
  void duckMusic(bool enable) {
    if (_isDucked == enable) return;
    _isDucked = enable;
    _updateMusicVolume();
    _updateCelebrationVolume();
  }

  void _updateMusicVolume() {
    if (_isMusicMuted) {
      _musicPlayer.setVolume(0);
    } else {
      double targetVolume = _musicVolume;
      if (_isDucked) {
        targetVolume *= 0.2; // Duck to 20%
      }
      _musicPlayer.setVolume(targetVolume);
    }
  }

  void _updateCelebrationVolume() {
    if (_celebrationPlayer == null) return;

    if (_isSfxMuted) {
      _celebrationPlayer!.setVolume(0);
    } else {
      double targetVolume = _sfxVolume;
      if (_isDucked) {
        targetVolume *= 0.2; // Duck to 20%
      }
      _celebrationPlayer!.setVolume(targetVolume);
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
      _updateCelebrationVolume();
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
    _updateMusicVolume();
    _saveSettings();
    notifyListeners();
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    _updateCelebrationVolume();
    _saveSettings();
    notifyListeners();
  }

  void toggleMusicMute() {
    _isMusicMuted = !_isMusicMuted;
    _updateMusicVolume();
    _saveSettings();
    notifyListeners();
  }

  void toggleSfxMute() {
    _isSfxMuted = !_isSfxMuted;
    _updateCelebrationVolume();
    _saveSettings();
    notifyListeners();
  }

  void toggleDolphSfxMute() {
    _isDolphSfxMuted = !_isDolphSfxMuted;
    _saveSettings();
    notifyListeners();
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    super.dispose();
  }
}
