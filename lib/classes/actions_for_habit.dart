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
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import '../actions/detail_screen/count_selector_sheet.dart';
import '../actions/detail_screen/time_selector_sheet.dart';
import '../extensions/duration_formatter.dart';
import 'liquid_wrapper.dart';


class ActionsForHabit extends StatelessWidget {
  final bool isLiquidBackground;
  final String habitId;
  final DateTime selectedDate;
  const ActionsForHabit({
    required this.isLiquidBackground,
    required this.selectedDate,
    required this.habitId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Habit currentHabit = context.read<HabitProvider>().getHabitById(habitId);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: LiquidWrapper(
            statement: isLiquidBackground,
            shape: LiquidRoundedRectangle(borderRadius: 160),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TASK
                  if (currentHabit.type == HabitType.task)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconButton(
                        onPressed: () {
                          currentHabit.isSkippedOnDate(
                                selectedDate,
                              )
                              ? currentHabit.unSkipOnDate(
                                  selectedDate,
                                )
                              : context
                                    .read<HabitProvider>()
                                    .toggleTaskCompletion(currentHabit.id);
                        },
                        icon:
                            currentHabit.isSkippedOnDate(
                              selectedDate,
                            )
                            ? Icon(Icons.skip_next)
                            : currentHabit.isCompletedOnDate(
                                selectedDate,
                              )
                            ? const Icon(Icons.done, color: Colors.green)
                            : const Icon(Icons.circle_outlined),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    )
                  // COUNT
                  else if (currentHabit.type == HabitType.count)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          currentHabit.isSkippedOnDate(
                                selectedDate,
                              )
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: LiquidWrapper(
                                    statement: isLiquidBackground,
                                    shape: LiquidRoundedRectangle(borderRadius: 160),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: currentHabit
                                              .color
                                              .withValues(alpha: 0.2),
                                        ),
                                        onPressed: () {
                                          context
                                              .read<HabitProvider>()
                                              .incrementCount(
                                                currentHabit.id,
                                              );
                                        },
                                        icon: Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                ),

                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2.0,
                              bottom: 2.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            child: LiquidWrapper(
                              statement: isLiquidBackground,
                              shape: LiquidRoundedRectangle(borderRadius: 160),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: currentHabit.color
                                      .withValues(alpha: 0.1),
                                  shadowColor: Colors
                                      .transparent, // Arka plan transparent ise gölgeyi de kaldırabilirsin
                                  shape: const StadiumBorder(),
                                  minimumSize: Size
                                      .zero, // Boyut sınırlamasını kaldırır
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // Tıklama alanını sıkıştırır
                                ),
                                onPressed: () {
                                  currentHabit.isSkippedOnDate(
                                        selectedDate,
                                      )
                                      ? currentHabit.unSkipOnDate(
                                          selectedDate,
                                        )
                                      : showCountSelectorSheet(
                                          selectedDate,
                                          context,
                                          currentHabit,
                                          habit: currentHabit,
                                        );
                                },
                                child:
                                    currentHabit.isSkippedOnDate(
                                      selectedDate,
                                    )
                                    ? Text("Atlandı")
                                    : Text(
                                        "${currentHabit.getCountProgressForDate(selectedDate)}",
                                      ),
                              ),
                            ),
                          ),

                          currentHabit.isSkippedOnDate(
                                selectedDate,
                              )
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: LiquidWrapper(
                                    statement: isLiquidBackground,
                                    shape: LiquidRoundedRectangle(borderRadius: 160),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: IconButton(
                                        style: IconButton.styleFrom(
                                          backgroundColor: currentHabit
                                              .color
                                              .withValues(alpha: 0.2),
                                        ),
                                        onPressed: () {
                                          context
                                              .read<HabitProvider>()
                                              .decrementCount(
                                                currentHabit.id,
                                              );
                                        },
                                        icon: Icon(Icons.remove),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  // TIME
                  else if (currentHabit.type == HabitType.time)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          currentHabit.isSkippedOnDate(
                                selectedDate,
                              )
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LiquidWrapper(
                                    statement: isLiquidBackground,
                                    shape: LiquidRoundedRectangle(borderRadius: 160),
                                    child: Consumer<HabitProvider>(
                                      builder: (context, provider, child) {
                                        return IconButton(
                                          style: IconButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          onPressed: () {
                                            provider.resetTimer(
                                              currentHabit.id,
                                              selectedDate ,
                                            ); // sıfırla
                                          },
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 25,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LiquidWrapper(
                              statement: isLiquidBackground,
                              shape: LiquidRoundedRectangle(borderRadius: 160),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors
                                      .transparent, // Arka plan transparent ise gölgeyi de kaldırabilirsin
                                  shape: const StadiumBorder(),
                                  minimumSize: Size
                                      .zero, // Boyut sınırlamasını kaldırır
                                  tapTargetSize: MaterialTapTargetSize
                                      .shrinkWrap, // Tıklama alanını sıkıştırır
                                ),
                                onPressed: () {
                                  currentHabit.isSkippedOnDate(
                                        selectedDate,
                                      )
                                      ? currentHabit.unSkipOnDate(
                                          selectedDate,
                                        )
                                      : showTimeSelectorSheet(
                                          context,
                                          currentHabit,
                                          selectedDate,
                                        );
                                },
                                child:
                                    currentHabit.isSkippedOnDate(
                                      selectedDate,
                                    )
                                    ? Text("Atlandı")
                                    : Text(
                                        currentHabit
                                            .getSecondsProgressForDate(
                                              selectedDate ,
                                            )
                                            .toInt()
                                            .formattedHMS,
                                      ),
                              ),
                            ),
                          ),
                          currentHabit.isSkippedOnDate(
                                selectedDate,
                              )
                              ? Container()
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LiquidWrapper(
                                    statement: isLiquidBackground,
                                    shape: LiquidRoundedRectangle(borderRadius: 160),
                                    child: Consumer<HabitProvider>(
                                      builder: (context, provider, child) {
                                        final bool isRunning =
                                            provider
                                                .runningTimers[currentHabit
                                                .id] ??
                                            false;

                                        return IconButton(
                                          style: IconButton.styleFrom(
                                            foregroundColor: Colors.grey,
                                          ),
                                          onPressed: () {
                                            provider.toggleTimer(
                                              currentHabit.id,

                                              selectedDate ,
                                            );
                                          },
                                          icon: Icon(
                                            isRunning
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            size: 25,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  else
                    const Placeholder(),
                  // durum yönetiminde bizdir (production için en iyi yöntem bu bu arada error yese adam diğer işleri engellenecek)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
