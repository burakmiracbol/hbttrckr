import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../classes/habit.dart';
import '../providers/habitprovider.dart';

void showCountSelectorSheet(
    BuildContext context,
    Habit currentHabit, {
      required Habit habit,
    }) {
  num? nCurrentValue;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: 400,
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Icon(Icons.cancel_outlined),
                ),
                Text(
                  "Sayı Seç",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                ElevatedButton(
                  onPressed: () {
                    // örnek değer, sen değiştireceksin
                    Navigator.pop(ctx);
                  },
                  child: Icon(Icons.done),
                ),
              ],
            ),
          ),
          // BURAYA SEN TASARIM YAPACAKSIN
          Expanded(
            child: WheelSlider.number(
              horizontal: false,
              isInfinite: false,
              pointerColor: Colors.white,
              showPointer: false,
              perspective: 0.01,
              verticalListHeight: double.infinity,
              totalCount: habit.maxCount == null
                  ? 999
                  : habit.maxCount!.toInt(),
              initValue: habit.achievedCount,
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
            ),
          ), // boş alan
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}