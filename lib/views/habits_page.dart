import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:hbttrckr/views/mainappview.dart';

// TODO : calendarda task türünden yapılanları işaretliyor diğer türleri değil
// TODO : calendar habitlerin hangi günde olduğunu biliyor ama hangi günde ne kadar bittiğini bilmiyor

Widget buildHabitsPage({
  required List<Habit> habits,
  required OnHabitTapped onHabitTapped, // tıklama
  required OnHabitUpdated onHabitUpdated,
  required OnHabitDeleted? onHabitDeleted,
  required Function(DateTime) onDateSelected,
}) {
  if (habits.isEmpty) {
    return Center(
      child: Text(
        'Henüz alışkanlık eklemedin.\n+ butonuna bas!',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  return Consumer<HabitProvider>(
      builder: (context, provider, child) { // BU CONTEXT DOĞRU!
        final selectedDate = provider.selectedDate ?? DateTime.now();
        return LiquidGlassLayer(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay:
                    Provider
                        .of<HabitProvider>(context)
                        .selectedDate ??
                        DateTime.now(),
                    // provider’daki tarih
                    selectedDayPredicate: (day) =>
                        isSameDay(Provider
                            .of<HabitProvider>(context)
                            .selectedDate, day),
                    calendarFormat: CalendarFormat.week,
                    // ← HAFTALIK GÖRÜNÜM!
                    startingDayOfWeek: StartingDayOfWeek.sunday,
          
                    headerVisible: false,
                    // "Today" yazısını kaldırdık
                    daysOfWeekHeight: 50,
                    rowHeight: 76,
          
                    // GÜN BAŞLIKLARI (Sun, Mon, Tue...)
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.white70, fontSize: 12),
                      weekendStyle: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
          
                    // SEÇİLEN GÜN
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(),
                      todayTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.pinkAccent.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          
                    // GÜN ÜZERİNDEKİ NOKTALAR (tamamlanan alışkanlık varsa)
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final completedCount = Provider.of<HabitProvider>(
                          context,
                        ).getCompletedCountForDay(date); // TODO: what the fuck is that we already have function to use but what is that because that we only get tasks
                        if (completedCount > 0) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  completedCount.clamp(0, 4),
                                      (index) =>
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1.5),
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          color: index < 3 ? Colors.cyan : Colors
                                              .orange,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                          );
                        }
                        return null;
                      },
                    ),
          
                    // TARİH DEĞİŞİNCE
                    onDaySelected: (selectedDay, focusedDay) {
                      context.read<HabitProvider>().setSelectedDate(selectedDay);
                      print("Tıklanan gün: $selectedDay"); // bunu ekle, konsola baksın
                    },
          
                    onPageChanged: (focusedDay) {
                      context.read<HabitProvider>().setSelectedDate(focusedDay);
                      print("Kaydırılan gün: $focusedDay");
                    },
                  ),
          
                ),
              ),
          
              Expanded(
                child: Consumer<HabitProvider>(
                  builder: (context, provider, child) {
                    final selectedDate = provider.selectedDate ?? DateTime.now();
                    final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                    final visibleHabits = habits.where((habit) {
                      final createdDate = DateTime(habit.createdAt.year, habit.createdAt.month, habit.createdAt.day);
                      return !createdDate.isAfter(normalizedDate);
                    }).toList();
                    return ListView.builder(
                      // TODO : istoolate de olsun habiti yedi gün önce ise düzenleme olmasın
                      padding: EdgeInsets.all(16),
                      itemCount: visibleHabits.length,
                      itemBuilder: (context, index) {
                        final habit = visibleHabits[index];
                        final normalizedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                        final today = DateTime.now();
                        final todayNormalized = DateTime(today.year, today.month, today.day);
                        final isFuture = normalizedDate.isAfter(todayNormalized);
                        DateTime sevenDaysAgo = todayNormalized.subtract(const Duration(days: 7));
                        bool isTooLate = selectedDate.isBefore(sevenDaysAgo);
                        final isCompleted = habit.completedDates.any((d) =>
                        d.year == normalizedDate.year &&
                            d.month == normalizedDate.month &&
                            d.day == normalizedDate.day);
                        return Card(
                          color: habit.color.withValues(alpha: 0.2),
                          child: ListTile(
                            onTap: () => onHabitTapped(habit),
                            // sadece tıklama bildir
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (ctx) =>
                                    AlertDialog(
                                      title: Text('Silinsin mi?'),
                                      content: Text(
                                        '${habit
                                            .name} alışkanlığını silmek istediğinden emin misin?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: Text('İptal'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // ANA EKRANA SİLME TALİMATI GÖNDER
                                            context
                                                .read<HabitProvider>()
                                                .deleteHabit(
                                              habit.id,
                                            ); // yukarı tanımlayacak
                                            Navigator.pop(ctx);
                                          },
                                          child: Text(
                                            'Sil',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            leading: CircleAvatar(backgroundColor: habit.color),
                            title: Text(
                              habit.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(isFuture || isTooLate ? "Yapılacak" :
                              habit.type == HabitType.task
                                  ? (habit.isCompletedToday()
                                  ? 'Tamamlandı'
                                  : 'Yapılmadı')
                                  : habit.type == HabitType.count
                                  ? '${habit.todayCountProgress} / ${habit
                                  .targetCount ?? '?'}'
                                  : habit.type == HabitType.time
                                  ? '${habit.todaySecondsProgress.formattedHMS} / ${habit.targetSeconds.formattedHMS} '
                                  : habit.isCompletedToday()
                                  ? 'Tamamlandı'
                                  : 'Yapılmadı',
                            ),
                            trailing: isFuture || isTooLate ? habit.type == HabitType.task
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:  Colors.grey,
                              ),
                              icon: Icon( Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {
                              },
                            )
                                : habit.type == HabitType.count
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: Colors.grey,
                              ),
                              icon: Icon( Icons.add_outlined,
                                size: 25,
                              ),
                              onPressed: () {
                              },
                            )
                                : habit.type == HabitType.time
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:  Colors.grey,
                              ),
                              icon: Icon( Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {},
                            )
                                : IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor:  Colors.grey,
                              ),
                              icon: Icon( Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {},
                            )
                                : habit.type == HabitType.task
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: habit.isCompletedToday()
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              icon: Icon(
                                habit.isCompletedToday()
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {
                                context
                                    .read<HabitProvider>()
                                    .toggleTaskCompletion(habit.id);
                              },
                            )
                                : habit.type == HabitType.count
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: habit.isCompletedToday()
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              icon: Icon(
                                habit.isCompletedToday()
                                    ? Icons.add
                                    : Icons.add_outlined,
                                size: 25,
                              ),
                              onPressed: () {
                                context.read<HabitProvider>().incrementCount(
                                  habit.id,
                                );
                              },
                            )
                                : habit.type == HabitType.time
                                ? IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: habit.isCompletedToday()
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              icon: Icon(
                                habit.isCompletedToday()
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {},
                            )
                                : IconButton(
                              style: IconButton.styleFrom(
                                foregroundColor: habit.isCompletedToday()
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              icon: Icon(
                                habit.isCompletedToday()
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 25,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }
  );
}
