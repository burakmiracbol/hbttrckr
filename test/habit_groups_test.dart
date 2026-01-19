import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/providers/habitprovider.dart';

Habit _buildHabit({
  required String id,
  required String name,
  String? group,
}) {
  return Habit(
    id: id,
    name: name,
    description: '',
    group: group,
    color: Colors.blue,
    createdAt: DateTime(2026, 1, 1),
    type: HabitType.task,
    icon: Icons.favorite,
    achievedCount: 0,
  );
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('clears selected group when a habit loses its group', () {
    final provider = HabitProvider(enableNotifications: false);
    final habit = _buildHabit(id: '1', name: 'Read', group: 'Health');
    provider.addHabitFromObject(habit);
    provider.addHabitFromObject(
      _buildHabit(id: '2', name: 'Run', group: 'Fitness'),
    );

    provider.selectedGroup = 'Health';

    provider.updateHabit(habit.copyWith(group: null));

    expect(provider.getGroupToView(), isNull);
  });

  test('clears selected group when last habit in group is deleted', () async {
    final provider = HabitProvider(enableNotifications: false);
    final habit = _buildHabit(id: '1', name: 'Meditate', group: 'Mind');
    provider.addHabitFromObject(habit);

    provider.selectedGroup = 'Mind';

    await provider.deleteHabit(habit.id);

    expect(provider.getGroupToView(), isNull);
  });

  test('unique groups are returned in stable alphabetical order', () {
    final provider = HabitProvider(enableNotifications: false);
    final habits = [
      _buildHabit(id: '1', name: 'B', group: 'Beta'),
      _buildHabit(id: '2', name: 'A', group: 'Alpha'),
      _buildHabit(id: '3', name: 'C', group: 'Alpha'),
    ];

    final groups = provider.getUniqueGroupNames(habits);

    expect(groups.map((group) => group).toList(), ['Alpha', 'Beta']);
  });
}