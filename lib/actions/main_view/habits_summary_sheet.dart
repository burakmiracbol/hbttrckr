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
import 'package:provider/provider.dart';
import '../../classes/glass_card.dart';
import '../../providers/habit_provider.dart';
import '../../providers/scheme_provider.dart';

void showHabitsSummarySheet (
    BuildContext context
    ){
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7, // başlangıçta ekranın %50'si
      minChildSize: 0.25,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: [
              glassContainer(context: context,
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0 ,bottom:8.0, left: 16.0, right: 16.0),
                  child: Text(
                    "Tüm Alışkanlıklar",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Column(
                children: [
                  ...context.watch<HabitProvider>().habits.map(
                        (h) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Card(
                        color:
                        context
                            .watch<CurrentThemeMode>()
                            .isMica
                            ? Theme.of(context).cardColor
                            : Theme.of(context).cardColor
                            .withValues(alpha: 0.2),
                        elevation: 3,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: context.read<HabitProvider>().getMixedColor(h.id).withValues(alpha: 0.8),
                            child: Icon(
                              h.icon,
                            ),
                          ),
                          title: Text(h.name),
                          subtitle: Text(
                            "${h.currentStreak} gün streak • ${h.strength}% güç",
                          ),
                          trailing: h.currentStreak > 0
                              ? Icon(
                            Icons.local_fire_department,
                            color: context.read<HabitProvider>().getMixedColor(h.id),
                          )
                              : const Icon(
                            Icons
                                .local_fire_department_outlined,
                            color: Colors.grey,
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
  );
}