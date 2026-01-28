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
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';

void showCountSelectorSheet(
    DateTime selectedDate,
  BuildContext context,
  Habit currentHabit, {
  required Habit habit,
}) {
  num? nCurrentValue;
  showModalBottomSheet(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: true,
    builder: (ctx) => ClipRRect(
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
          child: LiquidGlassLayer(
            child: GlassGlowLayer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LiquidGlass(
                            shape: LiquidRoundedRectangle(borderRadius: 64),
                            child: GlassGlow(
                              child: ElevatedButton(

                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                child: const Icon(Icons.cancel_outlined),
                              ),
                            ),
                          ),
                          LiquidGlass(
                            shape: LiquidRoundedRectangle(borderRadius: 64),
                            child: GlassGlow(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(16,6,16,6),
                                child: Text(
                                  "Sayı Seç",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          LiquidGlass(
                            shape: LiquidRoundedRectangle(borderRadius: 64),
                            child: GlassGlow(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                },
                                child: Icon(Icons.done),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // BURAYA SEN TASARIM YAPACAKSIN
                  WheelSlider.number(
                    horizontal: true,
                    isInfinite: false,
                    pointerColor: Colors.white,
                    showPointer: false,
                    perspective: 0.01,
                    verticalListHeight: double.infinity,
                    totalCount: 999,
                    initValue: habit.dailyProgress[selectedDate],
                    selectedNumberStyle: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white,
                    ),
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
                  ), // boş alan
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
