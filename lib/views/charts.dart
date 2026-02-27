// hbttrckr: just a habit tracker
// Copyright (C) 2026  Burak Miraç Bol
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:hbttrckr/data_types/habit.dart';

class WeekChartWidget extends StatelessWidget {
  const WeekChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left, color: Colors.white),
              onPressed: () {},
            ),
            Text('Bu Hafta', style: TextStyle(color: Colors.white)),
            IconButton(
              icon: Icon(Icons.arrow_right, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        Container(height: 100, color: Colors.white.withValues(alpha: 0.1)),
      ],
    );
  }
}

// widgets/monthly_calendar.dart
class MonthlyCalendarWidget extends StatelessWidget {
  final List<Habit> habits;
  const MonthlyCalendarWidget({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // Basit takvim
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: 35,
      itemBuilder: (context, i) => Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            '${i + 1}',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
