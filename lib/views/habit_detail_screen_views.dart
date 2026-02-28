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
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../actions/detail_screen/notes_editor_sheet.dart';
import '../actions/detail_screen/settings_sheet.dart';
import '../classes/actions_for_habit.dart';
import '../classes/liquid_wrapper.dart';
import '../classes/rate_of_doing.dart';
import '../classes/stats_card.dart';
import '../classes/strength_gauge.dart';
import '../data_types/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/style_provider.dart';
import 'mainviews/main_app_view.dart';

class HabitDetailScreenFullscreen extends StatelessWidget {
  final bool isLiquid;
  final bool isFakeLiquid;
  final String habitId;
  final DateTime selectedDate;
  final String howManyDaysBeforeCreated;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;
  final Habit currentHabit;

  const HabitDetailScreenFullscreen({
    required this.isLiquid,
    required this.isFakeLiquid,
    required this.habitId,
    required this.selectedDate,
    required this.currentHabit,
    required this.howManyDaysBeforeCreated,
    required this.onHabitUpdated,
    required this.onHabitDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      child: GlassGlowLayer(
        child: Container(
          color: currentHabit.color.withValues(alpha: 0.2),
          child: Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: CardLiquidWrapper(
                      statement2: isFakeLiquid,
                      borderRadius: 160,
                      statement: isLiquid,
                      shape: LiquidOval(),
                      child: IconButton(
                        icon: Icon(Icons.fullscreen_exit),
                        onPressed: () {
                          context.read<StyleProvider>().setFulscreenForNow(
                            false,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CardLiquidWrapper(
                          statement2: isFakeLiquid,
                          borderRadius: 160,
                          statement: isLiquid,
                          shape: LiquidOval(),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: currentHabit.color.withValues(
                              alpha: 0.3,
                            ),
                            child: Icon(
                              currentHabit.icon,
                              size: 50,
                              color: currentHabit.color,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Stack(
                      children: [
                        Center(
                          child: Card(
                            color: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IntrinsicHeight(
                              child: IntrinsicWidth(
                                child: CardLiquidWrapper(
                                  statement2: isFakeLiquid,
                                  borderRadius: 320,
                                  statement: isLiquid,
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 320,
                                  ),
                                  child: Card(
                                    color: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(160),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            2,
                                            4,
                                            2,
                                          ),
                                          child: LiquidWrapper(
                                            statement: isLiquid,
                                            shape: LiquidOval(),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.note_alt_outlined,
                                              ),
                                              onPressed: () async {
                                                final provider = context
                                                    .read<HabitProvider>();
                                                final current = provider
                                                    .getHabitById(
                                                      currentHabit.id,
                                                    );
                                                final result =
                                                    await showNotesEditorSheet(
                                                      context,
                                                      current,
                                                    );

                                                if (result != null) {
                                                  final updated = current
                                                      .copyWith(
                                                        notesDelta: result,
                                                      );
                                                  provider.updateHabit(updated);
                                                  onHabitUpdated.call(updated);
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            26,
                                            0,
                                            26,
                                            0,
                                          ),
                                          child: Text(
                                            currentHabit.name,
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            2,
                                            4,
                                            2,
                                          ),
                                          child: LiquidWrapper(
                                            statement: isLiquid,
                                            shape: LiquidOval(),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons
                                                    .format_list_bulleted_rounded,
                                              ),
                                              onPressed: () {
                                                detailSettingsSheet(
                                                  context,
                                                  currentHabit,
                                                  selectedDate ??
                                                      DateTime.now(),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: CardLiquidWrapper(
                              statement2: isFakeLiquid,
                              borderRadius: 160,
                              statement: isLiquid,
                              shape: LiquidRoundedRectangle(borderRadius: 160),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 18.0,
                                    right: 18.0,
                                    bottom: 4.0,
                                  ),
                                  child: Text(
                                    currentHabit.name,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: CardLiquidWrapper(
                        borderRadius: 320,
                        statement2: isFakeLiquid,
                        statement: isLiquid,
                        shape: LiquidRoundedRectangle(borderRadius: 320),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                          child: Column(
                            spacing: 8,
                            children: [
                              LiquidWrapper(
                                statement: isLiquid,
                                shape: LiquidRoundedRectangle(borderRadius: 16),
                                child: Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Text(
                                    currentHabit.description,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 18,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              LiquidWrapper(
                                statement: isLiquid,
                                shape: LiquidRoundedRectangle(borderRadius: 16),
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                  ),
                                  child: Text(
                                    'Toplam $howManyDaysBeforeCreated gün önce oluşturuldu',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ActionsForHabit(
                      isFakeLiquidBackground: isFakeLiquid,
                      isLiquidBackground: isLiquid,
                      selectedDate: selectedDate ?? DateTime.now(),
                      habitId: currentHabit.id,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HabitDetailScreenNormal extends StatelessWidget {
  final bool isLiquid;
  final bool isFakeLiquid;
  final String habitId;
  final DateTime selectedDate;
  final String howManyDaysBeforeCreated;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;
  final Habit currentHabit;

  const HabitDetailScreenNormal({
    required this.isLiquid,
    required this.isFakeLiquid,
    required this.habitId,
    required this.selectedDate,
    required this.currentHabit,
    required this.howManyDaysBeforeCreated,
    required this.onHabitUpdated,
    required this.onHabitDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GlassGlowLayer(
        child: LiquidGlassLayer(
          child: Stack(
            children: [
              Positioned(
                top:
                    MediaQuery.of(context).size.width *
                    -0.5, // üstten ne kadar taşacak (negatif = yukarı taşır)
                left: MediaQuery.of(context).size.width * -0.2, // soldan taşma
                right: MediaQuery.of(context).size.width * -0.2, // sağdan taşma
                child: Container(
                  width: MediaQuery.of(context).size.width * 1.2,
                  height: MediaQuery.of(context).size.width * 1.2,
                  decoration: BoxDecoration(
                    color: currentHabit.color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CardLiquidWrapper(
                                borderRadius: 160,
                                statement: isLiquid,
                                statement2: isFakeLiquid,
                                shape: LiquidRoundedRectangle(
                                  borderRadius: 160,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    18,
                                    6,
                                    18,
                                    8,
                                  ),
                                  child: IntrinsicWidth(
                                    child: Center(
                                      child: Text(
                                        currentHabit.group ?? "grupsuz",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15,
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              CardLiquidWrapper(
                                statement2: isFakeLiquid,
                                borderRadius: 160,
                                statement: isLiquid,
                                shape: LiquidRoundedRectangle(
                                  borderRadius: 160,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    context
                                        .read<StyleProvider>()
                                        .setFulscreenForNow(true);
                                  },
                                  icon: Icon(Icons.fullscreen),
                                ),
                              ),
                            ],
                          ),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CardLiquidWrapper(
                                statement2: isFakeLiquid,
                                borderRadius: 320,
                                statement: isLiquid,
                                shape: LiquidOval(),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: currentHabit.color
                                      .withValues(alpha: 0.3),
                                  child: Icon(
                                    currentHabit.icon,
                                    size: 50,
                                    color: currentHabit.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                            child: Center(
                              child: IntrinsicHeight(
                                child: IntrinsicWidth(
                                  child: CardLiquidWrapper(
                                    statement2: isFakeLiquid,
                                    borderRadius: 320,
                                    statement: isLiquid,
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 320,
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            2,
                                            4,
                                            2,
                                          ),
                                          child: LiquidWrapper(
                                            statement: isLiquid,
                                            shape: LiquidOval(),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.note_alt_outlined,
                                              ),
                                              onPressed: () async {
                                                final provider = context
                                                    .read<HabitProvider>();
                                                final current = provider
                                                    .getHabitById(
                                                      currentHabit.id,
                                                    );
                                                final result =
                                                    await showNotesEditorSheet(
                                                      context,
                                                      current,
                                                    );

                                                if (result != null) {
                                                  final updated = current
                                                      .copyWith(
                                                        notesDelta: result,
                                                      );
                                                  provider.updateHabit(updated);
                                                  onHabitUpdated.call(updated);
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            26,
                                            0,
                                            26,
                                            0,
                                          ),
                                          child: Text(
                                            currentHabit.name,
                                            style: TextStyle(
                                              fontSize: 32,
                                              color: Colors.transparent,
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            4,
                                            2,
                                            4,
                                            2,
                                          ),
                                          child: LiquidWrapper(
                                            statement: isLiquid,
                                            shape: LiquidOval(),
                                            child: IconButton(
                                              icon: Icon(
                                                Icons
                                                    .format_list_bulleted_rounded,
                                              ),
                                              onPressed: () {
                                                detailSettingsSheet(
                                                  context,
                                                  currentHabit,
                                                  selectedDate ??
                                                      DateTime.now(),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: CardLiquidWrapper(
                                statement2: isFakeLiquid,
                                borderRadius: 160,
                                statement: isLiquid,
                                shape: LiquidRoundedRectangle(
                                  borderRadius: 160,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 18.0,
                                      right: 18.0,
                                      bottom: 4.0,
                                    ),
                                    child: Text(
                                      currentHabit.name,
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CardLiquidWrapper(
                          statement2: isFakeLiquid,
                          borderRadius: 160,
                          statement: isLiquid,
                          shape: LiquidRoundedRectangle(borderRadius: 320),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                            child: Column(
                              spacing: 8,
                              children: [
                                LiquidWrapper(
                                  statement: isLiquid,
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 16,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Text(
                                      currentHabit.description,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 18,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                LiquidWrapper(
                                  statement: isLiquid,
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 16,
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: 8.0,
                                      right: 8.0,
                                    ),
                                    child: Text(
                                      'Toplam $howManyDaysBeforeCreated gün önce oluşturuldu',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      ActionsForHabit(
                        isFakeLiquidBackground: isFakeLiquid,
                        isLiquidBackground: isLiquid,
                        selectedDate: selectedDate ?? DateTime.now(),
                        habitId: currentHabit.id,
                      ),

                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CardLiquidWrapper(
                                  statement2: isFakeLiquid,
                                  borderRadius: 160,
                                  statement: isLiquid,
                                  shape: LiquidRoundedRectangle(
                                    borderRadius: 96,
                                  ),
                                  child: StatCard(
                                    "Aktif Streak",
                                    "${currentHabit.currentStreak}",
                                    Icons.whatshot,
                                    Colors.orange,
                                    16,
                                    isWideOverride: true,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: AspectRatio(
                                  aspectRatio: 2.1,
                                  child: CardLiquidWrapper(
                                    statement2: isFakeLiquid,
                                    borderRadius: 160,
                                    statement: isLiquid,
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 96,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 16.0),
                                      child: Opacity(
                                        opacity: 1,
                                        child: Center(
                                          child: LayoutBuilder(
                                            builder: (context, constraintsOfGauge) {
                                              return StrengthGauge(
                                                seenStrength:
                                                    "${currentHabit.strength.toStringAsFixed(1)}%",
                                                strength: currentHabit.strength,
                                                size:
                                                    constraintsOfGauge
                                                        .maxHeight *
                                                    3 /
                                                    2,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LayoutBuilder(
                                  builder: (context, designeConst) {
                                    return CardLiquidWrapper(
                                      statement2: isFakeLiquid,
                                      borderRadius: designeConst.maxWidth / 4,
                                      statement: isLiquid,
                                      shape: LiquidRoundedRectangle(
                                        borderRadius: designeConst.maxWidth / 4,
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 1.25,
                                        child: StatCard(
                                          isWideOverride: false,
                                          "Alışkanlık Seviyesi",
                                          currentHabit.strengthLevel,
                                          currentHabit.strengthLevel == "Efsane"
                                              ? Icons.hotel_class
                                              : currentHabit.strengthLevel ==
                                                    "Usta"
                                              ? Icons.star
                                              : currentHabit.strengthLevel ==
                                                    "Güçlü"
                                              ? Icons.star_half
                                              : currentHabit.strengthLevel ==
                                                    "Orta"
                                              ? Icons.favorite
                                              : currentHabit.strengthLevel ==
                                                    "Zayıf"
                                              ? Icons.all_out
                                              : Icons.question_mark,
                                          Colors.blue,
                                          8,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LayoutBuilder(
                                  builder: (context, designeConst1) {
                                    return CardLiquidWrapper(
                                      statement2: isFakeLiquid,
                                      borderRadius: designeConst1.maxWidth / 4,
                                      statement: isLiquid,
                                      shape: LiquidRoundedRectangle(
                                        borderRadius:
                                            designeConst1.maxWidth / 4,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: AspectRatio(
                                          aspectRatio: 1.25,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return RateOfDoing(
                                                doneCount: currentHabit
                                                    .dailyProgress
                                                    .values
                                                    .where(
                                                      (entry) =>
                                                          entry != "skipped"
                                                          ? currentHabit.type ==
                                                                    HabitType
                                                                        .task
                                                                ? entry == true
                                                                : currentHabit
                                                                          .type ==
                                                                      HabitType
                                                                          .count
                                                                ? (entry ??
                                                                          0) >=
                                                                      currentHabit
                                                                          .targetCount
                                                                : currentHabit
                                                                          .type ==
                                                                      HabitType
                                                                          .time
                                                                ? (entry ??
                                                                          0) ==
                                                                      currentHabit
                                                                          .targetSeconds
                                                                : false
                                                          : false,
                                                    )
                                                    .length
                                                    .toDouble(),
                                                missedCount: currentHabit
                                                    .dailyProgress
                                                    .values
                                                    .where(
                                                      (entry) =>
                                                          entry != "skipped"
                                                          ? entry != null
                                                                ? true
                                                                : currentHabit
                                                                          .type ==
                                                                      HabitType
                                                                          .task
                                                                ? entry == false
                                                                : currentHabit
                                                                          .type ==
                                                                      HabitType
                                                                          .count
                                                                ? (entry ?? 0) <
                                                                      currentHabit
                                                                          .targetCount
                                                                : currentHabit
                                                                          .type ==
                                                                      HabitType
                                                                          .time
                                                                ? (entry ?? 0) <
                                                                      currentHabit
                                                                          .targetSeconds
                                                                : false
                                                          : false,
                                                    )
                                                    .length
                                                    .toDouble(),
                                                skippedCount: currentHabit
                                                    .dailyProgress
                                                    .values
                                                    .where(
                                                      (entry) =>
                                                          entry == "skipped",
                                                    )
                                                    .length
                                                    .toDouble(),
                                                totalCount: currentHabit
                                                    .dailyProgress
                                                    .values
                                                    .length
                                                    .toDouble(),
                                                size: constraints.maxHeight,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CardLiquidWrapper(
                          statement2: isFakeLiquid,
                          borderRadius: 8,
                          statement: isLiquid,
                          shape: LiquidRoundedRectangle(borderRadius: 16),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: DateTime.now(),
                            calendarFormat: CalendarFormat.month,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),

                            // Günlerin nasıl renkleneceğini belirle
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                // Gelecek günler → siyah / şeffaf
                                if (day.isAfter(DateTime.now())) {
                                  return Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  );
                                }
                                return null; // normal gün
                              },

                              todayBuilder: (context, day, focusedDay) {
                                return Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.pinkAccent,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },

                              markerBuilder: (context, day, events) {
                                if (day.isAfter(DateTime.now())) {
                                  return null;
                                }
                                final normalizedDay = DateTime(
                                  day.year,
                                  day.month,
                                  day.day,
                                );

                                // Kurallar:
                                // - Tüm habitler yapılmış → dolu yeşil
                                // - Bazısı yapılmış → içi boş yeşil çember
                                // - Hiçbiri yapılmamış ve atlanmış ise → içi boş açık gri çember
                                // - Hiçbiri yapılmamış ve geçmiş gün ise → dolu kırmızı

                                if (normalizedDay.isBefore(
                                  currentHabit.createdAt.subtract(
                                    Duration(days: 1),
                                  ),
                                )) {
                                  return Center(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.8,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                // Tamamı yapılmış
                                if (currentHabit.isCompletedOnDate(
                                      normalizedDay,
                                    ) ||
                                    currentHabit.getCountProgressForDate(
                                          normalizedDay,
                                        ) ==
                                        (currentHabit.targetCount?.toInt()) ||
                                    currentHabit.getSecondsProgressForDate(
                                          normalizedDay,
                                        ) ==
                                        (currentHabit.targetSeconds?.toInt())) {
                                  return Center(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: context
                                            .read<HabitProvider>()
                                            .getMixedColor(currentHabit.id)
                                            .withValues(alpha: 0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (currentHabit.type == HabitType.time
                                    ? currentHabit.getSecondsProgressForDate(
                                                normalizedDay,
                                              ) <
                                              (currentHabit.targetSeconds!
                                                  .toInt()) &&
                                          currentHabit
                                                  .getSecondsProgressForDate(
                                                    normalizedDay,
                                                  ) >
                                              0
                                    : currentHabit.type == HabitType.count
                                    ? currentHabit.getCountProgressForDate(
                                                normalizedDay,
                                              ) <
                                              (currentHabit.targetCount!
                                                  .toInt()) &&
                                          currentHabit.getCountProgressForDate(
                                                normalizedDay,
                                              ) >
                                              0
                                    : false) {
                                  return Center(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: context
                                              .read<HabitProvider>()
                                              .getMixedColor(currentHabit.id)
                                              .withValues(alpha: 0.9),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: context
                                                .read<HabitProvider>()
                                                .getMixedColor(currentHabit.id)
                                                .withValues(alpha: 0.9),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (currentHabit.isSkippedOnDate(
                                  normalizedDay,
                                )) {
                                  return Center(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.grey.withValues(
                                            alpha: 0.6,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: Colors.grey.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                if (currentHabit.isCompletedOnDate(
                                          normalizedDay,
                                        ) ==
                                        false ||
                                    currentHabit.getCountProgressForDate(
                                          normalizedDay,
                                        ) ==
                                        0 ||
                                    currentHabit.getSecondsProgressForDate(
                                          normalizedDay,
                                        ) ==
                                        0) {
                                  return Center(
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.8,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
