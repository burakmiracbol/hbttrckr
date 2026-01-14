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
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:hbttrckr/classes/glasscard.dart';
import 'package:provider/provider.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

import '../classes/habit.dart';
import '../extensions/durationformatter.dart';
import '../providers/habitprovider.dart';
import '../views/mainappview.dart';

void detailSettingsSheet(
  BuildContext context,
  Habit currentHabit,
  DateTime selectedDate,
) {
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: false,
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Actions",
                          style: TextStyle(
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
                    ),
                  ],
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.double_arrow_rounded),
                  title: Text("Bu Oturumu Atla"),
                  subtitle: Text(
                    "Bu oturum şu an ${currentHabit.isSkippedOnDate(selectedDate ?? DateTime.now()) ? "atlanmış" : "atlanmamış"}",
                  ),
                  onTap: () {
                    context.read<HabitProvider>().changeSkipHabit(
                      currentHabit.id,
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text("Bu Alışkanlığı Düzenle"),
                  subtitle: Text("Mesela renk değiştirmeye ne dersin"),
                  onTap: () {
                    showResignOfHabit(
                      context,
                      currentHabit,
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text("Bu Alışkanlığı Paylaş"),
                  subtitle: Text("Ve ya fotosunu kaydet sana kalmış"),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("valla şu an bunu geliştirmedik")),
                    );
                    showShareDetailSheet(
                      context,
                      currentHabit,
                      selectedDate,
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text("Bu alışkanlığı Sil"),
                  subtitle: Text("silmesen iyi olurdu ama ..."),
                  onTap: () {
                    showDialogOfDeleteHabit(context, currentHabit);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void showDialogOfDeleteHabit (
    BuildContext context,
  Habit currentHabit,
    ){
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
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
              MaterialPageRoute(
                builder: (context) => MainAppView(),
              ),
                  (route) => false,
            );
          },
          child: Text(
            'Sil',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}

void showShareDetailSheet (
    BuildContext context,
  Habit currentHabit,
  DateTime selectedDate,
    ) {
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: false,
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (ctx, setStateSheet) => Padding(
        padding: EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: [
              Card(
                color: currentHabit.color.withValues(
                  alpha: 0.3,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: liquidGlassContainer(
                            context: context,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Icon(currentHabit.icon),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              liquidGlassContainer(context: context,child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0 , top: 4.0 , bottom: 4.0),
                                child: Text(currentHabit.name),
                              )),
                              liquidGlassContainer(context: context,child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0 , top: 4.0 , bottom: 4.0),
                                child: Text(currentHabit.description),
                              )),
                            ],
                          ),
                        ),
                        Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(Icons.health_and_safety),
                                Text(
                                  "Güç seviyesi ${currentHabit.strengthLevel}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(Icons.whatshot_rounded),
                                Text(
                                  "Streak ${currentHabit.currentStreak} gün",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons
                                          .keyboard_double_arrow_up,
                                    ),
                                    Text(
                                      "Güç seviyesi %${currentHabit.strength}",
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(
                                  currentHabit.type ==
                                      HabitType.task
                                      ? Icons.check
                                      : currentHabit.type ==
                                      HabitType.count
                                      ? Icons.add_box_rounded
                                      : currentHabit.type ==
                                      HabitType.time
                                      ? Icons.timer
                                      : Icons.question_mark,
                                ),
                                Text(
                                  "Tipi : ${currentHabit.type == HabitType.task
                                      ? "Görev"
                                      : currentHabit.type == HabitType.count
                                      ? "Sayılı"
                                      : currentHabit.type == HabitType.time
                                      ? "Süreli"
                                      : "Bilinmeyen"}",
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Icon(Icons.calendar_month),
                                Text(
                                  currentHabit.type == HabitType.task
                                      ? currentHabit.isCompletedOnDate(selectedDate)
                                      ? "Tamamlandı"
                                      : "Tamamlanmadı"
                                      : currentHabit.type == HabitType.count
                                      ? "${currentHabit.getCountProgressForDate(selectedDate)}"
                                      : currentHabit.type == HabitType.time
                                      ? "${currentHabit.getSecondsProgressForDate(selectedDate).formattedHMS}"
                                      : "Bilinmeyen",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


void showResignOfHabit (
    BuildContext context,
  Habit currentHabit,
    ) {
  final nameController = TextEditingController(
    text: currentHabit.name,
  );
  final descriptionController = TextEditingController(
    text: currentHabit.description,
  );
  Color selectedColor = currentHabit.color;
  Color tempColor = context
      .read<HabitProvider>()
      .getHabitById(currentHabit.id)
      .color;
  IconData selectedIcon = currentHabit.icon;
  TimeOfDay? selectedReminderTime = currentHabit.reminderTime;

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
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
                  decoration: InputDecoration(
                    labelText: 'İsim',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Açıklama',
                  ),
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
                                  pickerAreaHeightPercent:
                                  0.8,
                                ),
                              ),
                              actions: [
                                Padding(
                                  padding:
                                  const EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: TextButton(
                                    child: const Text(
                                      'İptal',
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(ctx),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.all(
                                    8.0,
                                  ),
                                  child: TextButton(
                                    child: const Text('Seç'),
                                    onPressed: () {
                                      setStateSheet(() {
                                        selectedColor =
                                            tempColor;
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
                    Text(
                      'Seçilen renk',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              // Icon Seçici
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    IconPickerIcon? icon =
                    await showIconPicker(
                      context,
                      configuration:
                      SinglePickerConfiguration(
                        iconPackModes: [
                          IconPack.material,
                        ],
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
                        ? selectedReminderTime!.format(
                      context,
                    )
                        : 'Ayarlanmamış',
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () async {
                    final TimeOfDay? picked =
                    await showTimePicker(
                      context: context,
                      initialTime:
                      selectedReminderTime ??
                          const TimeOfDay(
                            hour: 9,
                            minute: 0,
                          ),
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
                      final provider = context
                          .read<HabitProvider>();
                      final updatedHabit = provider
                          .getHabitById(currentHabit.id)
                          .copyWith(
                        name:
                        nameController.text
                            .trim()
                            .isNotEmpty
                            ? nameController.text.trim()
                            : provider
                            .getHabitById(
                          currentHabit.id,
                        )
                            .name,
                        description:
                        descriptionController.text
                            .trim()
                            .isNotEmpty
                            ? descriptionController.text
                            .trim()
                            : provider
                            .getHabitById(
                          currentHabit.id,
                        )
                            .description,
                        color: selectedColor,
                        icon: selectedIcon,
                        reminderTime:
                        selectedReminderTime,
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