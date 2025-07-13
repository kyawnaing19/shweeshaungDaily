import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:shweeshaungdaily/services/api_service.dart';

// --- IMPORTANT ---
// This widget assumes you have the following classes and functions defined elsewhere in your project:
//
// 1. An `ApiService` class with the static `uploadAudio` function you provided.
//    e.g.,
//    class ApiService {
//      static Future<void> uploadAudio({required XFile? voice}) async {
//        // ... your upload implementation
//      }
//      // ... other methods like refreshAccessToken
//    }
//
// 2. A `TokenService` class to handle authentication tokens.
//    e.g.,
//    class TokenService {
//      static Future<Map<String, String>?> loadTokens() async { /* ... */ }
//      // ... other methods
//    }
// -----------------


/// A StatefulWidget that provides a UI for recording and uploading audio.
/// It is self-contained and handles recording logic for both mobile and web.
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

        await _audioRecorder.start(const RecordConfig(encoder: encoder), path: path);

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
        audioFile = XFile.fromData(bytes, name: 'voice_recording.webm', mimeType: 'audio/webm');
      } else {
        // For mobile, we can create the XFile directly from the path.
        audioFile = XFile(_audioPath!);
      }

      setState(() {
        _statusText = "Uploading...";
      });

      // Call the static upload function from your ApiService.
      // Ensure ApiService and its methods are defined in your project.
      await ApiService.uploadAudio(voice: audioFile);

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
        title: const Text('Audio Recorder & Uploader'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _statusText,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildRecordButton(),
              const SizedBox(height: 20),
              _buildUploadButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return FloatingActionButton.large(
      onPressed: _onRecordButtonPressed,
      tooltip: 'Record',
      child: Icon(
        _isRecording ? Icons.stop : Icons.mic,
        size: 50,
      ),
    );
  }

  Widget _buildUploadButton() {
    if (_isUploading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("Uploading..."),
        ],
      );
    }

    return ElevatedButton.icon(
      onPressed: _audioPath != null ? _handleUpload : null,
      icon: const Icon(Icons.cloud_upload),
      label: const Text('Upload Audio'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        textStyle: const TextStyle(fontSize: 16),
      ),
    );
  }
}

