import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:fl_chart/fl_chart.dart';

class WeekChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dummy data
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: Icon(Icons.arrow_left, color: Colors.white), onPressed: () {}),
            Text('Bu Hafta', style: TextStyle(color: Colors.white)),
            IconButton(icon: Icon(Icons.arrow_right, color: Colors.white), onPressed: () {}),
          ],
        ),
        Container(height: 100, color: Colors.white.withOpacity(0.1)),
      ],
    );
  }
}

// widgets/monthly_calendar.dart
class MonthlyCalendarWidget extends StatelessWidget {
  final List<Habit> habits;
  const MonthlyCalendarWidget({required this.habits});

  @override
  Widget build(BuildContext context) {
    // Basit takvim
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: 35,
      itemBuilder: (context, i) => Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text('${i + 1}', style: TextStyle(color: Colors.white70, fontSize: 12))),
      ),
    );
  }
}
