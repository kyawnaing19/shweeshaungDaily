import 'package:flutter/material.dart';


class UserProfileView extends StatefulWidget {
    final VoidCallback? onBack;

  const UserProfileView({super.key,  this.onBack});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  List<String> imageAssets = [
    'assets/images/tpo.jpg',
    'assets/images/tpo.jpg',
    'assets/images/tpo.jpg',
    'assets/images/tpo.jpg',
    'assets/images/tpo.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFE0F7FA),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FullscreenImageView(),
                    ),
                  );
                },
                child: const Hero(
                  tag: 'profileImageHero',
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Color(0xFF00897B),
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: AssetImage('assets/images/tpo.jpg'),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),
              // User Name and Nickname
              const Text(
                'Efootball King of UCSTT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '@pyaephyoaung',
                style: TextStyle(fontSize: 16, color: Color(0xFF00897B)),
              ),
              const SizedBox(height: 18),
              // User Info Card for Mail and Bio
              _buildInfoCard(),
              const SizedBox(height: 18),
              // Album Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Album',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // Photo Album Grid
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // The grid shouldn't scroll itself
                itemCount: 5,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.8,
                ),
                itemBuilder:
                    (context, index) => _buildPhotoCard(index, context),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // A helper widget to build the info card for email and bio.
  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF48C4BC),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.email_outlined, 'pyaephyoaung@ucstt.edu.mm'),
            const Divider(height: 32, color: Colors.white, thickness: 1),
            const Text(
              'Bio',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'I like playing football, games. Also like listening music.',
              style: TextStyle(fontSize: 14, color: Colors.white, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // A helper widget for a row of information (icon + text).
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // A helper widget to build each photo card in the album.
  Widget _buildPhotoCard(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 400),
            pageBuilder:
                (_, __, ___) =>
                    GalleryViewerPage(images: imageAssets, initialIndex: index),
          ),
        );
      },
      child: Hero(
        tag: 'galleryImage_$index',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            image: DecorationImage(
              image: AssetImage(imageAssets[index]),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Full Screen Image View
class FullscreenImageView extends StatefulWidget {
  const FullscreenImageView({super.key});

  @override
  State<FullscreenImageView> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageView>
    with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += Offset(0, details.delta.dy);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_offset.dy > 100) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _offset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        1 - (_offset.dy / 300).clamp(0, 1),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Center(
              child: Transform.translate(
                offset: _offset,
                child: Hero(
                  tag: 'profileImageHero',
                  child: Image.asset(
                    'assets/images/tpo.jpg',
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GalleryViewerPage({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<GalleryViewerPage> createState() => _GalleryViewerPageState();
}

class _GalleryViewerPageState extends State<GalleryViewerPage> {
  late PageController _pageController;
  int currentIndex = 0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += Offset(0, details.delta.dy);
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_offset.dy.abs() > 100) {
      Navigator.pop(context);
    } else {
      setState(() {
        _offset = Offset.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(
        1 - (_offset.dy / 300).clamp(0, 1),
      ),
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => currentIndex = index),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Transform.translate(
                    offset: index == currentIndex ? _offset : Offset.zero,
                    child: Hero(
                      tag: 'galleryImage_$index',
                      child: Image.asset(
                        widget.images[index],
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
