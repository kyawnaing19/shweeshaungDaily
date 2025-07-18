import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shweeshaungdaily/services/api_service.dart';
import 'package:shweeshaungdaily/services/token_service.dart';
import 'package:shweeshaungdaily/utils/audio_timeformat.dart';
import 'package:shweeshaungdaily/views/audio_post/audio_player_widget.dart';
 Future<bool> _checkIfTeacher() async {
    final role = await TokenService.checkIfAdmin();
    print('role: $role');
    return role == 'true';
  }
final Map<String, String> audienceValueMap = {
  'Public': 'Public',
  'Teacher': 'Teacher',
  'Sem 1': '1',
  'Sem 2': '2',
  'Sem 3': '3',
  'Sem 4': '4',
  'Sem 5': '5',
  'Sem 6': '6',
  'Sem 7': '7',
  'Sem 8': '8',
  'Sem 9': '9',
  'Majors': 'Majors',
};
Future<void> updateAudienceMap() async {
  final isTeacher = await _checkIfTeacher(); // ⬅️ AWAIT here!

  if (!isTeacher) {
    audienceValueMap.remove('Public');
    audienceValueMap.remove('Teacher');
  }
  // Now 'audienceValueMap' is updated based on the teacher status// For demonstration
}



const List<String> majorsList = ['CST', 'CS', 'CT'];

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  State<AudioRecorderScreen> createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final TextEditingController _titleController = TextEditingController();
  final List<Animation<double>> _animations = [];
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  String? _audioPath;
  bool _isUploading = false;
  String _statusText = "Press the microphone to start recording";
  String _selectedAudience = 'Public';
  String? _selectedMajor;
  String? _selectedSemester;
  bool isLoading = true;
  List<dynamic> audioList = [];
  List<bool> cardExpanded = [];
  late AnimationController _animationController;

  String _formatTime(DateTime time) {
    // Implement your time formatting logic
    final difference = DateTime.now().difference(time);
    if (difference.inDays > 0) return "${difference.inDays}d ago";
    if (difference.inHours > 0) return "${difference.inHours}h ago";
    return "${difference.inMinutes}m ago";
  }

  @override
  void initState() {
    super.initState();
    updateAudienceMap();
    _titleController.addListener(() => setState(() {}));
    _fetchAudios();
    _checkIfTeacherList();

  }

  Future<void> _checkIfTeacherList() async {
    final role = await TokenService.checkIfAdmin();
    if(role == 'true') {
      _selectedAudience='Public';
    }else{
      _selectedAudience = 'Choose';
    }
    setState(() {
      
    });
  }

  

  void _onTitleChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _toggleCard(int index) {
    setState(() {
      for (int i = 0; i < cardExpanded.length; i++) {
        cardExpanded[i] = i == index ? !cardExpanded[i] : false;
      }
    });
  }

  Future<void> _fetchAudios() async {
    audioList = await ApiService.getAudios();
    cardExpanded = List.generate(audioList.length, (index) => false);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animations.clear();
    for (int i = 0; i < audioList.length; i++) {
      final delay = i * 300;
      final start = (delay / 1500).clamp(0.0, 1.0);
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, 1.0, curve: Curves.elasticOut),
        ),
      );

      _animations.add(animation);
    }
    setState(() {
      isLoading = false;
    });
    _animationController.forward();
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
        title: _titleController.text,
        audience:
            _selectedAudience == 'Public'
                ? 'public'
                : _selectedAudience == 'Majors' &&
                    _selectedMajor != null &&
                    _selectedSemester != null
                ? '${_selectedSemester?.replaceAll('Sem ', '') ?? ''} ${_selectedMajor ?? ''}'
                : _selectedAudience.startsWith('Sem ')
                ? '${_selectedAudience.replaceAll('Sem ', '')} CST'
                : _selectedAudience,
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
      resizeToAvoidBottomInset:
          true, // Default is true, but ensure it's not false
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 0), // Left padding for title
          child: const Text(
            'Audio Recorder',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16.0,
            ), // Right padding for actions
            child: _buildAudienceSelector(),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Column(
          children: [
            // Rest of your content
            Expanded(
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
                            // Add TextField for audio title at the top
                            TextField(
                              controller: _titleController,
                              decoration: InputDecoration(
                                labelText: 'Audio Title',
                                hintText: 'Enter your audio title',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                            ),
                            const SizedBox(
                              height: 15,
                            ), // Add spacing between TextField and status text
                            Text(
                              _statusText,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            _buildRecordButton(),
                            const SizedBox(height: 10),
                            _buildUploadButton(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20), // Space between cards
                      // New audio history card
                      Expanded(
                        child: Container(
                          // margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD3F4F3),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child:
                              isLoading
                                  ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                  : audioList.isEmpty
                                  ? const Center(child: Text('No audio found'))
                                  : ListView.separated(
                                    itemCount: audioList.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      return AnimatedBuilder(
                                        animation: _animations[index],
                                        builder: (context, child) {
                                          final animationValue =
                                              _animations[index].value.clamp(
                                                0.0,
                                                1.0,
                                              );
                                          return Transform.translate(
                                            offset: Offset(
                                              0,
                                              (1 - animationValue) * 100,
                                            ),
                                            child: Opacity(
                                              opacity: animationValue,
                                              child: Transform.scale(
                                                scale:
                                                    0.8 + 0.2 * animationValue,
                                                child: child,
                                              ),
                                            ),
                                          );
                                        },
                                        child: _buildAudioCard(
                                          index,
                                          cardExpanded[index],
                                        ),
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(int index, bool isExpanded) {
    final audio = audioList[index];
    final title = audio['title'] ?? 'No Title';
    final author = audio['teacherName'] ?? 'Unknown';
    final audioUrl = '${ApiService.base}/' + audio['fileUrl'];
    final time = audio['createdAt'] ?? '';
    return GestureDetector(
      onTap: () => _toggleCard(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          gradient:
              isExpanded
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFD3F4F3).withOpacity(0.7),
                    ],
                  )
                  : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isExpanded ? 0.15 : 0.1),
              blurRadius: isExpanded ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3A7A72),
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
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
            if (isExpanded)
              Column(
                children: [
                  const SizedBox(height: 12),
                  AudioPlayerWidget(audioUrl: audioUrl),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatFacebookStyleTime(time),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudienceSelector() {
    return GestureDetector(
      onTap: () async {
        final selected = await showDialog<String>(
          context: context,
          builder: (context) => const ShowSharesDialog(),
        );
        if (selected != null) {
          setState(() {
            if (selected.contains('::')) {
              final parts = selected.split('::');
              _selectedSemester = parts[0];
              _selectedMajor = parts[1];
              _selectedAudience = 'Majors';
            } else if (selected.startsWith('Majors-')) {
              _selectedAudience = 'Majors';
              _selectedMajor = selected.split('-')[1];
              _selectedSemester = null;
            } else {
              _selectedAudience = selected;
              _selectedMajor = null;
              _selectedSemester = null;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F7F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF48C4BC).withOpacity(0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedAudience == 'Public' ? Icons.public : Icons.people_alt,
              size: 18,
              color: const Color(0xFF317575),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedAudience == 'Majors' &&
                      _selectedMajor != null &&
                      _selectedSemester != null
                  ? '$_selectedSemester ($_selectedMajor)'
                  : _selectedAudience,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF317575),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_isRecording ? Colors.red : kShadowColor).withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton.large(
        onPressed: _onRecordButtonPressed,
        backgroundColor: _isRecording ? Colors.red[400] : kPrimaryColor,
        elevation: 0,
        child: Icon(
          _isRecording ? Icons.stop : Icons.mic,
          size: 45,
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

    final isButtonEnabled =
        _audioPath != null && _titleController.text.trim().isNotEmpty && _selectedAudience != 'Choose';

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _audioPath != null ? 1.0 : 0.0,
      curve: Curves.easeInOut,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _audioPath != null ? 1.0 : 0.8,
        curve: Curves.easeInOut,
        child: AbsorbPointer(
          absorbing: !isButtonEnabled, // Prevent tap when disabled
          child: Opacity(
            opacity: isButtonEnabled ? 1.0 : 0.4, // Visually dim when disabled
            child: Material(
              borderRadius: BorderRadius.circular(12),
              elevation: isButtonEnabled ? 2 : 0,
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isButtonEnabled ? _handleUpload : null,
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isButtonEnabled
                              ? [Colors.blue[400]!, Colors.blue[600]!]
                              : [Colors.grey[400]!, Colors.grey[500]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      if (isButtonEnabled)
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
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
          ),
        ),
      ),
    );
  }
}

class ShowSharesDialog extends StatefulWidget {
  const ShowSharesDialog({super.key});

  @override
  State<ShowSharesDialog> createState() => _ShowSharesDialogState();
}

class _ShowSharesDialogState extends State<ShowSharesDialog> {
  bool _showMajors = false;
  String? _pendingSem;
  bool? isAdmin;

  Future<void> _loadUserRole() async {
  final result = await _checkIfTeacher(); // Your async role check
  setState(() {
    isAdmin = result;
  });
}
 
Future<void> updateAudienceMap() async {
  final isTeacher = await _checkIfTeacher(); // ⬅️ AWAIT here!

  if (!isTeacher) {
    _audienceList.remove('Public');
    _audienceList.remove('Teacher');
    setState(() {
      
    });
  }
  // Now 'audienceValueMap' is updated based on the teacher status// For demonstration
}


  static final List<String> _audienceList = [
    'Public',
    'Teacher',
    'Sem 1',
    'Sem 2',
    'Sem 3',
    'Sem 4',
    'Sem 5',
    'Sem 6',
    'Sem 7',
    'Sem 8',
    'Sem 9',
  ];
  @override
  void initState() {
    super.initState();
    _loadUserRole();
    updateAudienceMap(); // Call the function to update the audience map
  }
 
  @override
  Widget build(BuildContext context) {
     var checkIf = _checkIfTeacher();

    return WillPopScope(
      onWillPop: () async {
        if (_showMajors && _pendingSem != null) {
          Navigator.pop(context, 'Public');
          return false;
        }
        return true;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDFC),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFF48C4BC).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Select Audience',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF317575),
                    ),
                  ),
                ),
              ),

              // Content
              SizedBox(
                height: 280,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Left Column (Audiences)
                      Expanded(
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbVisibility: WidgetStateProperty.all(true),
                            trackVisibility: WidgetStateProperty.all(true),
                            thumbColor: WidgetStateProperty.all(
                              const Color(0xFF48C4BC),
                            ),
                            trackColor: WidgetStateProperty.all(
                              const Color(0xFFE8F7F6),
                            ),
                            thickness: WidgetStateProperty.all(6),
                            radius: const Radius.circular(10),
                            crossAxisMargin: 2,
                          ),
                          child: Scrollbar(
                            child: ListView.separated(
                              padding: const EdgeInsets.only(right: 4),
                              itemCount: _audienceList.length,
                              separatorBuilder:
                                  (_, __) => Divider(
                                    height: 1,
                                    color: const Color(
                                      0xFF48C4BC,
                                    ).withOpacity(0.1),
                                  ),
                              itemBuilder: (context, index) {
                                final item = _audienceList[index];
                               
                                final bool isSemWithMajors;
                                if(isAdmin==true) {
                                  isSemWithMajors = index >= 4;
                                } else {
                                  isSemWithMajors = index >= 2;
                                }
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () {
                                      if (!isSemWithMajors) {
                                        Navigator.pop(context, item);
                                      } else {
                                        setState(() {
                                          _showMajors = true;
                                          _pendingSem = item;
                                        });
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            item == 'Public'
                                                ? Icons.public
                                                : Icons.school,
                                            size: 20,
                                            color: const Color(0xFF317575),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            item,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF317575),
                                            ),
                                          ),
                                          if (isSemWithMajors) ...[
                                            const Spacer(),
                                            const Icon(
                                              Icons.chevron_right,
                                              size: 20,
                                              color: Color(0xFF48C4BC),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // Vertical divider
                      Container(
                        width: 1,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: const Color(0xFF48C4BC).withOpacity(0.2),
                      ),

                      // Right Column (Majors)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child:
                              _showMajors
                                  ? ScrollbarTheme(
                                    data: ScrollbarThemeData(
                                      thumbVisibility: WidgetStateProperty.all(
                                        true,
                                      ),
                                      trackVisibility: WidgetStateProperty.all(
                                        true,
                                      ),
                                      thumbColor: WidgetStateProperty.all(
                                        const Color(0xFF48C4BC),
                                      ),
                                      trackColor: WidgetStateProperty.all(
                                        const Color(0xFFE8F7F6),
                                      ),
                                      thickness: WidgetStateProperty.all(6),
                                      radius: const Radius.circular(10),
                                      crossAxisMargin: 2,
                                    ),
                                    child: Scrollbar(
                                      child: ListView.separated(
                                        padding: const EdgeInsets.only(left: 4),
                                        itemCount: majorsList.length,
                                        separatorBuilder:
                                            (_, __) => Divider(
                                              height: 1,
                                              color: const Color(
                                                0xFF48C4BC,
                                              ).withOpacity(0.1),
                                            ),
                                        itemBuilder: (context, index) {
                                          final major = majorsList[index];
                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                if (_pendingSem != null) {
                                                  Navigator.pop(
                                                    context,
                                                    '$_pendingSem::$major',
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                      horizontal: 12,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.architecture,
                                                      size: 20,
                                                      color: Color(0xFF317575),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Text(
                                                      major,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: const Color(
                                                              0xFF317575,
                                                            ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                  : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFE8F7F6),
                                          ),
                                          child: const Icon(
                                            Icons.people_alt,
                                            size: 30,
                                            color: Color(0xFF317575),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Select a semester\nfirst to see majors',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: const Color(
                                              0xFF317575,
                                            ).withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FDFC),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: const Color(0xFF48C4BC).withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
