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

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../classes/glass_card.dart';
import '../../classes/habit.dart';
import '../../extensions/duration_formatter.dart';

void showShareDetailSheet(
    BuildContext context,
    Habit currentHabit,
    DateTime selectedDate,
    ) {
  ScreenshotController screenshotController = ScreenshotController();
  Map<String, Uint8List?> imageState = {'image': null};
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: false,
    context: context,
    builder: (sheetContext) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(64)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(64)),
            border: Border.all(
              color: Colors.white.withOpacity(
                0.2,
              ), // İnce ışık yansıması (kenarlık)
              width: 1.5,
            ),
          ),
          child: StatefulBuilder(
            builder: (ctx, setStateSheet) {
              return Padding(
                padding: EdgeInsets.all(8),
                child: Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Screenshot(
                          controller: screenshotController,
                          child: IntrinsicWidth(
                            child: Card(
                              color: currentHabit.color.withValues(alpha: 0.3),
                              child: IntrinsicWidth(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [
                                    IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              8.0,
                                              4.0,
                                              4.0,
                                              4.0,
                                            ),
                                            child: glassContainer(
                                              borderRadiusRect: 300.0,
                                              context: context,
                                              child: AspectRatio(
                                                aspectRatio: 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    14.0,
                                                  ),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      currentHabit.icon,
                                                      size: null,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              6.0,
                                              4.0,
                                              6.0,
                                              4.0,
                                            ),
                                            child: Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                        6.0,
                                                        2.0,
                                                        4.0,
                                                        2.0,
                                                      ),
                                                      child: glassContainer(
                                                        context: context,
                                                        child: Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0,
                                                              top: 4.0,
                                                              bottom: 4.0,
                                                            ),
                                                            child: Text(
                                                              currentHabit.name,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.fromLTRB(
                                                        6.0,
                                                        2.0,
                                                        4.0,
                                                        2.0,
                                                      ),
                                                      child: glassContainer(
                                                        context: context,
                                                        child: Expanded(
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                              left: 8.0,
                                                              right: 8.0,
                                                              top: 4.0,
                                                              bottom: 4.0,
                                                            ),
                                                            child: Text(
                                                              currentHabit
                                                                  .description,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                6.0,
                                                4.0,
                                                8.0,
                                                4.0,
                                              ),
                                              child: glassContainer(
                                                context: context,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets.all(
                                                          4.0,
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .health_and_safety,
                                                        ),
                                                      ),
                                                      Text(
                                                        "Güç seviyesi : ${currentHabit.strengthLevel}",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Wrap(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              6.0,
                                              4.0,
                                              6.0,
                                              4.0,
                                            ),
                                            child: glassContainer(
                                              context: context,
                                              child: Card(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.whatshot_rounded,
                                                      ),
                                                      Text(
                                                        "Streak : ${currentHabit.currentStreak} gün",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              6.0,
                                              4.0,
                                              6.0,
                                              4.0,
                                            ),
                                            child: glassContainer(
                                              context: context,
                                              child: Card(
                                                color: Colors.transparent,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .keyboard_double_arrow_up,
                                                          ),
                                                          Text(
                                                            "Güç : %${currentHabit.strength}",
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
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              6.0,
                                              4.0,
                                              6.0,
                                              4.0,
                                            ),
                                            child: glassContainer(
                                              context: context,
                                              child: Card(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        currentHabit.type ==
                                                            HabitType.task
                                                            ? Icons.check
                                                            : currentHabit
                                                            .type ==
                                                            HabitType
                                                                .count
                                                            ? Icons
                                                            .add_box_rounded
                                                            : currentHabit
                                                            .type ==
                                                            HabitType.time
                                                            ? Icons.timer
                                                            : Icons
                                                            .question_mark,
                                                      ),
                                                      Text(
                                                        "Tipi : ${currentHabit.type == HabitType.task
                                                            ? "Görev"
                                                            : currentHabit.type == HabitType.count
                                                            ? "Sayılı"
                                                            : currentHabit.type == HabitType.time
                                                            ? "Süreli"
                                                            : "Bilinmeyen"}",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              6.0,
                                              4.0,
                                              6.0,
                                              4.0,
                                            ),
                                            child: glassContainer(
                                              context: context,
                                              child: Card(
                                                color: Colors.transparent,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_month,
                                                      ),
                                                      Text(
                                                        currentHabit.type ==
                                                            HabitType.task
                                                            ? currentHabit.isCompletedOnDate(
                                                          selectedDate,
                                                        )
                                                            ? "Tamamlandı"
                                                            : "Tamamlanmadı"
                                                            : currentHabit
                                                            .type ==
                                                            HabitType
                                                                .count
                                                            ? "${currentHabit.getCountProgressForDate(selectedDate)} / ${currentHabit.targetCount?.toInt()}"
                                                            : currentHabit
                                                            .type ==
                                                            HabitType.time
                                                            ? "${currentHabit.getSecondsProgressForDate(selectedDate).formattedHMS} / ${currentHabit.targetSeconds?.toInt().formattedHMS} "
                                                            : "Bilinmeyen",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: imageState['image'] != null
                            ? ElevatedButton(
                          onPressed: () {
                            // Burada share işlemi yapılabilir
                            debugPrint(
                              "Screenshot paylaşıldı: ${imageState['image']!.length} bytes",
                            );
                          },
                          child: Text("Paylaş"),
                        )
                            : ElevatedButton(
                          onPressed: () async {
                            final directory =
                                (await getApplicationDocumentsDirectory())
                                    .path; //from path_provide package
                            String fileName =
                                "${currentHabit.name} ${DateTime.now().microsecondsSinceEpoch.toString()}.png";
                            var path = directory;
                            screenshotController.captureAndSave(
                              path,
                              fileName: fileName,
                            );
                          },
                          child: Text("Screenshot Al"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
