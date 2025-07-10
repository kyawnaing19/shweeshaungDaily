import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shweeshaungdaily/utils/route_transition.dart';
import 'package:shweeshaungdaily/views/Home.dart';

// List of story privacy/status options for backend integration
final List<String> storyStatusOptions = [
  'Public',
  'Sem 1',
  'Sem 2',
  'Sem 3',
  'Sem 4',
  'Sem 5',
  'Sem 6',
  'Sem 7',
  'Sem 8',
];

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF57C5BE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!(); // ✅ Access via `widget`
            }
          },
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    final RenderBox overlay =
                        Overlay.of(context).context.findRenderObject()
                            as RenderBox;
                    final Offset topRight = overlay.localToGlobal(
                      Offset(overlay.size.width, 0),
                    );
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        topRight.dx - 200, // 200 = width of SettingsCard
                        topRight.dy + kToolbarHeight + 8, // below appbar
                        16, // right margin
                        0,
                      ),
                      items: [
                        PopupMenuItem(
                          enabled: false,
                          padding: EdgeInsets.zero,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: SettingsCard(),
                          ),
                        ),
                      ],
                      elevation: 8,
                      color: Colors.transparent,
                    );
                  },
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF317575),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF317575),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mg Pyae Phyo Aung',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '( Kyote Gyi )',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          'I like playing efootball mobile game',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Stories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                  color: Color(0xFF317575),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio:
                      0.63, // Adjust this value for width/height ratio
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const UploadStoryDialog(),
                        );
                      },
                      child: SizedBox(
                        width: 100, // Set your desired width
                        height: 120, // Set your desired height
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9D4D4),
                            borderRadius: BorderRadius.circular(
                              5,
                            ), // Customizable borderRadius
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.add,
                              size: 30,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox(
                      width: 100, // Set your desired width
                      height: 120, // Set your desired height
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF48C4BC),
                          borderRadius: BorderRadius.circular(
                            5,
                          ), // Customizable borderRadius
                        ),
                        child: Stack(
                          children: const [
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Icon(
                                Icons.play_arrow,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 20,
                              child: Text(
                                '1:30',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: _onItemTapped,
      // ),
    );
  }
}

class UploadStoryDialog extends StatelessWidget {
  const UploadStoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85, // 85% of screen width
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // 👈 Rounded corners
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Your Story',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF317575),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Share your moment with the world.',
              style: TextStyle(color: Color(0xFF317575)),
            ),
            const SizedBox(height: 20),
            DottedBorder(
              borderType: BorderType.RRect,
              radius: Radius.circular(12),
              dashPattern: [6, 3],
              color: Color(0xFF317575),
              child: Container(
                height: 120,
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 60, color: Color(0xFF317575)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF317575),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        // TODO: Implement image picker
                        print("Select Photo button pressed");
                      },
                      child: Text(
                        "Select Photo",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ShowStoryDialog(),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundColor: Color(0xFF48C4BC),
                    child: Icon(
                      Icons.lock_person_rounded,
                      size: 25,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Add a caption ....",
                      hintStyle: TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Color(0xFF48C4BC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFFD4F7F5),
                    side: BorderSide(color: Colors.teal),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFF317575)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF317575),
                  ),
                  onPressed: () {
                    // TODO: Handle upload logic
                    print("Your story has been uploaded!");
                    Navigator.pop(context);
                  },
                  child: Text("Upload", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShowStoryDialog extends StatelessWidget {
  const ShowStoryDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * 0.3,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Story Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF317575),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 230, // Customize this height as needed
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(
                    Color(0xFF317575),
                  ), // Your custom color
                  trackColor: WidgetStateProperty.all(Color(0xFFD4F7F5)),
                  thickness: WidgetStateProperty.all(6),
                  radius: Radius.circular(10),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  interactive: true,
                  child: ListView(
                    shrinkWrap: true,
                    children:
                        storyStatusOptions
                            .map(
                              (status) => ListTile(
                                title: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Color(0xFF317575),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, status);
                                },
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _SettingsItem(
            icon: Icons.headset_mic_outlined,
            text: 'Customer Support',
          ),
          SizedBox(height: 12),
          _SettingsItem(
            icon: Icons.power_settings_new_rounded,
            text: 'Log out',
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SettingsItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF317575),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF317575),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
