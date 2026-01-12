import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../classes/durationformatter.dart';
import '../classes/habit.dart';
import '../providers/habitprovider.dart';

void showTimeSelectorSheet(
    BuildContext context,
    Habit habit,
    DateTime selectedDate,
    ) {
  // Başlangıç değerleri
  num currentHours = habit.getSecondsProgressForDate(selectedDate).hours;
  num currentMinutes = habit.getSecondsProgressForDate(selectedDate).minutes;
  num currentSeconds = habit.getSecondsProgressForDate(selectedDate).seconds;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    enableDrag: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Container(
        height: 500,
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Üst bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const Text(
                    "Süre Seç",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      "Tamam",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

            // WHEEL'LER
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SAAT
                  Expanded(
                    child: WheelSlider.number(
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
                        fontSize: 30,
                        color: Colors.white,
                      ),
                      unSelectedNumberStyle: const TextStyle(
                        fontSize: 24,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  // DAKİKA
                  Expanded(
                    child: WheelSlider.number(
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
              padding: const EdgeInsets.all(20),
              child: Text(
                "${currentHours.toInt().toString().padLeft(2, '0')}:${currentMinutes.toInt().toString().padLeft(2, '0')}:${currentSeconds.toInt().toString().padLeft(2, '0')}",
                style: const TextStyle(color: Colors.white70, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}