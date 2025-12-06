import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voquadro/theme/voquadro_colors.dart';
import 'dart:io';
import 'dart:async';

class InterviewAudioPlayer extends StatefulWidget {
  final String? mergedAudioPath;
  final List<String> sessionAudioPaths;

  const InterviewAudioPlayer({
    super.key,
    this.mergedAudioPath,
    this.sessionAudioPaths = const [],
  });

  @override
  State<InterviewAudioPlayer> createState() => _InterviewAudioPlayerState();
}

class _InterviewAudioPlayerState extends State<InterviewAudioPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _totalDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateSubscription;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  @override
  void didUpdateWidget(InterviewAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mergedAudioPath != oldWidget.mergedAudioPath ||
        !listEquals(widget.sessionAudioPaths, oldWidget.sessionAudioPaths)) {
      _stopAndReinit();
    }
  }

  Future<void> _stopAndReinit() async {
    try {
      await _player.stop();
    } catch (e) {
      // Ignore stop errors
    }
    if (mounted) {
      _initAudio();
    }
  }

  void _cancelSubscriptions() {
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _sequenceStateSubscription?.cancel();
  }

  Future<void> _initAudio() async {
    _cancelSubscriptions();
    
    try {
      _totalDuration = Duration.zero;
      _currentPosition = Duration.zero;

      if (!mounted) return;

      if (widget.mergedAudioPath != null && File(widget.mergedAudioPath!).existsSync()) {
        await _player.setFilePath(widget.mergedAudioPath!);
      } else if (widget.sessionAudioPaths.isNotEmpty) {
        final playlist = ConcatenatingAudioSource(
          useLazyPreparation: false,
          children: widget.sessionAudioPaths
              .map((path) => AudioSource.file(path))
              .toList(),
        );
        await _player.setAudioSource(playlist);
      }

      _playerStateSubscription = _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });

      _durationSubscription = _player.durationStream.listen((d) {
        if (mounted && widget.mergedAudioPath != null) {
           setState(() => _totalDuration = d ?? Duration.zero);
        }
      });

      _positionSubscription = _player.positionStream.listen((p) {
        if (mounted) {
          if (widget.mergedAudioPath != null) {
            setState(() => _currentPosition = p);
          } else {
            _updatePlaylistPosition(p);
          }
        }
      });
      
      _sequenceStateSubscription = _player.sequenceStateStream.listen((sequenceState) {
        if (sequenceState == null) return;
        // Handle playlist duration logic if needed
      });

    } catch (e) {
      debugPrint("Error initializing audio playback: $e");
    }
  }

  void _updatePlaylistPosition(Duration currentItemPosition) {
    if (!mounted) return;
    setState(() {
      _currentPosition = currentItemPosition;
      _totalDuration = _player.duration ?? Duration.zero;
    });
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: VoquadroColors.primaryPurple,
                ),
                onPressed: () {
                  if (_isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: (_currentPosition.inSeconds.toDouble()).clamp(0.0, (_totalDuration.inSeconds.toDouble() > 0 ? _totalDuration.inSeconds.toDouble() : 1.0)),
            min: 0,
            max: _totalDuration.inSeconds.toDouble() > 0 ? _totalDuration.inSeconds.toDouble() : 1.0,
            activeColor: VoquadroColors.primaryPurple,
            inactiveColor: Colors.grey.shade700,
            onChanged: (value) {
              _player.seek(Duration(seconds: value.toInt()));
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
                Text(
                  _formatDuration(_totalDuration),
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
