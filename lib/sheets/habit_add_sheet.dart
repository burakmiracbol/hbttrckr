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
import 'package:wheel_slider/wheel_slider.dart';

import '../classes/habit.dart';

// Sık kullanılan Material Icons'ın custom map'i


class AddHabitSheet extends StatefulWidget {
  final Function({
  required String name,
  String description,
  String? group,
  required Color color,
  required HabitType type,
  required IconData icon,
  double? targetCount,
  double? maxCount,
  double? targetSeconds,
  TimeOfDay? reminderTime,
  Set<int>? reminderDays,
  })
  onAdd;

  const AddHabitSheet({Key? key, required this.onAdd}) : super(key: key);

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final _groupController = TextEditingController();
  final _countController = TextEditingController();
  final _maxCountController = TextEditingController();

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
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapat + Başlık
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'New Habit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 48),
              ],
            ),
            SizedBox(height: 20),

            // Habit Name
            TextField(
              controller: _nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Habit name',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            SizedBox(height: 16),

            // Description
            TextField(
              controller: _descController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            SizedBox(height: 16),

            TextField(
              controller: _groupController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Group (optional)',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            SizedBox(height: 16),

            ElevatedButton.icon(
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
              icon: Icon(currentIconOfHabit),
              label: Text('Icon Seç'),
            ),
            SizedBox(height: 24),

            // Habit Type
            Text(
              'Tür',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            DropdownButton<HabitType>(
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
            SizedBox(height: 16),

            // Target (Count / Time)
            if (_selectedType == HabitType.count)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Hedef sayı (örn: 10)',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _maxCountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'maximum sayı',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[900],
                    ),
                  ),
                ],
              ),

            if (_selectedType == HabitType.time)
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // SAAT
                    Expanded(
                      child: WheelSlider.number(
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

            SizedBox(height: 24),

            // Reminder
            Text(
              'Reminder',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time', style: TextStyle(color: Colors.white70)),
                TextButton(
                  onPressed: selectTime,
                  child: Text(
                    _selectedTime.format(context),
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Days
            Text(
              'Days',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
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
                      selected ? _selectedDays.add(i) : _selectedDays.remove(i);
                    });
                  },
                  selectedColor: Colors.blue[600],
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey[800],
                );
              }),
            ),
            SizedBox(height: 24),

            // Color Picker
            Text(
              'Renk seç',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
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
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: tempColor,
                            onColorChanged: (color) => tempColor = color,
                            labelTypes: [],
                            pickerAreaHeightPercent: 0.8,
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
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      shape: BoxShape.rectangle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Icon(Icons.color_lens, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Seçilen renk',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
            SizedBox(height: 24),

            // SAVE BUTONU
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue[700],
                ),
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
                      group: _groupController.text.toString() == "" ? null : _groupController.text.trim(),
                      color: _selectedColor,
                      type: _selectedType,
                      icon: currentIconOfHabit,
                      targetCount: _selectedType == HabitType.count
                          ? double.tryParse(_countController.text)
                          : null,
                      maxCount: _selectedType == HabitType.count
                          ? double.tryParse(_maxCountController.text)
                          : null,
                      targetSeconds: _selectedType == HabitType.time
                          ? _totalSeconds.toDouble()
                          : null,
                      reminderTime: _selectedTime,
                      reminderDays: _selectedDays.isEmpty ? null : _selectedDays,
                    );
                    // Navigator.pop() çağrısını kaldır - mainappview'da zaten çağrılıyor
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Hata oluştu: $e')),
                    );
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
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
