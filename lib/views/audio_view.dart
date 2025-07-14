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
    with TickerProviderStateMixin {
  List<bool> rectorCardExpanded = [];
  List<bool> teacherCardExpanded = [];
  late AnimationController _animationController;
  final List<Animation<double>> _animations = [];
  List<dynamic> rectorAudioList = [];
  List<dynamic> teacherAudioList = [];
  bool isLoading = true;
  String? errorMessage;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10000),
    );
    _fetchAudios();
  }

  Future<void> _fetchAudios() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // TODO: Replace with correct API calls if rector and teacher audios are different
      final rector = await ApiService.getAudios();
      final teacher = await ApiService.getAudios();
      setState(() {
        rectorAudioList = rector;
        teacherAudioList = teacher;
        rectorCardExpanded = List.generate(rectorAudioList.length, (_) => false);
        teacherCardExpanded = List.generate(teacherAudioList.length, (_) => false);
        isLoading = false;
      });
      _animations.clear();
      for (int i = 0; i < rectorAudioList.length; i++) {
        final delay = i * 300;
        final start = (delay / 2500).clamp(0.0, 1.0);
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(start, 1.0, curve: Curves.elasticOut),
          ),
        );
        _animations.add(animation);
      }
      if (mounted) {
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load audios.';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleCard(int index, bool isMyTab) {
    setState(() {
      if (isMyTab) {
        rectorCardExpanded[index] = !rectorCardExpanded[index];
      } else {
        teacherCardExpanded[index] = !teacherCardExpanded[index];
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
                "University Voices",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // TabBar
          Container(
            color: const Color(0xFF58C2B5),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: "Rector's Address"),
                Tab(text: "Faculty Addresses"),
              ],
            ),
          ),
          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAudioListSection(
                  title: "Rector's Official Address",
                  list: rectorAudioList,
                  expandedList: rectorCardExpanded,
                  isMyTab: true,
                ),
                _buildAudioListSection(
                  title: 'Faculty Member Addresses',
                  list: teacherAudioList,
                  expandedList: teacherCardExpanded,
                  isMyTab: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioListSection({
    required String title,
    required List<dynamic> list,
    required List<bool> expandedList,
    required bool isMyTab,
  }) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (list.isEmpty) {
      return const Center(child: Text('No audio found'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: _sectionBoxDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildAudioCard(
                  index,
                  expandedList[index],
                  list,
                  isMyTab,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCard(
    int index,
    bool isExpanded,
    List<dynamic> list,
    bool isMyTab,
  ) {
    final audio = list[index];
    final title = audio['title'] ?? 'No Title';
    final author = audio['teacherName'] ?? 'Unknown';
    final audioUrl = '${ApiService.base}/' + audio['fileUrl'];
    final time = audio['createdAt'] ?? '';

    return GestureDetector(
      onTap: () => _toggleCard(index, isMyTab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
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
            // Title + author + arrow
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title/author
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
            // Time or AudioPlayer
            isExpanded
                ? Column(
                  children: [
                    const SizedBox(height: 12),
                    AudioPlayerWidget(audioUrl: audioUrl),
                  ],
                )
                : Align(
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

  BoxDecoration _sectionBoxDecoration() {
    return BoxDecoration(
      color: const Color(0xFFD3F4F3),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
