import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPlaying = false;
  Duration _audioDuration = const Duration(seconds: 30);
  Duration _currentPosition = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isDragging = false;
  double? _dragPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _audioDuration)
      ..addListener(_updatePosition);

    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      // Use AssetSource instead of UrlSource for local assets
      await _audioPlayer.setSource(UrlSource(widget.audioUrl));
      final duration = await _audioPlayer.getDuration();
      if (duration != null) {
        setState(() {
          _audioDuration = duration;
          _controller.duration = duration;
        });
      }

      _audioPlayer.onPositionChanged.listen((position) {
        if (!_isDragging) {
          _controller.value =
              position.inMilliseconds / _audioDuration.inMilliseconds;
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) async {
        setState(() {
          _isPlaying = false;
          _controller.value = 0;
          _currentPosition = Duration.zero;
        });
        // Re-set the audio source to allow replay
        try {
          await _audioPlayer.setSource(UrlSource(widget.audioUrl));
        } catch (e) {
          debugPrint("Audio player reset error: $e");
        }
      });
    } catch (e) {
      debugPrint("Audio player init error: $e");
    }
  }

  void _updatePosition() {
    if (!_isDragging) {
      setState(() {
        _currentPosition = _audioDuration * _controller.value;
      });
    }
  }

  void _togglePlay() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      // If audio is finished, restart from beginning
      if (_currentPosition >= _audioDuration) {
        await _audioPlayer.seek(Duration.zero);
        _controller.value = 0;
        setState(() {
          _currentPosition = Duration.zero;
        });
      }
      await _audioPlayer.resume();
      _controller.forward();
    } else {
      await _audioPlayer.pause();
      _controller.stop();
    }
  }

  void _seekAudio(double value) async {
    final position = value * _audioDuration.inMilliseconds;
    await _audioPlayer.seek(Duration(milliseconds: position.round()));
  }

  void _startDrag() {
    setState(() {
      _isDragging = true;
    });
  }

  void _updateDrag(double dragValue) {
    setState(() {
      _dragPosition = dragValue.clamp(0.0, 1.0);
      _currentPosition = _audioDuration * _dragPosition!;
    });
  }

  void _endDrag() async {
    if (_dragPosition != null) {
      _seekAudio(_dragPosition!);
      _controller.value = _dragPosition!;
    }
    setState(() {
      _isDragging = false;
      _dragPosition = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _dragPosition ?? _controller.value;

    return GestureDetector(
      onTap: _togglePlay,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: Colors.black,
                  size: 36,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onHorizontalDragStart: (_) => _startDrag(),
                    onHorizontalDragUpdate: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(
                        details.globalPosition,
                      );
                      final dragValue = localPosition.dx / box.size.width;
                      _updateDrag(dragValue);
                    },
                    onHorizontalDragEnd: (_) => _endDrag(),
                    onTapDown: (details) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPosition = box.globalToLocal(
                        details.globalPosition,
                      );
                      final tapValue = localPosition.dx / box.size.width;
                      _startDrag();
                      _updateDrag(tapValue);
                      _endDrag();
                    },
                    child: CustomPaint(
                      painter: WaveformPainter(
                        progress: progressValue,
                        isPlaying: _isPlaying,
                      ),
                      size: const Size(double.infinity, 24),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(_formatDuration(_currentPosition)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Drag on waveform to seek',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final bool isPlaying;
  final int waveCount = 20;

  WaveformPainter({required this.progress, required this.isPlaying});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withOpacity(0.6)
          ..style = PaintingStyle.fill;

    final waveWidth = size.width / waveCount;
    final baseHeight = size.height / 2;
    final amplitude = size.height / 2;

    for (int i = 0; i < waveCount; i++) {
      final x = i * waveWidth + waveWidth / 2;
      final isActive = x < size.width * progress;

      // Animate the waves when playing
      double waveFactor = 1.0;
      if (isPlaying) {
        final time = DateTime.now().millisecondsSinceEpoch / 1000;
        waveFactor = 0.7 + 0.3 * sin(time * 8 + i * 0.5).abs();
      }

      // Height of the current wave
      final height =
          (isActive
              ? baseHeight * (0.3 + 0.7 * ((i % 3 + 1) / 3))
              : baseHeight * 0.3) *
          waveFactor;

      // Draw a rounded bar for each wave
      final rect = Rect.fromCenter(
        center: Offset(x, size.height / 2),
        width: waveWidth * 0.6,
        height: height,
      );

      final path =
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(rect, Radius.circular(waveWidth)),
            )
            ..close();

      canvas.drawPath(
        path,
        paint..color = isActive ? Colors.black : Colors.grey.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        isPlaying != oldDelegate.isPlaying;
  }
}
