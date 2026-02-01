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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';
import '../../classes/all_widgets.dart';
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';

void showResignOfHabit(BuildContext context, Habit currentHabit) {
  final nameController = TextEditingController(text: currentHabit.name);
  final descriptionController = TextEditingController(
    text: currentHabit.description,
  );
  final groupController = TextEditingController(text: currentHabit.group);
  Color selectedColor = currentHabit.color;
  Color tempColor = context
      .read<HabitProvider>()
      .getHabitById(currentHabit.id)
      .color;
  IconData selectedIcon = currentHabit.icon;
  TimeOfDay? selectedReminderTime = currentHabit.reminderTime;

  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setStateSheet) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PlatformTitle(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  title: "Alışkanlığı Düzenle",
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.fontSize,
                ),
              ),

              PlatformTextField(
                controller: nameController,
                //labelText: 'İsim',
                hintText: 'İsim',
                //prefixIcon: const Icon(Icons.title),
              ),
              PlatformTextField(
                controller: descriptionController,
                //decoration: InputDecoration(labelText: 'Açıklama'),
                hintText: 'Açıklama',
              ),
              PlatformTextField(
                controller: groupController,
                //decoration: InputDecoration(labelText: 'Grup'),
                hintText: 'Grup',
              ),

              PlatformListTile(
              title:
                  IntrinsicWidth(
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text('Renk Seç'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: tempColor,
                                      onColorChanged: (color) {
                                        tempColor = color;
                                      },
                                      pickerAreaHeightPercent: 0.8,
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        child: const Text('İptal'),
                                        onPressed: () => Navigator.pop(ctx),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TextButton(
                                        child: const Text('Seç'),
                                        onPressed: () {
                                          setStateSheet(() {
                                            selectedColor = tempColor;
                                          });
                                          Navigator.pop(ctx);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: selectedColor,
                              shape: BoxShape.rectangle,
                              border: Border.all(color: Colors.black, width: 3),
                            ),
                            child: Icon(Icons.color_lens, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Seçilen renk', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  trailing: PlatformButton(
                    onPressed: () async {
                      IconPickerIcon? icon = await showIconPicker(
                        context,
                        configuration: SinglePickerConfiguration(
                          iconPackModes: [IconPack.material],
                        ),
                      );

                      if (icon != null) {
                        setStateSheet(() {
                          selectedIcon = icon.data;
                        });
                      }
                    },
                    child: IntrinsicWidth(
                      child: Row(
                        children: [Icon(selectedIcon), Text('İcon Seç')],
                      ),
                    ),
                  ),
                onTap: () {},
              ),

              // Icon Seçici
              PlatformListTile(
                leading: Icon(Icons.notifications),
                title: Text("Hatırlatma Saati"),
                subtitle: Text(
                  selectedReminderTime != null
                      ? selectedReminderTime!.format(context)
                      : 'Ayarlanmamış',
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime:
                        selectedReminderTime ??
                        const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) {
                    setStateSheet(() {
                      selectedReminderTime = picked;
                    });
                  }
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PlatformButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('İptal'),
                  ),
                  PlatformButton(
                    onPressed: () async {
                      final provider = context.read<HabitProvider>();
                      final updatedHabit = provider
                          .getHabitById(currentHabit.id)
                          .copyWith(
                            name: nameController.text.trim().isNotEmpty
                                ? nameController.text.trim()
                                : provider.getHabitById(currentHabit.id).name,
                            description:
                                descriptionController.text.trim().isNotEmpty
                                ? descriptionController.text.trim()
                                : provider
                                      .getHabitById(currentHabit.id)
                                      .description,
                            group: groupController.text == ""
                                ? null
                                : groupController.text,
                            color: selectedColor,
                            icon: selectedIcon,
                            reminderTime: selectedReminderTime,
                          );

                      provider.updateHabit(updatedHabit);

                      Navigator.pop(ctx);
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
