import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/views/audio_player_widget.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  bool _isUploading = false;
  String _statusText = "Press the microphone to start recording";

  String _formatTime(DateTime time) {
    // Implement your time formatting logic
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return "${difference.inDays}d ago";
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    return "${difference.inMinutes}m ago";
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Starts the audio recording process.
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        const encoder = kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc;
        final path = await _getRecordingPath();

        await _audioRecorder.start(
          const RecordConfig(encoder: encoder),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _statusText = "Recording...";
        });
      } else {
        setState(() {
          _statusText = "Permission to record audio denied.";
        });
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _statusText = "Failed to start recording.";
      });
    }
  }

  /// Stops the audio recording process and saves the file path.
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _audioPath = path;
        _statusText = "Recording stopped. Ready to upload.";
      });
      print("Recording stopped, file saved at: $path");
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _statusText = "Failed to stop recording.";
      });
    }
  }

  /// Determines the appropriate path for the recording based on the platform.
  Future<String> _getRecordingPath() async {
    if (kIsWeb) {
      return '';
    }
    final dir = await getTemporaryDirectory();
    return '${dir.path}/myFile.m4a';
  }

  /// Toggles the recording state.
  void _onRecordButtonPressed() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  /// Handles the entire upload process by calling the static ApiService method.
  Future<void> _handleUpload() async {
    if (_audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record an audio first!')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _statusText = "Preparing to upload...";
    });

    try {
      // Create an XFile object from the recording path/URL.
      XFile audioFile;
      if (kIsWeb) {
        // For web, the path is a blob URL. We fetch the bytes to create the file.
        final response = await http.get(Uri.parse(_audioPath!));
        final bytes = response.bodyBytes;
        audioFile = XFile.fromData(
          bytes,
          name: 'voice_recording.webm',
          mimeType: 'audio/webm',
        );
      } else {
        // For mobile, we can create the XFile directly from the path.
        audioFile = XFile(_audioPath!);
      }

      setState(() {
        _statusText = "Uploading...";
      });

      // Call the static upload function from your ApiService.
      // Ensure ApiService and its methods are defined in your project.
      await ApiService.uploadAudio(
        voice: audioFile,
        title: 'audiotitle',
        audience: 'public',
      );

      // Handle success
      setState(() {
        _statusText = "Upload successful!";
        _audioPath = null; // Clear path after successful upload
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audio uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Handle errors
      print("Upload failed: $e");
      setState(() {
        _statusText = "Upload failed: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset the uploading state regardless of outcome.
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio Recorder',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Your existing recording card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      _buildRecordButton(),
                      const SizedBox(height: 30),
                      _buildUploadButton(),
                    ],
                  ),
                ),

                const SizedBox(height: 24), // Space between cards
                // New audio history card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Audio History",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7A72),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Loop through 5 audio history items
                      ...List.generate(
                        5,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAudioHistoryItem(
                            title: "Recording ${index + 1}",
                            author: "User",
                            time: DateTime.now().subtract(
                              Duration(hours: index),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Helper method to build history item
    );
  }

  Widget _buildAudioHistoryItem({
    required String title,
    required String author,
    required DateTime time,
  }) {
    bool isExpanded = true; // You'll need to manage this state properly

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A7A72),
                  ),
                ),
                Text(
                  "By $author",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF3A7A72),
                  ),
                ),
              ],
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF3A7A72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // if (isExpanded)
        //   Column(
        //     children: [
        //       const SizedBox(height: 12),
        //       AudioPlayerWidget(audioUrl: "your_audio_url_here"),
        //     ],
        //   )
        // else
        //   Align(
        //     alignment: Alignment.centerRight,
        //     child: Text(
        //       _formatTime(time), // Implement your time formatting
        //       style: TextStyle(
        //         color: Colors.grey[600],
        //         fontWeight: FontWeight.bold,
        //         fontSize: 11,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildRecordButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_isRecording ? Colors.red[400]! : Colors.blue[400]!)
                .withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.large(
        onPressed: _onRecordButtonPressed,
        backgroundColor: _isRecording ? Colors.red[400] : Colors.blue[400],
        elevation: 0,
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 36,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    if (_isUploading) {
      return Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Uploading...",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ],
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _audioPath != null ? null : 0,
      height: _audioPath != null ? null : 0,
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _audioPath != null ? _handleUpload : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_upload, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Upload Audio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
