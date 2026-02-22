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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/each_habit_grid_tile.dart';
import 'package:hbttrckr/classes/each_habit_tile.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/classes/habit.dart';
import '../extensions/duration_formatter.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hbttrckr/providers/style_provider.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/views/mainviews/main_app_view.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

Widget buildHabitsPage({
  required List<Habit> habits,
  required OnHabitTapped onHabitTapped, // tıklama
  required OnHabitUpdated onHabitUpdated,
  required OnHabitDeleted? onHabitDeleted,
  required Function(DateTime) onDateSelected,
}) {
  return Consumer<HabitProvider>(
    builder: (context, provider, child) {
      if (provider.habits.isEmpty) {
        return Center(
          child: Text(
            'Henüz alışkanlık eklemedin.\n+ butonuna bas!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
      }

      return LiquidGlassLayer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Calender (week style but we wanna add to change to month or so if yo want)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay:
                        Provider.of<HabitProvider>(context).selectedDate ??
                        DateTime.now(),
                    // provider’daki tarih
                    selectedDayPredicate: (day) => isSameDay(
                      Provider.of<HabitProvider>(context).selectedDate,
                      day,
                    ),
                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    headerVisible: false,
                    daysOfWeekHeight: 40,
                    rowHeight: 66,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(),
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.pinkAccent.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final habitProvider = Provider.of<HabitProvider>(
                          context,
                        );
                        final normalizedDate = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );

                        // Tamamlanan habitler
                        final completedHabits = provider.habits.where((habit) {
                          final createdDate = DateTime(
                            habit.createdAt.year,
                            habit.createdAt.month,
                            habit.createdAt.day,
                          );
                          return !createdDate.isAfter(normalizedDate) &&
                              habit.isCompletedOnDate(normalizedDate);
                        }).toList();

                        if (completedHabits.isNotEmpty) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  completedHabits.take(4).length,
                                  (index) {
                                    final habit = completedHabits[index];
                                    final mixedColor = habitProvider
                                        .getMixedColor(habit.id);
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 1.5,
                                      ),
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: mixedColor.withValues(
                                          alpha: 0.8,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),

                    onDaySelected: (selectedDay, focusedDay) {
                      context.read<HabitProvider>().setSelectedDate(
                        selectedDay,
                      );
                      debugPrint("Tıklanan gün: $selectedDay");
                    },

                    onPageChanged: (focusedDay) {
                      context.read<HabitProvider>().setSelectedDate(focusedDay);
                      debugPrint("Kaydırılan gün: $focusedDay");
                    },
                  ),
                ),
              ),

              // Grup filter chipleri
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children:
                        context
                            .read<HabitProvider>()
                            .getUniqueGroupNames(
                              context.read<HabitProvider>().habits,
                            )
                            .isEmpty
                        ? []
                        : [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: FilterChip(
                                label: const Text("Hepsi"),
                                selected:
                                    context
                                        .watch<HabitProvider>()
                                        .selectedGroup ==
                                    null,
                                onSelected: (bool selected) {
                                  context.read<HabitProvider>().setGroupToView(
                                    null,
                                  );
                                },
                              ),
                            ),

                            ...context
                                .read<HabitProvider>()
                                .getUniqueGroupNames(
                                  context.read<HabitProvider>().habits,
                                )
                                .map((groupName) {
                                  return FilterChip(
                                    label: Text(groupName),
                                    selected:
                                        context
                                            .watch<HabitProvider>()
                                            .getGroupToView() ==
                                        groupName,
                                    onSelected: (bool selected) {
                                      if (selected) {
                                        context
                                            .read<HabitProvider>()
                                            .setGroupToView(groupName);
                                      } else {
                                        context
                                            .read<HabitProvider>()
                                            .setGroupToView(null);
                                      }
                                    },
                                  );
                                }),
                          ],
                  ),
                ),
              ),

              // Habitler
              Consumer<HabitProvider>(
                builder: (context, provider, child) {
                  final selectedDate = provider.selectedDate ?? DateTime.now();
                  final normalizedDate = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                  );

                  final dateFilteredHabits = provider.habits.where((habit) {
                    final createdDate = DateTime(
                      habit.createdAt.year,
                      habit.createdAt.month,
                      habit.createdAt.day,
                    );
                    return !createdDate.isAfter(normalizedDate);
                  }).toList();

                  final currentGroup = provider.getGroupToView();
                  final uniqueGroups = provider.getUniqueGroupNames(
                    provider.habits,
                  );
                  final bool isGroupInvalid =
                      currentGroup != null &&
                      !uniqueGroups.any((h) => h == currentGroup);

                  if (isGroupInvalid) {
                    Future.microtask(() {
                      FocusScope.of(context).unfocus();
                      provider.setGroupToView(null);
                    });
                  }

                  final List<Habit> visibleHabitsByGroup =
                      (currentGroup == null || isGroupInvalid)
                      ? dateFilteredHabits
                      : dateFilteredHabits
                            .where((h) => h.group == currentGroup)
                            .toList();

                  final today = DateTime.now();
                  final todayNormalized = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  final isFuture = normalizedDate.isAfter(todayNormalized);
                  DateTime sevenDaysAgo = todayNormalized.subtract(
                    const Duration(days: 7),
                  );
                  bool isTooLate = selectedDate.isBefore(sevenDaysAgo);

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        context.watch<StyleProvider>().getVSFMD() ==
                            ViewStyleForMultipleData.list
                        ? Column(
                            children: [
                              ...visibleHabitsByGroup.map(
                                (habit) => EachHabitTile(
                                  isFuture: isFuture,
                                  isTooLate: isTooLate,
                                  selectedDate: selectedDate,
                                  onHabitTapped: onHabitTapped,
                                  habit: habit,
                                ),
                              ),
                            ],
                          )
                        : context.watch<StyleProvider>().getVSFMD() ==
                              ViewStyleForMultipleData.grid
                        ? MasonryGridView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 600,
                                ),
                            children: [
                              ...visibleHabitsByGroup.map(
                                (habit) => EachHabitGridTile(
                                  isFuture: isFuture,
                                  isTooLate: isTooLate,
                                  onHabitTapped: onHabitTapped,
                                  habit: habit,
                                  selectedDate: selectedDate,
                                ),
                              ),
                            ],
                          )
                        : Placeholder(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
