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

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';
import '../../classes/all_widgets.dart';
import '../../extensions/duration_formatter.dart';
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';

void showTimeSelectorSheet(
  BuildContext context,
  Habit habit,
  DateTime selectedDate,
) {
  // Başlangıç değerleri
  num currentHours = habit.getSecondsProgressForDate(selectedDate).hours;
  num currentMinutes = habit.getSecondsProgressForDate(selectedDate).minutes;
  num currentSeconds = habit.getSecondsProgressForDate(selectedDate).seconds;

  showPlatformModalSheet(
    context: context,
    isScrollControlled: false,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: PlatformTitle(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              title: 'Süre Seç',
              color: Colors.white,
              fontSize: 18,
            ),
          ),

          // WHEEL'LER
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SAAT
                Expanded(
                  child: WheelSlider.number(
                    perspective: 0.009,
                    horizontal: false,
                    totalCount: 24,
                    initValue: currentHours,
                    currentIndex: currentHours,
                    onValueChanged: (val) {
                      setStateSheet(() {
                        currentHours = val;
                      });
                      final total =
                          (currentHours * 3600) +
                          (currentMinutes * 60) +
                          currentSeconds;
                      context.read<HabitProvider>().setSecondsForThatDate(
                        habit.id,
                        total.toInt(),
                      );
                    },
                    selectedNumberStyle: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                    unSelectedNumberStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white54,
                    ),
                  ),
                ),
                // DAKİKA
                Expanded(
                  child: WheelSlider.number(
                    perspective: 0.009,
                    horizontal: false,
                    totalCount: 60,
                    initValue: currentMinutes,
                    currentIndex: currentMinutes,
                    onValueChanged: (val) {
                      setStateSheet(() {
                        currentMinutes = val;
                        // diğerleri için de minutes = val.toInt(); seconds = val.toInt();
                      });

                      // Tamam butonuna gerek yok, anında kaydet
                      final total =
                          (currentHours * 3600) +
                          (currentMinutes * 60) +
                          currentSeconds;
                      context.read<HabitProvider>().setSecondsForThatDate(
                        habit.id,
                        total.toInt(),
                      );
                    },
                  ),
                ),
                // SANİYE
                Expanded(
                  child: WheelSlider.number(
                    perspective: 0.009,
                    horizontal: false,
                    totalCount: 60,
                    initValue: currentSeconds,
                    currentIndex: currentSeconds,
                    onValueChanged: (val) {
                      setStateSheet(() {
                        currentSeconds = val;
                        // diğerleri için de minutes = val.toInt(); seconds = val.toInt();
                      });

                      // Tamam butonuna gerek yok, anında kaydet
                      final total =
                          (currentHours * 3600) +
                          (currentMinutes * 60) +
                          currentSeconds;
                      context.read<HabitProvider>().setSecondsForThatDate(
                        habit.id,
                        total.toInt(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Toplam göster (isteğe bağlı)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 0),
            child: PlatformCard(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                child: Text(
                  "${currentHours.toInt().toString().padLeft(2, '0')}:${currentMinutes.toInt().toString().padLeft(2, '0')}:${currentSeconds.toInt().toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white70, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
