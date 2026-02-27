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
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hbttrckr/classes/rate_of_doing.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/data_types/habit.dart';
import 'package:hbttrckr/classes/strength_gauge.dart';

import '../classes/glass_card.dart';
import '../classes/stats_card.dart';
import '../providers/scheme_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    // Normalize today (date-only) to avoid time-of-day issues when comparing
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // Determine the earliest habit creation date safely
    DateTime firstHabitCreatedTime;
    if (habits.isEmpty) {
      firstHabitCreatedTime = todayDate;
    } else {
      // pick the earliest createdAt among habits and normalize to date-only
      final earliest = habits
          .map((h) => h.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      firstHabitCreatedTime = DateTime(
        earliest.year,
        earliest.month,
        earliest.day,
      );
    }

    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => h.currentStreak > 0).length;
    final groupHabits = context
        .read<HabitProvider>()
        .getUniqueGroupNames(context.watch<HabitProvider>().habits)
        .length;
    final perfectHabits = habits.where((h) => h.strength >= 90).length;
    final totalStrength = habits.fold(0.0, (sum, h) => sum + h.strength);

    // Tüm gün-habit kombinasyonları için istatistik hesapla
    double doneCount = 0;
    double missedCount = 0;
    double skippedCount = 0;
    double totalCount = 0;

    for (final habit in habits) {
      // Habit oluşturulduğu günden bugüne kadar geçen gün sayısı
      int daysForThisHabit =
          todayDate
              .difference(
                DateTime(
                  habit.createdAt.year,
                  habit.createdAt.month,
                  habit.createdAt.day,
                ),
              )
              .inDays +
          1;
      totalCount += daysForThisHabit;

      for (final dynamicValues in habit.dailyProgress.values) {
        //final dynamic value = habit.dailyProgress[startDate];
        daysForThisHabit -= 1;
        //habit.dailyProgress.entries
        bool isDone = false;
        bool isSkipped = dynamicValues == "skipped";

        if (!isSkipped) {
          if (habit.type == HabitType.task) {
            isDone = dynamicValues == true;
          } else if (habit.type == HabitType.count) {
            final achieved = (dynamicValues is num) ? dynamicValues.toInt() : 0;
            isDone = achieved >= (habit.targetCount ?? 1);
          } else if (habit.type == HabitType.time) {
            final achievedSeconds = (dynamicValues is num)
                ? dynamicValues.toInt()
                : 0;
            final targetSecs = habit.targetSeconds ?? 60;
            isDone = achievedSeconds >= targetSecs;
          }
        }

        if (isDone) {
          doneCount++;
        } else if (isSkipped) {
          skippedCount++;
        }
      }
      missedCount = totalCount - (doneCount + skippedCount);
    }

    return GlassGlowLayer(
      child: LiquidGlassLayer(
        child: Scaffold(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // problematic gridview
                LayoutBuilder(
                  builder: (context, constraints) {
                    const maxTileExtent = 185.0;
                    final crossAxisCount =
                        (constraints.maxWidth / maxTileExtent)
                            .floor()
                            .clamp(1, 6)
                            .toInt();

                    List<int> buildSpans(int columns, int count) {
                      final spans = List<int>.filled(count, 1);
                      if (count <= 2 || columns <= 3) {
                        return spans;
                      }
                      if (count == 6 && columns == 4) {
                        spans[2] = 2;
                        spans[5] = 2;
                        return spans;
                      }
                      if (count == 6 && columns == 5) {
                        spans[3] = 2;
                        spans[4] = 2;
                        spans[5] = 3;
                        return spans;
                      }
                      return spans;
                    }

                    const statCardCount = 6;
                    final spans = buildSpans(crossAxisCount, statCardCount);

                    final statCards = <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    (designeConste.maxHeight / 4),
                                  ),
                                ),
                              ),
                              color: Theme.of(
                                context,
                              ).cardColor.withValues(alpha: 0.2),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: glassContainer(
                                  borderRadiusRect: designeConste.maxHeight / 4,
                                  context: context,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RateOfDoing(
                                          doneCount: doneCount,
                                          missedCount: missedCount,
                                          skippedCount: skippedCount,
                                          totalCount: totalCount,
                                          size: constraints.minWidth,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return glassContainer(
                              borderRadiusRect: (designeConste.maxHeight / 4),
                              context: context,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      (designeConste.maxHeight / 4),
                                    ),
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.2),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            top: 32.0,
                                            bottom: 8.0,
                                            right: 8.0,
                                            left: 8.0,
                                          ),
                                          child: StrengthGauge(
                                            seenStrength:
                                                "${(totalStrength / totalHabits.clamp(1, 999)).toStringAsFixed(1)}%",
                                            strength:
                                                (totalStrength /
                                                totalHabits.clamp(1, 999)),
                                            size: constraints.minWidth,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return glassContainer(
                              borderRadiusRect: (designeConste.maxHeight / 4),
                              context: context,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      (designeConste.maxHeight / 4),
                                    ),
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.2),
                                child: SizedBox.expand(
                                  child: StatCard(
                                    "Toplam Alışkanlık",
                                    totalHabits.toString(),
                                    Icons.list_alt,
                                    Colors.blue,
                                    16,
                                    isWideOverride: spans[2] > 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return glassContainer(
                              borderRadiusRect: (designeConste.maxHeight / 4),
                              context: context,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      (designeConste.maxHeight / 4),
                                    ),
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.2),
                                child: SizedBox.expand(
                                  child: StatCard(
                                    "Aktif Streak",
                                    activeHabits.toString(),
                                    Icons.whatshot,
                                    Colors.orange,
                                    16,
                                    isWideOverride: spans[3] > 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return glassContainer(
                              borderRadiusRect: (designeConste.maxHeight / 4),
                              context: context,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      (designeConste.maxHeight / 4),
                                    ),
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.2),
                                child: SizedBox.expand(
                                  child: StatCard(
                                    "Efsane Seviye",
                                    perfectHabits.toString(),
                                    Icons.star,
                                    Colors.purple,
                                    16,
                                    isWideOverride: spans[4] > 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: LayoutBuilder(
                          builder: (context, designeConste) {
                            return glassContainer(
                              borderRadiusRect: (designeConste.maxHeight / 4),
                              context: context,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      (designeConste.maxHeight / 4),
                                    ),
                                  ),
                                ),
                                color: Theme.of(
                                  context,
                                ).cardColor.withValues(alpha: 0.2),
                                child: SizedBox.expand(
                                  child: StatCard(
                                    "Alışkanlık Grup Sayısı",
                                    groupHabits.toString(),
                                    Icons.grid_view_rounded,
                                    Colors.green,
                                    16,
                                    isWideOverride: spans[5] > 1,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ];

                    return StaggeredGrid.count(
                      axisDirection: AxisDirection.down,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: List.generate(statCards.length, (index) {
                        final span = spans[index];
                        final mainSpan = index < 2 ? span : 1;
                        return StaggeredGridTile.count(
                          crossAxisCellCount: span,
                          mainAxisCellCount: mainSpan,
                          child: statCards[index],
                        );
                      }),
                    );
                  },
                ),

                // GridView sonu
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Card(
                    color: context.read<CurrentThemeMode>().isMica
                        ? Theme.of(context).cardColor
                        : Theme.of(context).cardColor.withValues(alpha: 0.2),
                    child: glassContainer(
                      context: context,
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.month,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        // Günlerin nasıl renkleneceğini belirle
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            // Gelecek günler → siyah / şeffaf
                            if (day.isAfter(todayDate)) {
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
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          },

                          markerBuilder: (context, day, events) {
                            if (day.isAfter(todayDate)) {
                              return null;
                            }

                            final normalizedDay = DateTime(
                              day.year,
                              day.month,
                              day.day,
                            );

                            // Gün için tüm habitleri kontrol et
                            final habits = context.read<HabitProvider>().habits;

                            if (habits.isEmpty) return null;

                            int doneCount = 0;
                            int skippedCount = 0;

                            bool sameDate(DateTime a, DateTime b) =>
                                a.year == b.year &&
                                a.month == b.month &&
                                a.day == b.day;

                            for (final habit in habits) {
                              // normalize edilmiş gün için o habit'in yapılıp yapılmadığını güvenli şekilde belirle
                              bool isDone = false;
                              bool isSkipped = false;

                              // skipped kontrolü (varsa)
                              try {
                                isSkipped = habit.isSkippedOnDate(
                                  normalizedDay,
                                );
                              } catch (_) {
                                isSkipped = false;
                              }

                              // Güvenli günlük veri okuma: doğrudan map lookup yerine tarihe göre eşleme
                              dynamic v;
                              try {
                                for (final entry
                                    in habit.dailyProgress.entries) {
                                  final dynamic k = entry
                                      .key; // treat as dynamic to allow legacy string keys
                                  if (k is DateTime) {
                                    if (sameDate(k, normalizedDay)) {
                                      v = entry.value;
                                      break;
                                    }
                                  } else if (k is String) {
                                    try {
                                      final parsed = DateTime.parse(k);
                                      if (sameDate(parsed, normalizedDay)) {
                                        v = entry.value;
                                        break;
                                      }
                                    } catch (_) {}
                                  }
                                }
                              } catch (_) {
                                v = null;
                              }

                              if (habit.type == HabitType.task) {
                                isDone = v == true;
                              } else if (habit.type == HabitType.count) {
                                final achieved = (v is num) ? v.toInt() : 0;
                                isDone = achieved >= (habit.targetCount ?? 1);
                              } else if (habit.type == HabitType.time) {
                                final achievedSeconds = (v is num)
                                    ? v.toInt()
                                    : 0;
                                final targetSecs = habit.targetSeconds ?? 60;
                                isDone = achievedSeconds >= targetSecs;
                              }

                              if (isDone) doneCount++;
                              if (!isDone && isSkipped) skippedCount++;
                            }

                            // Kurallar:
                            // - Tüm habitler yapılmış → dolu yeşil
                            // - Bazısı yapılmış → içi boş yeşil çember
                            // - Hiçbiri yapılmamış ve atlanmış ise → içi boş açık gri çember
                            // - Hiçbiri yapılmamış ve geçmiş gün ise → dolu kırmızı

                            if (normalizedDay.isBefore(
                              firstHabitCreatedTime.subtract(Duration(days: 1)),
                            )) {
                              return Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.8),
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
                            if (doneCount == habits.length) {
                              return Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.8),
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

                            // Bazısı yapılmış
                            if (doneCount > 0) {
                              return Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.green.withValues(
                                        alpha: 0.9,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        color: Colors.green.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            // Hiç yapılmamış ama atlananlar varsa (skipped)
                            if (skippedCount > 0) {
                              return Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.6),
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

                            if (doneCount == 0 && skippedCount == 0) {
                              return Center(
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.8),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
