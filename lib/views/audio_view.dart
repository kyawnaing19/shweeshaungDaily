import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'audio_player_widget.dart';
import '../utils/audio_timeformat.dart';

class ReactorAudioPage extends StatefulWidget {
  const ReactorAudioPage({super.key});

  @override
  State<ReactorAudioPage> createState() => _ReactorAudioPageState();
}

class _ReactorAudioPageState extends State<ReactorAudioPage>
    with SingleTickerProviderStateMixin {
  List<bool> cardExpanded = [];
  late AnimationController _animationController;
  final List<Animation<double>> _animations = [];
  List<dynamic> audioList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAudios();
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
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay / 1500, 1.0, curve: Curves.elasticOut),
        ),
      );
      _animations.add(animation);
    }
    setState(() {
      isLoading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCard(int index) {
    setState(() {
      for (int i = 0; i < cardExpanded.length; i++) {
        cardExpanded[i] = i == index ? !cardExpanded[i] : false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Column(
        children: [
          // Header
          Container(
            height: 100,
            padding: const EdgeInsets.only(top: 40),
            decoration: const BoxDecoration(
              color: Color(0xFF58C2B5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 3),
                  blurRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Reactor Audio",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // List Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
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
                      ? const Center(child: CircularProgressIndicator(),)
                      : audioList.isEmpty
                      ? const Center(child: Text('No audio found'))
                      : ListView.separated(
                        itemCount: audioList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _animations[index],
                            builder: (context, child) {
                              final animationValue = _animations[index].value
                                  .clamp(0.0, 1.0);
                              return Transform.translate(
                                offset: Offset(0, (1 - animationValue) * 100),
                                child: Opacity(
                                  opacity: animationValue,
                                  child: Transform.scale(
                                    scale: 0.8 + 0.2 * animationValue,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: _buildAudioCard(index, cardExpanded[index]),
                          );
                        },
                      ),
            ),
          ),
        ],
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
}
