import 'dart:async'; // Import for Timer
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
//import 'your_upload_function.dart'; // Import your uploadAudio function

import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class VoiceMessageUI extends StatefulWidget {
  const VoiceMessageUI({super.key});

  @override
  State<VoiceMessageUI> createState() => _VoiceMessageUIState();
}

class _VoiceMessageUIState extends State<VoiceMessageUI>
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecorded = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double _recordingTime = 0.0;
  Timer? _timer; // Declare a Timer variable

  final int _maxRecordingTime = 60; // 60 seconds max

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _animationController.repeat(reverse: true);
        _startTimer();
      } else {
        _animationController.stop();
        _animationController.reverse();
        _stopTimer();
        _hasRecorded = true;
      }
    });
  }

  void _startTimer() {
    _recordingTime = 0.0;
    // Use Timer.periodic for consistent updates
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel(); // Stop the timer if recording is no longer active
        return;
      }
      setState(() {
        _recordingTime += 0.1;
        if (_recordingTime >= _maxRecordingTime) {
          _toggleRecording(); // Stop recording when max time is reached
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel(); // Cancel the timer explicitly
    // No need to reset _recordingTime here if you want to display the final time
    // If you want to reset, you can add setState(() { _recordingTime = 0.0; });
  }

  void _playAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Playing audio..."),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.deepPurple[400],
      ),
    );
  }

  void _uploadAudio() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Audio sent successfully!"),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  void _discardRecording() {
    setState(() {
      _hasRecorded = false;
      _recordingTime = 0.0; // Reset recording time on discard
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Voice Message"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (_hasRecorded)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _discardRecording,
              tooltip: 'Discard',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:
                isDarkMode
                    ? [Colors.grey.shade900, Colors.grey.shade800]
                    : [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated microphone button with wave effect
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isRecording)
                      WaveWidget(
                        config: CustomConfig(
                          colors: [
                            Colors.deepPurple.withOpacity(0.4),
                            Colors.deepPurple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.2),
                          ],
                          durations: [18000, 8000, 5000],
                          heightPercentages: [0.2, 0.4, 0.6],
                        ),
                        size: const Size(200, 200),
                        waveAmplitude: 10,
                        backgroundColor: Colors.transparent,
                      ),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors:
                                _isRecording
                                    ? [Colors.red.shade600, Colors.red.shade400]
                                    : [
                                      Colors.deepPurple.shade600,
                                      Colors.deepPurple.shade400,
                                    ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording
                                      ? Colors.red
                                      : Colors.deepPurple)
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: _toggleRecording,
                          iconSize: 36,
                          padding: const EdgeInsets.all(24),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Recording status and timer
                Column(
                  children: [
                    Text(
                      _isRecording ? "Recording..." : "Tap to record",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color:
                            _isRecording
                                ? Colors.red.shade600
                                : theme.textTheme.titleMedium?.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isRecording)
                      Text(
                        "${_recordingTime.toStringAsFixed(1)}s / ${_maxRecordingTime}s",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recording progress bar
                const SizedBox(height: 32),
                // Audio visualization placeholder
                if (_hasRecorded && !_isRecording)
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          30,
                          (index) => Container(
                            width: 4,
                            height: (index % 5 + 1) * 10.0,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade400,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                // Action buttons
                if (_hasRecorded && !_isRecording)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.play_arrow,
                        label: "Play",
                        color: Colors.green.shade600,
                        onPressed: _playAudio,
                      ),
                      const SizedBox(width: 20),
                      _buildActionButton(
                        icon: Icons.send,
                        label: "Send",
                        color: Colors.deepPurple.shade400,
                        onPressed: _uploadAudio,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
      ),
    );
  }
}
