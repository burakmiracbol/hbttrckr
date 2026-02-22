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
import 'package:provider/provider.dart';
import '../extensions/duration_formatter.dart';
import '../providers/habit_provider.dart';
import 'habit.dart';

class EachHabitTile extends StatelessWidget {
  final bool isTooLate;
  final bool isFuture;
  final Function(Habit) onHabitTapped;
  final DateTime selectedDate;
  final Habit habit;
  const EachHabitTile({
    required this.isFuture,
    required this.isTooLate,
    required this.selectedDate,
    required this.onHabitTapped,
    required this.habit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 2.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(320)),
        color: habit.color.withValues(alpha: 0.2),
        child: ListTile(
          onTap: () => onHabitTapped(habit),

          onLongPress: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Silinsin mi?'),
                content: Text(
                  '${habit.name} alışkanlığını silmek istediğinden emin misin?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('İptal'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<HabitProvider>().deleteHabit(habit.id);
                      Navigator.pop(ctx);
                    },
                    child: Text('Sil', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: habit.color,
            child: Icon(habit.icon),
          ),
          title: Text(
            habit.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isFuture || isTooLate
                ? " "
                : habit.type == HabitType.task
                ? habit.isSkippedOnDate(selectedDate)
                      ? "Atlandı"
                      : (habit.isCompletedOnDate(selectedDate)
                            ? 'Tamamlandı'
                            : 'Yapılmadı')
                : habit.type == HabitType.count
                ? habit.isSkippedOnDate(selectedDate)
                      ? "Atlandı"
                      : '${habit.getCountProgressForDate(selectedDate)} / ${habit.targetCount?.toInt() ?? '?'}'
                : habit.type == HabitType.time
                ? habit.isSkippedOnDate(selectedDate)
                      ? "Atlandı"
                      : '${habit.getSecondsProgressForDate(selectedDate).formattedHMS} / ${habit.targetSeconds?.toInt().formattedHMS} '
                : habit.isCompletedOnDate(selectedDate)
                ? 'Tamamlandı'
                : 'Yapılmadı',
          ),
          trailing: isFuture || isTooLate
              ? habit.type == HabitType.task
                    ? IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        icon: Icon(Icons.radio_button_unchecked, size: 25),
                        onPressed: () {},
                      )
                    : habit.type == HabitType.count
                    ? IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        icon: Icon(Icons.add_outlined, size: 25),
                        onPressed: () {},
                      )
                    : habit.type == HabitType.time
                    ? IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        icon: Icon(Icons.play_arrow, size: 25),
                        onPressed: () {},
                      )
                    : IconButton(
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                        icon: Icon(Icons.radio_button_unchecked, size: 25),
                        onPressed: () {},
                      )
              : habit.type == HabitType.task
              ? IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: habit.isCompletedOnDate(selectedDate)
                        ? Colors.green
                        : Colors.grey,
                  ),
                  icon: Icon(
                    habit.isCompletedOnDate(selectedDate)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 25,
                  ),
                  onPressed: () {
                    context.read<HabitProvider>().toggleTaskCompletion(
                      habit.id,
                    );
                  },
                )
              : habit.type == HabitType.count
              ? IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: habit.isCompletedOnDate(selectedDate)
                        ? Colors.green
                        : Colors.grey,
                  ),
                  icon: Icon(
                    habit.isCompletedOnDate(selectedDate)
                        ? Icons.add
                        : Icons.add_outlined,
                    size: 25,
                  ),
                  onPressed: () {
                    context.read<HabitProvider>().incrementCount(habit.id);
                  },
                )
              : habit.type == HabitType.time
              ? Consumer<HabitProvider>(
                  builder: (context, provider, child) {
                    final bool isRunning =
                        provider.runningTimers[habit.id] ?? false;

                    return IconButton(
                      style: IconButton.styleFrom(
                        foregroundColor: habit.isCompletedOnDate(selectedDate)
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onPressed: () {
                        provider.toggleTimer(habit.id, selectedDate);
                      },
                      icon: Icon(
                        isRunning && provider.extraDate == selectedDate
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 25,
                      ),
                    );
                  },
                )
              : IconButton(
                  style: IconButton.styleFrom(
                    foregroundColor: habit.isCompletedOnDate(selectedDate)
                        ? Colors.green
                        : Colors.grey,
                  ),
                  icon: Icon(
                    habit.isCompletedOnDate(selectedDate)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 25,
                  ),
                  onPressed: () {},
                ),
        ),
      ),
    );
  }
}
