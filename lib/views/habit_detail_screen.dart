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
import 'package:hbttrckr/data_types/habit.dart';
import 'package:hbttrckr/views/mainviews/main_app_view.dart';
import 'package:provider/provider.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import '../providers/style_provider.dart';
import 'habit_detail_screen_views.dart';

class HabitDetailScreen extends StatefulWidget {
  final bool isLiquid;
  final bool isFakeLiquid;
  final String habitId;
  final DateTime selectedDate;
  final bool isPanel;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
    required this.isLiquid,
    required this.isFakeLiquid,
    required this.selectedDate,
    this.isPanel = false,
    required this.onHabitUpdated,
    required this.onHabitDeleted,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late final currentHabit = Provider.of<HabitProvider>(
    context,
  ).getHabitById(widget.habitId);
  late final selectedDate = Provider.of<HabitProvider>(context).selectedDate;

  late String howManyDaysBeforeCreated =
      "${DateTime.now().difference(currentHabit.createdAt).inDays + 1}";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, child) {
        final currentHabit = provider.getHabitById(widget.habitId);


        if (widget.isPanel) {
          return Material(
            color: Colors.transparent,
            child: buildContent(
              currentHabit,
              context,
              widget.isLiquid,
              widget.isFakeLiquid,
            ),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 30));
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            primary: true,
            extendBody: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Icon(currentHabit.icon, color: currentHabit.color),
                  const SizedBox(width: 12),
                  Text(
                    currentHabit.name,
                    style: TextStyle(
                      color: currentHabit.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: buildContent(
              currentHabit,
              context,
              widget.isLiquid,
              widget.isFakeLiquid,
            ),
          ),
        );
      },
    );
  }

  Widget buildContent(
    Habit currentHabit,
    BuildContext context,
    bool isLiquid,
    bool isFakeLiquid,
  ) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: context.watch<StyleProvider>().getFulscreenForNow() == false
          ? HabitDetailScreenNormal(
              habitId: currentHabit.id,
              isLiquid: isLiquid,
              isFakeLiquid: isFakeLiquid,
              selectedDate: selectedDate ?? DateTime.now(),
              onHabitUpdated: widget.onHabitUpdated,
              onHabitDeleted: widget.onHabitDeleted,
              currentHabit: currentHabit,
              howManyDaysBeforeCreated: howManyDaysBeforeCreated,
            )
          : HabitDetailScreenFullscreen(
              isLiquid: isLiquid,
              isFakeLiquid: isFakeLiquid,
              habitId: currentHabit.id,
              selectedDate: selectedDate ?? DateTime.now(),
              currentHabit: currentHabit,
              howManyDaysBeforeCreated: howManyDaysBeforeCreated,
              onHabitUpdated: widget.onHabitUpdated,
              onHabitDeleted: widget.onHabitDeleted,
            ),
    );
  }
}
