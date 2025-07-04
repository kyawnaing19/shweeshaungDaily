import 'package:flutter/material.dart';
import 'package:shweeshaungdaily/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TimeTablePage extends StatefulWidget {
  final EdgeInsetsGeometry timelinePadding;

  const TimeTablePage({
    super.key,
    this.timelinePadding = const EdgeInsets.all(17),
  });

  @override
  State<TimeTablePage> createState() => _TimeTablePageState();
}

class _TimeTablePageState extends State<TimeTablePage> {
  final List<String> days = const ['Mon', 'Tue', 'Wed', 'Thrs', 'Fri'];
  int selectedDay = 0;

  final Map<int, String> periodTimes = {
    1: '08:30 - 09:30',
    2: '09:30 - 10:30',
    3: '10:30 - 11:30',
    4: '12:30 - 1:30',
    5: '1:30 - 2:30',
    6: '2:30 - 03:30',
  };

  Map<String, Map<int, dynamic>> timetableData = {};

  @override
  void initState() {
    super.initState();
    loadTimetableData();
  }

  Future<void> loadTimetableData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('timetableData');
    if (jsonString != null) {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      setState(() {
        timetableData = jsonMap.map(
          (day, periods) => MapEntry(
            day,
            (periods as Map).map(
              (periodStr, value) => MapEntry(int.parse(periodStr), value),
            ),
          ),
        );
        print('timetableData loaded: $timetableData');
      });
    }
  }

  Widget buildClassCard(dynamic periodData) {
    if (periodData == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No Class', style: TextStyle(color: kPrimaryDarkColor)),
        ),
      );
    }
    return Card(
      elevation: 4,
      shadowColor: kShadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              periodData['subjectName'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: kPrimaryDarkColor,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              periodData['subjectCode'] ?? '',
              style: const TextStyle(color: kPrimaryDarkColor),
            ),
            Text(
              periodData['teacherName'] ?? '',
              style: const TextStyle(color: kPrimaryDarkColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimelineItem(int period, dynamic periodData) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryDarkColor,
              ),
            ),
            Container(width: 4, height: 100, color: kPrimaryDarkColor),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                periodTimes[period] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              buildClassCard(periodData),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final selectedDayName = dayNames[selectedDay];
    final periods = timetableData[selectedDayName] ?? {};
    final periodNumbers = [1, 2, 3, 4, 5, 6];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAccentColor,
        elevation: 4,
        leading: const Padding(
          padding: EdgeInsets.all(12.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.teal),
          ),
        ),
        title: const Text(
          'Time Table',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(days.length, (index) {
              final isSelected = selectedDay == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDay = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryDarkColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : kPrimaryDarkColor,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: widget.timelinePadding,
              decoration: BoxDecoration(
                color: kAccentColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView(
                children: periodNumbers.map((period) {
                  final periodData = periods[period]; // ✅ fixed line
                  return buildTimelineItem(period, periodData);
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kAccentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Icon(Icons.home, color: Colors.white),
                Icon(Icons.list, color: Colors.white),
                Icon(Icons.check_box, color: Colors.white),
                Icon(Icons.person, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
