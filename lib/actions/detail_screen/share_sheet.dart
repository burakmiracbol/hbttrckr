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
import '../../classes/all_widgets.dart';
import '../../classes/glass_card.dart';
import 'package:hbttrckr/data_types/habit.dart';
import '../../extensions/duration_formatter.dart';

void showShareDetailSheet(
  BuildContext context,
  Habit currentHabit,
  DateTime selectedDate,
) {
  ScreenshotController screenshotController = ScreenshotController();
  Map<String, Uint8List?> imageState = {'image': null};
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setStateSheet) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Screenshot(
                controller: screenshotController,
                child: buildHabitCard(context, currentHabit, selectedDate),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: imageState['image'] != null
                  ? PlatformButton(
                      onPressed: () {
                        debugPrint(
                          "Screenshot paylaşıldı: ${imageState['image']!.length} bytes",
                        );
                      },
                      child: Text("Paylaş"),
                    )
                  : PlatformButton(
                      onPressed: () async {
                        final directory =
                            (await getApplicationDocumentsDirectory()).path;
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
        );
      },
    ),
  );
}

Widget buildHabitCard(
  BuildContext context,
  Habit currentHabit,
  DateTime selectedDate,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(28),
      color: currentHabit.color.withValues(alpha: 0.12),
      border: Border.all(
        color: currentHabit.color.withValues(alpha: 0.25),
        width: 1.5,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              glassContainer(
                context: context,
                borderRadiusRect: 20,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    currentHabit.icon,
                    color: currentHabit.color,
                    size: 36,
                  ), // Dev İkon
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentHabit.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentHabit.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- ALT BÖLÜM (İSTATİSTİK GRİDİ) ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              double aspectRatio;
              bool isRowLayout;

              // 663px MAX GENİŞLİĞE GÖRE HESAPLANMIŞ BREAKPOINT'LER
              if (constraints.maxWidth >= 400) {
                // MOD 1: YAN YANA 4 TANE (Senin istediğin 4x1)
                crossAxisCount = 4;
                aspectRatio = 0.95; // Kutuları biraz dikey yapıyoruz ki sığsın
                isRowLayout = false; // İkon üstte, yazı altta
              } else if (constraints.maxWidth >= 280) {
                // MOD 2: 2x2 GRID
                crossAxisCount = 2;
                aspectRatio = 1.7; // Kutuları yatay dikdörtgen yapıyoruz
                isRowLayout = false; // İkon üstte, yazı altta
              } else {
                // MOD 3: ÜST ÜSTE 4 SATIR (Senin tabirinle 1x4)
                crossAxisCount = 1;
                aspectRatio = 4.2; // İnce uzun şeritler
                isRowLayout = true; // İkon solda, yazı sağda (Row)
              }

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: aspectRatio,
                children: [
                  _buildResponsiveTile(context, Icons.whatshot_rounded, "${currentHabit.currentStreak}", "Gün Streak", Colors.orange, isRowLayout),
                  _buildResponsiveTile(context, Icons.bolt_rounded, "%${currentHabit.strength}", "Güç", Colors.blue, isRowLayout),
                  _buildResponsiveTile(context, _getTypeIcon(currentHabit.type), _getTypeName(currentHabit.type), "Hedef Tipi", Colors.purple, isRowLayout),
                  _buildResponsiveTile(context, Icons.insights_rounded, _getProgressText(currentHabit, selectedDate), "İlerleme", Colors.green, isRowLayout),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildResponsiveTile(BuildContext context, IconData icon, String value, String label, Color accentColor, bool isRowLayout) {
  return glassContainer(
    context: context,
    borderRadiusRect: 15,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: isRowLayout
          ? Row( // Üst üste modunda (1 sütun) ikon solda
        children: [
          const SizedBox(width: 8),
          Icon(icon, size: 24, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(fit: BoxFit.scaleDown, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      )
          : Column( // 2x2 ve 4'lü modda ikon üstte
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: accentColor),
          const SizedBox(height: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ),
          ),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700]), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    ),
  );
}

// --- Yardımcı Metodlar (Mantık aynı kaldı) ---

IconData _getTypeIcon(HabitType type) {
  switch (type) {
    case HabitType.task:
      return Icons.check;
    case HabitType.count:
      return Icons.add_box_rounded;
    case HabitType.time:
      return Icons.timer;
    default:
      return Icons.question_mark;
  }
}

String _getTypeName(HabitType type) {
  switch (type) {
    case HabitType.task:
      return "Görev";
    case HabitType.count:
      return "Sayılı";
    case HabitType.time:
      return "Süreli";
    default:
      return "Bilinmeyen";
  }
}

String _getProgressText(Habit currentHabit, DateTime selectedDate) {
  if (currentHabit.type == HabitType.task) {
    return currentHabit.isCompletedOnDate(selectedDate)
        ? "Tamamlandı"
        : "Bekliyor";
  } else if (currentHabit.type == HabitType.count) {
    return "${currentHabit.getCountProgressForDate(selectedDate)}/${currentHabit.targetCount?.toInt()}";
  } else {
    return currentHabit.getSecondsProgressForDate(selectedDate).formattedHMS;
  }
}
