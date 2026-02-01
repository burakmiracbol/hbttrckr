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
import 'package:provider/provider.dart';
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';
import '../../views/main_app_view.dart';

void showDialogOfDeleteHabit(BuildContext context, Habit currentHabit) {
  showDialog(
    context: context,
    builder: (ctx) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(64)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(64)),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.2,
              ), // İnce ışık yansıması (kenarlık)
              width: 1.5,
            ),
          ),
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            title: Text('Alışkanlığı Sil'),
            content: Text(
              '"${currentHabit.name}" alışkanlığını silmek istediğine emin misin?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<HabitProvider>().deleteHabit(
                    currentHabit.id,
                  );

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MainAppView()),
                    (route) => false,
                  );
                },
                child: Text('Sil', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
