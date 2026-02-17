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
import 'package:hbttrckr/providers/style_provider.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';
import '../../classes/all_widgets.dart';

void showCountSelectorSheet(
  DateTime selectedDate,
  BuildContext context,
  Habit currentHabit, {
  required Habit habit,
}) {
  num? nCurrentValue;
  Selectors selector = Selectors.count;
  showPlatformModalSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    builder: (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 8),
          child: PlatformTitle(
            title: "Sayı Seç",
            color: Colors.white,
            fontSize: 18,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          ),
        ),

        // BURAYA SEN TASARIM YAPACAKSI
        WheelSlider.number(
          horizontal: context.read<StyleProvider>().getOrientationForSelectors(
            selector,
          ),
          isInfinite: true,
          pointerColor: Colors.white,
          showPointer: false,
          perspective: 0.01,
          totalCount: 999,
          initValue: habit.dailyProgress[selectedDate] ?? 0,
          selectedNumberStyle: TextStyle(fontSize: 13.0, color: Colors.white),
          unSelectedNumberStyle: TextStyle(
            fontSize: 12.0,
            color: Colors.white.withValues(alpha: 200),
          ),
          currentIndex: nCurrentValue,
          onValueChanged: (val) {
            Provider.of<HabitProvider>(
              context,
              listen: false,
            ).changeCount(habit.id, val);
          },
          hapticFeedbackType: HapticFeedbackType.heavyImpact,
        ),
      ],
    ),
  );
}
