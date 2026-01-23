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

  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
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
          child: StatefulBuilder(
            builder: (context, setStateSheet) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Alışkanlığı Düzenle",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.fontSize,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: 'İsim'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Açıklama'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: groupController,
                        decoration: InputDecoration(labelText: 'Grup'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                border: Border.all(
                                  color: Colors.black,
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                Icons.color_lens,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Seçilen renk', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    // Icon Seçici
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
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
                        icon: Icon(selectedIcon),
                        label: Text('İcon Seç'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
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
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final provider = context.read<HabitProvider>();
                            final updatedHabit = provider
                                .getHabitById(currentHabit.id)
                                .copyWith(
                              name: nameController.text.trim().isNotEmpty
                                  ? nameController.text.trim()
                                  : provider
                                  .getHabitById(currentHabit.id)
                                  .name,
                              description:
                              descriptionController.text
                                  .trim()
                                  .isNotEmpty
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
        ),
      ),
    ),
  );
}