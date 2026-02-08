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
import 'package:hbttrckr/classes/all_widgets.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/providers/style_provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/views/mainviews/main_app_view.dart';
import 'dart:async';

import '../extensions/duration_formatter.dart';

// TODO : calendarda task türünden yapılanları işaretliyor diğer türleri değil
// TODO : calendar habitlerin hangi günde olduğunu biliyor ama hangi günde ne kadar bittiğini bilmiyor

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

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: Text("Grid"),
                        selected: context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.grid ,
                        onSelected: (bool value) {
                          context.read<StyleProvider>().setVSFMD(ViewStyleForMultipleData.grid);
                        },
                      ),
                      FilterChip(
                        label: Text("List"),
                        selected: context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.list ,
                        onSelected: (bool value) {
                          context.read<StyleProvider>().setVSFMD(ViewStyleForMultipleData.list);
                        },
                      ),
                    ],
                  ),
                ),
              ),

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
                    child: context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.list
                        ? Column(
                            children: [
                              ...visibleHabitsByGroup.map(
                                (habit) => Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    8.0,
                                    2.0,
                                    8.0,
                                    2.0,
                                  ),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(320),
                                    ),
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
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: Text('İptal'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<HabitProvider>()
                                                      .deleteHabit(habit.id);
                                                  Navigator.pop(ctx);
                                                },
                                                child: Text(
                                                  'Sil',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
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
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        isFuture || isTooLate
                                            ? " "
                                            : habit.type == HabitType.task
                                            ? habit.isSkippedOnDate(
                                                    selectedDate,
                                                  )
                                                  ? "Atlandı"
                                                  : (habit.isCompletedOnDate(
                                                          selectedDate,
                                                        )
                                                        ? 'Tamamlandı'
                                                        : 'Yapılmadı')
                                            : habit.type == HabitType.count
                                            ? habit.isSkippedOnDate(
                                                    selectedDate,
                                                  )
                                                  ? "Atlandı"
                                                  : '${habit.getCountProgressForDate(selectedDate)} / ${habit.targetCount?.toInt() ?? '?'}'
                                            : habit.type == HabitType.time
                                            ? habit.isSkippedOnDate(
                                                    selectedDate,
                                                  )
                                                  ? "Atlandı"
                                                  : '${habit.getSecondsProgressForDate(selectedDate).formattedHMS} / ${habit.targetSeconds?.toInt().formattedHMS} '
                                            : habit.isCompletedOnDate(
                                                selectedDate,
                                              )
                                            ? 'Tamamlandı'
                                            : 'Yapılmadı',
                                      ),
                                      trailing: isFuture || isTooLate
                                          ? habit.type == HabitType.task
                                                ? IconButton(
                                                    style: IconButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey,
                                                    ),
                                                    icon: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      size: 25,
                                                    ),
                                                    onPressed: () {},
                                                  )
                                                : habit.type == HabitType.count
                                                ? IconButton(
                                                    style: IconButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey,
                                                    ),
                                                    icon: Icon(
                                                      Icons.add_outlined,
                                                      size: 25,
                                                    ),
                                                    onPressed: () {},
                                                  )
                                                : habit.type == HabitType.time
                                                ? IconButton(
                                                    style: IconButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey,
                                                    ),
                                                    icon: Icon(
                                                      Icons.play_arrow,
                                                      size: 25,
                                                    ),
                                                    onPressed: () {},
                                                  )
                                                : IconButton(
                                                    style: IconButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.grey,
                                                    ),
                                                    icon: Icon(
                                                      Icons
                                                          .radio_button_unchecked,
                                                      size: 25,
                                                    ),
                                                    onPressed: () {},
                                                  )
                                          : habit.type == HabitType.task
                                          ? IconButton(
                                              style: IconButton.styleFrom(
                                                foregroundColor:
                                                    habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              icon: Icon(
                                                habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Icons.check_circle
                                                    : Icons
                                                          .radio_button_unchecked,
                                                size: 25,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<HabitProvider>()
                                                    .toggleTaskCompletion(
                                                      habit.id,
                                                    );
                                              },
                                            )
                                          : habit.type == HabitType.count
                                          ? IconButton(
                                              style: IconButton.styleFrom(
                                                foregroundColor:
                                                    habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              icon: Icon(
                                                habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Icons.add
                                                    : Icons.add_outlined,
                                                size: 25,
                                              ),
                                              onPressed: () {
                                                context
                                                    .read<HabitProvider>()
                                                    .incrementCount(habit.id);
                                              },
                                            )
                                          : habit.type == HabitType.time
                                          ? Consumer<HabitProvider>(
                                              builder: (context, provider, child) {
                                                final bool isRunning =
                                                    provider.runningTimers[habit
                                                        .id] ??
                                                    false;

                                                return IconButton(
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
                                                );
                                              },
                                            )
                                          : IconButton(
                                              style: IconButton.styleFrom(
                                                foregroundColor:
                                                    habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Colors.green
                                                    : Colors.grey,
                                              ),
                                              icon: Icon(
                                                habit.isCompletedOnDate(
                                                      selectedDate,
                                                    )
                                                    ? Icons.check_circle
                                                    : Icons
                                                          .radio_button_unchecked,
                                                size: 25,
                                              ),
                                              onPressed: () {},
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.grid ? GridView(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 300,
                                  childAspectRatio: 1.6,
                                ),
                            children: [
                              ...visibleHabitsByGroup.map(
                                (habit) => GestureDetector(
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
                                              context
                                                  .read<HabitProvider>()
                                                  .deleteHabit(habit.id);
                                              Navigator.pop(ctx);
                                            },
                                            child: Text(
                                              'Sil',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
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
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        12,
                                                        0,
                                                        12,
                                                        0,
                                                      ),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        habit.name,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(habit.description),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(),
                                            IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  glassContainer(
                                                    context: context,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.fromLTRB(
                                                            12,
                                                            0,
                                                            12,
                                                            0,
                                                          ),
                                                      child: Center(
                                                        child: Text(
                                                          habit.type ==
                                                                  HabitType.task
                                                              ? habit.isSkippedOnDate(
                                                                      selectedDate,
                                                                    )
                                                                    ? "Atlandı"
                                                                    : (habit.isCompletedOnDate(
                                                                            selectedDate,
                                                                          )
                                                                          ? 'Tamamlandı'
                                                                          : 'Yapılmadı')
                                                              : habit.type ==
                                                                    HabitType
                                                                        .count
                                                              ? habit.isSkippedOnDate(
                                                                      selectedDate,
                                                                    )
                                                                    ? "Atlandı"
                                                                    : '${habit.getCountProgressForDate(selectedDate)} / ${habit.targetCount?.toInt() ?? '?'}'
                                                              : habit.type ==
                                                                    HabitType
                                                                        .time
                                                              ? habit.isSkippedOnDate(
                                                                      selectedDate,
                                                                    )
                                                                    ? "Atlandı"
                                                                    : '${habit.getSecondsProgressForDate(selectedDate).formattedHMS} / ${habit.targetSeconds?.toInt().formattedHMS} '
                                                              : habit.isCompletedOnDate(
                                                                  selectedDate,
                                                                )
                                                              ? 'Tamamlandı'
                                                              : 'Yapılmadı',
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                  isFuture || isTooLate
                                                      ? habit.type ==
                                                                HabitType.task
                                                            ? glassContainer(
                                                                context:
                                                                    context,
                                                                child: IconButton(
                                                                  style: IconButton.styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .radio_button_unchecked,
                                                                    size: 25,
                                                                  ),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              )
                                                            : habit.type ==
                                                                  HabitType
                                                                      .count
                                                            ? glassContainer(
                                                                context:
                                                                    context,
                                                                child: IntrinsicWidth(
                                                                  child: Row(
                                                                    children: [
                                                                      IconButton(
                                                                        style: IconButton.styleFrom(
                                                                          foregroundColor:
                                                                              Colors.grey,
                                                                        ),
                                                                        icon: Icon(
                                                                          Icons
                                                                              .remove,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                      ),
                                                                      IconButton(
                                                                        style: IconButton.styleFrom(
                                                                          foregroundColor:
                                                                              Colors.grey,
                                                                        ),
                                                                        icon: Icon(
                                                                          Icons
                                                                              .add_outlined,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : habit.type ==
                                                                  HabitType.time
                                                            ? glassContainer(
                                                                context:
                                                                    context,
                                                                child: IntrinsicWidth(
                                                                  child: Row(
                                                                    children: [
                                                                      IconButton(
                                                                        style: IconButton.styleFrom(
                                                                          foregroundColor:
                                                                              Colors.grey,
                                                                        ),
                                                                        icon: Icon(
                                                                          Icons
                                                                              .play_arrow,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                      ),
                                                                      IconButton(
                                                                        style: IconButton.styleFrom(
                                                                          foregroundColor:
                                                                              Colors.grey,
                                                                        ),
                                                                        icon: Icon(
                                                                          Icons
                                                                              .refresh,
                                                                          size:
                                                                              25,
                                                                        ),
                                                                        onPressed:
                                                                            () {},
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : glassContainer(
                                                                context:
                                                                    context,
                                                                child: IconButton(
                                                                  style: IconButton.styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                                  icon: Icon(
                                                                    Icons
                                                                        .radio_button_unchecked,
                                                                    size: 25,
                                                                  ),
                                                                  onPressed:
                                                                      () {},
                                                                ),
                                                              )
                                                      : habit.type ==
                                                            HabitType.task
                                                      ? glassContainer(
                                                          context: context,
                                                          child: IconButton(
                                                            style: IconButton.styleFrom(
                                                              foregroundColor:
                                                                  habit.isCompletedOnDate(
                                                                    selectedDate,
                                                                  )
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                            ),
                                                            icon: Icon(
                                                              habit.isCompletedOnDate(
                                                                    selectedDate,
                                                                  )
                                                                  ? Icons
                                                                        .check_circle
                                                                  : Icons
                                                                        .radio_button_unchecked,
                                                              size: 25,
                                                            ),
                                                            onPressed: () {
                                                              context
                                                                  .read<
                                                                    HabitProvider
                                                                  >()
                                                                  .toggleTaskCompletion(
                                                                    habit.id,
                                                                  );
                                                            },
                                                          ),
                                                        )
                                                      : habit.type ==
                                                            HabitType.count
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
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .grey,
                                                                  ),
                                                                  icon: Icon(
                                                                    habit.isCompletedOnDate(
                                                                          selectedDate,
                                                                        )
                                                                        ? Icons
                                                                              .add
                                                                        : Icons
                                                                              .add_outlined,
                                                                    size: 25,
                                                                  ),
                                                                  onPressed: () {
                                                                    context
                                                                        .read<
                                                                          HabitProvider
                                                                        >()
                                                                        .incrementCount(
                                                                          habit
                                                                              .id,
                                                                        );
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  style: IconButton.styleFrom(
                                                                    foregroundColor:
                                                                        habit.isCompletedOnDate(
                                                                          selectedDate,
                                                                        )
                                                                        ? Colors
                                                                              .green
                                                                        : Colors
                                                                              .grey,
                                                                  ),
                                                                  icon: Icon(
                                                                    habit.isCompletedOnDate(
                                                                          selectedDate,
                                                                        )
                                                                        ? Icons
                                                                              .remove
                                                                        : Icons
                                                                              .remove,
                                                                    size: 25,
                                                                  ),
                                                                  onPressed: () {
                                                                    context
                                                                        .read<
                                                                          HabitProvider
                                                                        >()
                                                                        .decrementCount(
                                                                          habit
                                                                              .id,
                                                                        );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : habit.type ==
                                                            HabitType.time
                                                      ? glassContainer(
                                                          context: context,
                                                          child: Consumer<HabitProvider>(
                                                            builder:
                                                                (
                                                                  context,
                                                                  provider,
                                                                  child,
                                                                ) {
                                                                  final bool
                                                                  isRunning =
                                                                      provider
                                                                          .runningTimers[habit
                                                                          .id] ??
                                                                      false;

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
                                                                            size:
                                                                                25,
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
                                                                            );
                                                                            if (isRunning) {
                                                                              provider.toggleTimer(
                                                                                habit.id,
                                                                                selectedDate,
                                                                              );
                                                                            }
                                                                          },
                                                                          icon: Icon(
                                                                            Icons.refresh,
                                                                            size:
                                                                                25,
                                                                          ),
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
                                                                habit.isCompletedOnDate(
                                                                  selectedDate,
                                                                )
                                                                ? Colors.green
                                                                : Colors.grey,
                                                          ),
                                                          icon: Icon(
                                                            habit.isCompletedOnDate(
                                                                  selectedDate,
                                                                )
                                                                ? Icons
                                                                      .check_circle
                                                                : Icons
                                                                      .radio_button_unchecked,
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
                                ),
                              ),
                            ],
                          ) : Placeholder()
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
