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
import 'package:hbttrckr/actions/detail_screen/resign_sheet.dart';
import 'package:hbttrckr/actions/detail_screen/share_sheet.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/classes/all_widgets.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'delete_dialog.dart';

void detailSettingsSheet(
  BuildContext context,
  Habit currentHabit,
  DateTime selectedDate,
) {
  showPlatformModalSheet(
      enableDrag: true,
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: PlatformTitle(
                padding: const EdgeInsets.fromLTRB(16,4,16,4),
                title: "Actions",
                fontStyle: Theme.of(
                  context,
                ).textTheme.headlineMedium?.fontStyle,
                fontSize: Theme.of(
                  context,
                ).textTheme.headlineMedium?.fontSize,
                decorationStyle: Theme.of(
                  context,
                ).textTheme.displayMedium?.decorationStyle,
              ),
            ),
          ),
          PlatformListTile(
            leading: Icon(Icons.double_arrow_rounded),
            title: Text("Bu Oturumu Atla"),
            subtitle: Text(
              "Bu oturum şu an ${currentHabit.isSkippedOnDate(selectedDate) ? "atlanmış" : "atlanmamış"}",
            ),
            onTap: () {
              context.read<HabitProvider>().changeSkipOnDate(
                currentHabit.id,
                extraDate: selectedDate,
              );
            },
          ),

          PlatformListTile(
            leading: Icon(Icons.edit),
            title: Text("Bu Alışkanlığı Düzenle"),
            subtitle: Text("Mesela renk değiştirmeye ne dersin"),
            onTap: () {
              showResignOfHabit(context, currentHabit);
            },
          ),

          PlatformListTile(
            leading: Icon(Icons.share),
            title: Text("Bu Alışkanlığı Paylaş"),
            subtitle: Text("Ve ya fotosunu kaydet sana kalmış"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("valla şu an bunu geliştirmedik")),
              );
              showShareDetailSheet(context, currentHabit, selectedDate);
            },
          ),

          PlatformListTile(
            leading: Icon(Icons.delete),
            title: Text("Bu alışkanlığı Sil"),
            subtitle: Text("silmesen iyi olurdu ama ..."),
            onTap: () {
              showDialogOfDeleteHabit(context, currentHabit);
            },
          ),
        ],
      ),
    ),
  );
}
