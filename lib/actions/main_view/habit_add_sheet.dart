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
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:wheel_slider/wheel_slider.dart';
import '../../classes/all_widgets.dart';
import '../../classes/habit.dart';
import '../../providers/habit_provider.dart';

// Sık kullanılan Material Icons'ın custom map'i

void showAddHabitSheet(BuildContext parentContext) {
  showPlatformModalSheet(
    context: parentContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => AddHabitSheet(
      onAdd:
          ({
            required String name,
            String description = '',
            String? group,
            required Color color,
            required HabitType type,
            required IconData icon,
            double? targetCount,
            double? targetSeconds,
            TimeOfDay? reminderTime,
            Set<int>? reminderDays,
          }) {
            parentContext.read<HabitProvider>().addHabit(
              name: name,
              description: description,
              group: group,
              color: color,
              type: type,
              targetCount: targetCount,
              targetSeconds: targetSeconds?.toDouble(),
              reminderTime: reminderTime,
              reminderDays: reminderDays,
              icon: icon,
            );

            Navigator.pop(sheetContext);
          },
    ),
  );
}

class AddHabitSheet extends StatefulWidget {
  final Function({
    required String name,
    String description,
    String? group,
    required Color color,
    required HabitType type,
    required IconData icon,
    double? targetCount,
    double? targetSeconds,
    TimeOfDay? reminderTime,
    Set<int>? reminderDays,
  })
  onAdd;

  const AddHabitSheet({super.key, required this.onAdd});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _groupController = TextEditingController();
  final _countController = TextEditingController();

  late IconData currentIconOfHabit;

  TimeOfDay _selectedTime = TimeOfDay.now();
  Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Pazartesi-Cuma
  Color _selectedColor = Colors.blue;
  HabitType _selectedType = HabitType.task;

  // --- Taşınan state alanları (değişiklik burası) ---
  int _currentHours = 0;
  int _currentMinutes = 0;
  int _currentSeconds = 0;
  int _totalSeconds = 0;
  // ---------------------------------------------------

  final List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  void initState() {
    super.initState();
    currentIconOfHabit = Icons.favorite; // IconData'yı initialize et
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapat + Başlık
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 8.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: PlatformTitle(
                        fontSize: Theme.of(context,).textTheme.headlineSmall!.fontSize,
                        title: 'New Habit',
                        padding: EdgeInsets.fromLTRB(16,2,16,2)
                    ),
                  ),
                ),
              ),
            ),

            // Habit Name
            PlatformTextField(
              controller: _nameController,
              hintText: 'Habit name',
            ),

            // Description
            PlatformTextField(
              controller: _descController,
              hintText: 'Description',
            ),

            PlatformTextField(
              controller: _groupController,
              hintText: 'Group (optional)',
            ),

            Center(
              child: PlatformButton(
                onPressed: () async {
                  IconPickerIcon? icon = await showIconPicker(
                    context,
                    configuration: SinglePickerConfiguration(
                      iconPackModes: [IconPack.material],
                    ),
                  );

                  if (icon != null) {
                    setState(() {
                      currentIconOfHabit = icon.data;
                    });
                  }
                },
                child: Text('Icon Seç'),
              ),
            ),

            // Habit Type
            PlatformListTile(
              title: Text("Alışkanlığın Türünü Seçin"),
              onTap: () {},
              trailing: DropdownButton<HabitType>(
                value: _selectedType,
                dropdownColor: Colors.grey[900],
                style: TextStyle(color: Colors.white),
                items: HabitType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
            ),

            // Target (Count / Time)
            if (_selectedType == HabitType.count)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PlatformTextField(
                    controller: _countController,
                    // keyboardType: TextInputType.number,
                    hintText: 'Hedef sayı (örn: 10)',
                  ),
                ],
              ),

            if (_selectedType == HabitType.time)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SAAT
                    Expanded(
                      child: WheelSlider.number(
                        perspective: 0.009,
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 24,
                        initValue: _currentHours,
                        currentIndex: _currentHours,
                        onValueChanged: (val) {
                          setState(() {
                            _currentHours = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                        selectedNumberStyle: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                        unSelectedNumberStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    // DAKİKA
                    Expanded(
                      child: WheelSlider.number(
                        perspective: 0.009,
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 60,
                        initValue: _currentMinutes,
                        currentIndex: _currentMinutes,
                        onValueChanged: (val) {
                          setState(() {
                            _currentMinutes = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                      ),
                    ),
                    // SANİYE
                    Expanded(
                      child: WheelSlider.number(
                        perspective: 0.009,
                        verticalListHeight:
                            MediaQuery.of(context).size.height * 0.3,
                        horizontal: false,
                        totalCount: 60,
                        initValue: _currentSeconds,
                        currentIndex: _currentSeconds,
                        onValueChanged: (val) {
                          setState(() {
                            _currentSeconds = val.toInt();
                            _totalSeconds =
                                (_currentHours * 3600) +
                                (_currentMinutes * 60) +
                                _currentSeconds;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Reminder Time
            PlatformListTile(
              title: Text(
                'Reminder Time',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: TextButton(
                onPressed: selectTime,
                child: Text(
                  _selectedTime.format(context),
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              onTap: () {},
            ),

            // Reminder Days
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Center(
                child: Column(
                  spacing: 10,
                  children: [
                    Center(
                      child: Text(
                        'Reminder Days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (i) {
                        return FilterChip(
                          label: Text(
                            dayNames[i],
                            style: TextStyle(color: Colors.white),
                          ),
                          selected: _selectedDays.contains(i),
                          onSelected: (selected) {
                            setState(() {
                              selected
                                  ? _selectedDays.add(i)
                                  : _selectedDays.remove(i);
                            });
                          },
                          selectedColor: Colors.blue[600],
                          checkmarkColor: Colors.white,
                          backgroundColor: Colors.grey[800],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // Color Picker
            PlatformListTile(
              leading: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(Icons.color_lens, color: Colors.white),
              ),
              title: Text(
                'Renk seç',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Color tempColor = _selectedColor;
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: Text(
                      'Renk Seç',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: IntrinsicWidth(
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ColorPicker(
                                hexInputBar: true,
                                pickerColor: tempColor,
                                onColorChanged: (color) => tempColor = color,
                                labelTypes: [],
                                pickerAreaHeightPercent: 0.8,
                                portraitOnly: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          'İptal',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      TextButton(
                        child: Text(
                          'Seç',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () {
                          setState(() => _selectedColor = tempColor);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            // SAVE BUTONU
            SizedBox(
              width: double.infinity,
              child: PlatformButton(
                onPressed: () {
                  if (_nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Habit name gerekli!')),
                    );
                    return;
                  }

                  try {
                    widget.onAdd(
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      group: _groupController.text.toString() == ""
                          ? null
                          : _groupController.text.trim(),
                      color: _selectedColor,
                      type: _selectedType,
                      icon: currentIconOfHabit,
                      targetCount: _selectedType == HabitType.count
                          ? double.tryParse(_countController.text)
                          : null,
                      targetSeconds: _selectedType == HabitType.time
                          ? _totalSeconds.toDouble()
                          : null,
                      reminderTime: _selectedTime,
                      reminderDays: _selectedDays.isEmpty
                          ? null
                          : _selectedDays,
                    );
                    // Navigator.pop() çağrısını kaldır - mainappview'da zaten çağrılıyor
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
                  }
                },
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
