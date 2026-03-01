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
import '../views/mainviews/main_app_view.dart';
import 'glass_card.dart';
import 'package:hbttrckr/data_types/habit.dart';

class EachHabitGridTile extends StatelessWidget {
  final bool isFuture;
  final bool isTooLate;
  final Habit habit;
  final DateTime selectedDate;
  final OnHabitTapped onHabitTapped;
  const EachHabitGridTile({
    required this.isFuture,
    required this.isTooLate,
    required this.onHabitTapped,
    required this.habit,
    required this.selectedDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: IntrinsicWidth(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          color: habit.color.withValues(alpha: 0.2),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              spacing: 12,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: habit.color,
                      child: Icon(habit.icon),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: Column(
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(habit.description),
                        ],
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Güç: ${habit.strength.roundToDouble().toInt()}"),
                        Text("Aktif Streak: ${habit.currentStreak}"),
                        Text(habit.notesDelta?.substring(12, 24) ?? "Not yok"),
                      ],
                    ),
                  ),
                ),

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      glassContainer(
                        context: context,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: Center(
                            child: Text(
                              habit.type == HabitType.task
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
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      habit.isSkippedOnDate(selectedDate)
                          ? glassContainer(
                              child: IconButton(
                                onPressed: () {
                                  context
                                      .read<HabitProvider>()
                                      .changeSkipOnDate(
                                        habit.id,
                                        extraDate: selectedDate,
                                      );
                                },
                                icon: Icon(Icons.skip_next),
                              ),
                              context: context,
                            )
                          : isFuture || isTooLate
                          ? habit.type == HabitType.task
                                ? glassContainer(
                                    context: context,
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                      ),
                                      icon: Icon(
                                        Icons.radio_button_unchecked,
                                        size: 25,
                                      ),
                                      onPressed: () {},
                                    ),
                                  )
                                : habit.type == HabitType.count
                                ? glassContainer(
                                    context: context,
                                    child: IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                            icon: Icon(Icons.remove, size: 25),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                            icon: Icon(
                                              Icons.add_outlined,
                                              size: 25,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : habit.type == HabitType.time
                                ? glassContainer(
                                    context: context,
                                    child: IntrinsicWidth(
                                      child: Row(
                                        children: [
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                            icon: Icon(
                                              Icons.play_arrow,
                                              size: 25,
                                            ),
                                            onPressed: () {},
                                          ),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              foregroundColor: Colors.grey,
                                            ),
                                            icon: Icon(Icons.refresh, size: 25),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : glassContainer(
                                    context: context,
                                    child: IconButton(
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.grey,
                                      ),
                                      icon: Icon(
                                        Icons.radio_button_unchecked,
                                        size: 25,
                                      ),
                                      onPressed: () {},
                                    ),
                                  )
                          : habit.type == HabitType.task
                          ? glassContainer(
                              context: context,
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  foregroundColor:
                                      habit.isCompletedOnDate(selectedDate)
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
                                  context
                                      .read<HabitProvider>()
                                      .toggleTaskCompletion(habit.id);
                                },
                              ),
                            )
                          : habit.type == HabitType.count
                          ? glassContainer(
                              context: context,
                              child: IntrinsicWidth(
                                child: Row(
                                  children: [
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        foregroundColor:
                                            habit.isCompletedOnDate(
                                              selectedDate,
                                            )
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
                                        context
                                            .read<HabitProvider>()
                                            .incrementCount(habit.id);
                                      },
                                    ),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        foregroundColor:
                                            habit.isCompletedOnDate(
                                              selectedDate,
                                            )
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      icon: Icon(
                                        habit.isCompletedOnDate(selectedDate)
                                            ? Icons.remove
                                            : Icons.remove,
                                        size: 25,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<HabitProvider>()
                                            .decrementCount(habit.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : habit.type == HabitType.time
                          ? glassContainer(
                              context: context,
                              child: Consumer<HabitProvider>(
                                builder: (context, provider, child) {
                                  final bool isRunning =
                                      provider.runningTimers[habit.id] ?? false;

                                  return IntrinsicWidth(
                                    child: Row(
                                      children: [
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            foregroundColor:
                                                habit.isCompletedOnDate(
                                                  selectedDate,
                                                )
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          onPressed: () {
                                            provider.toggleTimer(
                                              habit.id,
                                              selectedDate,
                                            );
                                          },
                                          icon: Icon(
                                            isRunning &&
                                                    provider.extraDate ==
                                                        selectedDate
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 25,
                                          ),
                                        ),
                                        IconButton(
                                          style: IconButton.styleFrom(
                                            foregroundColor:
                                                habit.isCompletedOnDate(
                                                  selectedDate,
                                                )
                                                ? Colors.green
                                                : Colors.grey,
                                          ),
                                          onPressed: () {
                                            provider.resetTimer(
                                              habit.id,
                                              selectedDate,
                                            );
                                          },
                                          icon: Icon(Icons.refresh, size: 25),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            )
                          : IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:
                                    habit.isCompletedOnDate(selectedDate)
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
