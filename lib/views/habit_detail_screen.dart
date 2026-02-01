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
import 'package:hbttrckr/classes/strength_gauge.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/views/main_app_view.dart';
import 'package:hbttrckr/actions/detail_screen/settings_sheet.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hbttrckr/providers/habit_provider.dart';
import 'package:hbttrckr/actions/detail_screen/notes_editor_sheet.dart';
import '../classes/all_widgets.dart';
import '../classes/stats_card.dart';
import '../extensions/duration_formatter.dart';
import '../actions/detail_screen/count_selector_sheet.dart';
import '../actions/detail_screen/time_selector_sheet.dart';

// TODO ERROR : düzenleme oluyor iki iptal tuşu var

// TODO : habitlerde kategorilendirme yapılacak ve ana ekranda ona göre bakma olacak

// TODO : lottie fire . json çalışmıyor ona bak pubspec.yaml dosyasında assets kısmını açtım bir daha bak o şekil dene

// TODO : time ve count selector tasarım
// TODO : time selctor sheet için time saklama biçimini saniyeye çevirdik bu yüzden dakika ile yapılan çoğu metodu düzeltmek lazım
// TODO : mesela habit içinden erişilebilen ve habit içinde kullanılan bir saat ve dakika ve saniye bölme yaparız işlemleri ona göre düzenleriz

// TODO : calendarda ileri gidince habit değerleri gözukmesin ve geri gidince eski günlerin yapılmış değerleri görüntülene bilsin ve beş gün önceki değerler değiştirilemesin

// TODO : Her habit detail screende kendi calendar istatistikleri ve sıralama istatistikleri olsun current streak best streak total sessions done sessions missed sessions skipped sessions planned hours counted hours missed hours
// TODO : succes rate grafiği done missed skipped calendr istatistikleri haftalık süre sayı veya yaptı yapmadı grafiği ve aylık done missed skipped grafiği

// TODO: Appbar veya calendar gibi bir widget ın rengini tüm habitlerin renginin karışımım belirlesin #özellik

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  final DateTime selectedDate;
  final OnHabitUpdated onHabitUpdated;
  final OnHabitDeleted? onHabitDeleted;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
    required this.selectedDate,
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
        return PopScope(
          canPop: false, // Pop işlemini biz yöneteceğiz
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;

            // Yeni yaklaşım:
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 30));

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            primary: false,
            extendBody: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: Row(
                children: [
                  Icon(currentHabit.icon, color: currentHabit.color),
                  SizedBox(width: 12),
                  Text(
                    currentHabit.name,
                    style: TextStyle(
                      color: currentHabit.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [],
            ),
            body: SingleChildScrollView(
              child: GlassGlowLayer(
                child: LiquidGlassLayer(
                  child: GlassGlow(
                    child: Stack(
                      children: [
                        Positioned(
                          top:
                              MediaQuery.of(context).size.width *
                              -0.5, // üstten ne kadar taşacak (negatif = yukarı taşır)
                          left:
                              MediaQuery.of(context).size.width *
                              -0.2, // soldan taşma
                          right:
                              MediaQuery.of(context).size.width *
                              -0.2, // sağdan taşma
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1.2,
                            height: MediaQuery.of(context).size.width * 1.2,
                            decoration: BoxDecoration(
                              color: currentHabit.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    LiquidGlass(
                                      shape: LiquidRoundedRectangle(
                                        borderRadius: 160,
                                      ),
                                      child: GlassGlow(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            18,
                                            6,
                                            18,
                                            8,
                                          ),
                                          child: IntrinsicWidth(
                                            child: Center(
                                              child: Text(
                                                currentHabit.group ?? "grupsuz",
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontSize: 15,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: LiquidGlass(
                                          shape: LiquidOval(),
                                          child: GlassGlow(
                                            child: CircleAvatar(
                                              radius: 50,
                                              backgroundColor: currentHabit
                                                  .color
                                                  .withValues(alpha: 0.3),
                                              child: Icon(
                                                currentHabit.icon,
                                                size: 50,
                                                color: currentHabit.color,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Stack(
                                  children: [
                                    Center(
                                      child: Card(
                                        color: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: IntrinsicHeight(
                                          child: IntrinsicWidth(
                                            child: LiquidGlass(
                                              shape: LiquidRoundedRectangle(
                                                borderRadius: 320,
                                              ),
                                              child: GlassGlow(
                                                child: Card(
                                                  color: Colors.transparent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          160,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                              4,
                                                              2,
                                                              4,
                                                              2,
                                                            ),
                                                        child: LiquidGlass(
                                                          shape: LiquidOval(),
                                                          child: GlassGlow(
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .note_alt_outlined,
                                                              ),
                                                              onPressed: () async {
                                                                final provider =
                                                                    context
                                                                        .read<
                                                                          HabitProvider
                                                                        >();
                                                                final current = provider
                                                                    .getHabitById(
                                                                      currentHabit
                                                                          .id,
                                                                    );
                                                                final result =
                                                                    await showNotesEditorSheet(
                                                                      context,
                                                                      current,
                                                                    );

                                                                if (result !=
                                                                    null) {
                                                                  final updated =
                                                                      current.copyWith(
                                                                        notesDelta:
                                                                            result,
                                                                      );
                                                                  provider
                                                                      .updateHabit(
                                                                        updated,
                                                                      );
                                                                  widget
                                                                      .onHabitUpdated
                                                                      .call(
                                                                        updated,
                                                                      );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                              26,
                                                              0,
                                                              26,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          currentHabit.name,
                                                          style: TextStyle(
                                                            fontSize: 32,
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ),
                                                      ),

                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                              4,
                                                              2,
                                                              4,
                                                              2,
                                                            ),
                                                        child: LiquidGlass(
                                                          shape: LiquidOval(),
                                                          child: GlassGlow(
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .format_list_bulleted_rounded,
                                                              ),
                                                              onPressed: () {
                                                                detailSettingsSheet(
                                                                  context,
                                                                  currentHabit,
                                                                  selectedDate ??
                                                                      DateTime.now(),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          0,
                                          8,
                                          0,
                                        ),
                                        child: LiquidGlass(
                                          shape: LiquidRoundedRectangle(
                                            borderRadius: 160,
                                          ),
                                          child: GlassGlow(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                6.0,
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                  left: 18.0,
                                                  right: 18.0,
                                                  bottom: 4.0,
                                                ),
                                                child: Text(
                                                  currentHabit.name,
                                                  style: TextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 320,
                                    ),
                                    child: GlassGlow(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          30,
                                          10,
                                          30,
                                          10,
                                        ),
                                        child: Column(
                                          spacing: 8,
                                          children: [
                                            LiquidGlass(
                                              shape: LiquidRoundedRectangle(
                                                borderRadius: 16,
                                              ),
                                              child: GlassGlow(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                  ),
                                                  child: Text(
                                                    currentHabit.description,
                                                    style: TextStyle(
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      fontSize: 18,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            LiquidGlass(
                                              shape: LiquidRoundedRectangle(
                                                borderRadius: 16,
                                              ),
                                              child: GlassGlow(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: 8.0,
                                                    right: 8.0,
                                                  ),
                                                  child: Text(
                                                    'Toplam $howManyDaysBeforeCreated gün önce oluşturuldu',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IntrinsicHeight(
                                    child: IntrinsicWidth(
                                      child: LiquidGlass(
                                        shape: LiquidRoundedRectangle(
                                          borderRadius: 64,
                                        ),
                                        child: GlassGlow(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                              12.0,
                                              8.0,
                                              12.0,
                                              8.0,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // TASK
                                                if (currentHabit.type ==
                                                    HabitType.task)
                                                  currentHabit.isSkippedOnDate(
                                                        selectedDate ??
                                                            DateTime.now(),
                                                      )
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  4.0,
                                                                ),
                                                            child: IconButton(
                                                              onPressed: () {},
                                                              icon: Icon(
                                                                Icons.skip_next,
                                                              ),
                                                              style: IconButton.styleFrom(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      10,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                4.0,
                                                              ),
                                                          child: IconButton(
                                                            onPressed: () => context
                                                                .read<
                                                                  HabitProvider
                                                                >()
                                                                .toggleTaskCompletion(
                                                                  currentHabit
                                                                      .id,
                                                                ),
                                                            icon:
                                                                currentHabit.isCompletedOnDate(
                                                                  selectedDate ??
                                                                      DateTime.now(),
                                                                )
                                                                ? const Icon(
                                                                    Icons.done,
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : const Icon(
                                                                    Icons
                                                                        .circle_outlined,
                                                                  ),
                                                            style: IconButton.styleFrom(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    10,
                                                                  ),
                                                            ),
                                                          ),
                                                        )
                                                // COUNT
                                                else if (currentHabit.type ==
                                                    HabitType.count)
                                                  currentHabit.isSkippedOnDate(
                                                        selectedDate ??
                                                            DateTime.now(),
                                                      )
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: LiquidGlass(
                                                            shape:
                                                                LiquidRoundedRectangle(
                                                                  borderRadius:
                                                                      16,
                                                                ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    4.0,
                                                                  ),
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      currentHabit
                                                                          .color
                                                                          .withValues(
                                                                            alpha:
                                                                                0.2,
                                                                          ),
                                                                  shape:
                                                                      const StadiumBorder(),
                                                                ),
                                                                onPressed:
                                                                    () {},
                                                                child: Text(
                                                                  "Atlandı",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : IntrinsicHeight(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      4.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape:
                                                                      LiquidOval(),
                                                                  child: AspectRatio(
                                                                    aspectRatio:
                                                                        1,
                                                                    child: IconButton(
                                                                      style: IconButton.styleFrom(
                                                                        backgroundColor: currentHabit
                                                                            .color
                                                                            .withValues(
                                                                              alpha: 0.2,
                                                                            ),
                                                                      ),
                                                                      onPressed: () {
                                                                        context
                                                                            .read<
                                                                              HabitProvider
                                                                            >()
                                                                            .incrementCount(
                                                                              currentHabit.id,
                                                                            );
                                                                      },
                                                                      icon: Icon(
                                                                        Icons
                                                                            .add,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      top: 2.0,
                                                                      bottom:
                                                                          2.0,
                                                                      left: 8.0,
                                                                      right:
                                                                          8.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape: LiquidRoundedRectangle(
                                                                    borderRadius:
                                                                        160,
                                                                  ),
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor: currentHabit
                                                                          .color
                                                                          .withValues(
                                                                            alpha:
                                                                                0.1,
                                                                          ),
                                                                      shadowColor:
                                                                          Colors
                                                                              .transparent, // Arka plan transparent ise gölgeyi de kaldırabilirsin
                                                                      shape:
                                                                          const StadiumBorder(),
                                                                      minimumSize:
                                                                          Size.zero, // Boyut sınırlamasını kaldırır
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap, // Tıklama alanını sıkıştırır
                                                                    ),
                                                                    onPressed: () => showCountSelectorSheet(
                                                                      selectedDate ??
                                                                          DateTime.now(),
                                                                      context,
                                                                      currentHabit,
                                                                      habit:
                                                                          currentHabit,
                                                                    ),
                                                                    child: Text(
                                                                      "${currentHabit.getCountProgressForDate(selectedDate ?? DateTime.now())}",
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      4.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape:
                                                                      LiquidOval(),
                                                                  child: AspectRatio(
                                                                    aspectRatio:
                                                                        1,
                                                                    child: IconButton(
                                                                      style: IconButton.styleFrom(
                                                                        backgroundColor: currentHabit
                                                                            .color
                                                                            .withValues(
                                                                              alpha: 0.2,
                                                                            ),
                                                                      ),
                                                                      onPressed: () {
                                                                        context
                                                                            .read<
                                                                              HabitProvider
                                                                            >()
                                                                            .decrementCount(
                                                                              currentHabit.id,
                                                                            );
                                                                      },
                                                                      icon: Icon(
                                                                        Icons
                                                                            .remove,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                // TIME
                                                else if (currentHabit.type ==
                                                    HabitType.time)
                                                  currentHabit.isSkippedOnDate(
                                                        selectedDate ??
                                                            DateTime.now(),
                                                      )
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                8.0,
                                                              ),
                                                          child: LiquidGlass(
                                                            shape:
                                                                LiquidRoundedRectangle(
                                                                  borderRadius:
                                                                      16,
                                                                ),
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                shape:
                                                                    const StadiumBorder(),
                                                              ),
                                                              onPressed: () {},
                                                              child: Text(
                                                                "Atlandı",
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : IntrinsicHeight(
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape:
                                                                      LiquidOval(),
                                                                  child:
                                                                      Consumer<
                                                                        HabitProvider
                                                                      >(
                                                                        builder:
                                                                            (
                                                                              context,
                                                                              provider,
                                                                              child,
                                                                            ) {
                                                                              final bool
                                                                              isRunning =
                                                                                  (provider.runningTimers[currentHabit.id]) ??
                                                                                  false;

                                                                              return IconButton(
                                                                                style: IconButton.styleFrom(
                                                                                  foregroundColor: Colors.grey,
                                                                                ),
                                                                                onPressed: () {
                                                                                  provider.resetTimer(
                                                                                    currentHabit.id,
                                                                                  ); // sıfırla
                                                                                  if (isRunning) {
                                                                                    provider.toggleTimer(
                                                                                      currentHabit.id,
                                                                                      selectedDate ??
                                                                                          DateTime.now(),
                                                                                    ); // timer'ı da durdur
                                                                                  }
                                                                                },
                                                                                icon: const Icon(
                                                                                  Icons.refresh,
                                                                                  size: 25,
                                                                                ),
                                                                              );
                                                                            },
                                                                      ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape: LiquidRoundedRectangle(
                                                                    borderRadius:
                                                                        160,
                                                                  ),
                                                                  child: ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      shadowColor:
                                                                          Colors
                                                                              .transparent, // Arka plan transparent ise gölgeyi de kaldırabilirsin
                                                                      shape:
                                                                          const StadiumBorder(),
                                                                      minimumSize:
                                                                          Size.zero, // Boyut sınırlamasını kaldırır
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap, // Tıklama alanını sıkıştırır
                                                                    ),
                                                                    onPressed: () => showTimeSelectorSheet(
                                                                      context,
                                                                      currentHabit,
                                                                      selectedDate ??
                                                                          DateTime.now(),
                                                                    ),
                                                                    child: Text(
                                                                      currentHabit
                                                                          .getSecondsProgressForDate(
                                                                            selectedDate ??
                                                                                DateTime.now(),
                                                                          )
                                                                          .toInt()
                                                                          .formattedHMS,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8.0,
                                                                    ),
                                                                child: LiquidGlass(
                                                                  shape:
                                                                      LiquidOval(),
                                                                  child:
                                                                      Consumer<
                                                                        HabitProvider
                                                                      >(
                                                                        builder:
                                                                            (
                                                                              context,
                                                                              provider,
                                                                              child,
                                                                            ) {
                                                                              final bool
                                                                              isRunning =
                                                                                  provider.runningTimers[currentHabit.id] ??
                                                                                  false;

                                                                              return IconButton(
                                                                                style: IconButton.styleFrom(
                                                                                  foregroundColor: Colors.grey,
                                                                                ),
                                                                                onPressed: () {
                                                                                  provider.toggleTimer(
                                                                                    currentHabit.id,

                                                                                    selectedDate ??
                                                                                        DateTime.now(),
                                                                                  );
                                                                                },
                                                                                icon: Icon(
                                                                                  isRunning
                                                                                      ? Icons.pause
                                                                                      : Icons.play_arrow,
                                                                                  size: 25,
                                                                                ),
                                                                              );
                                                                            },
                                                                      ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                else
                                                  const Placeholder(),
                                                // durum yönetiminde bizdir (production için en iyi yöntem bu bu arada error yese adam diğer işleri engellenecek)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 96,
                                    ),
                                    child: GlassGlow(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16.0,
                                        ),
                                        child: Opacity(
                                          opacity: 1,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              StrengthGauge(
                                                seenStrength:
                                                    "${currentHabit.strength.toStringAsFixed(1)}%",
                                                strength: currentHabit.strength,
                                                size: 200,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: LiquidGlass(
                                            shape: LiquidRoundedRectangle(
                                              borderRadius: 64,
                                            ),
                                            child: GlassGlow(
                                              child: StatCard(
                                                "Aktif Streak",
                                                "${currentHabit.currentStreak}",
                                                Icons.whatshot,
                                                Colors.orange,
                                                16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: LiquidGlass(
                                            shape: LiquidRoundedRectangle(
                                              borderRadius: 64,
                                            ),
                                            child: GlassGlow(
                                              child: StatCard(
                                                "Güç Seviyesi",
                                                "%${currentHabit.strength}",
                                                Icons.trending_up,
                                                Colors.green,
                                                16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: LiquidGlass(
                                            shape: LiquidRoundedRectangle(
                                              borderRadius: 64,
                                            ),
                                            child: GlassGlow(
                                              child: StatCard(
                                                isWideOverride: true,
                                                "Alışkanlık Seviyesi",
                                                currentHabit.strengthLevel,
                                                currentHabit.strengthLevel ==
                                                        "Efsane"
                                                    ? Icons.hotel_class
                                                    : currentHabit
                                                              .strengthLevel ==
                                                          "Usta"
                                                    ? Icons.star
                                                    : currentHabit
                                                              .strengthLevel ==
                                                          "Güçlü"
                                                    ? Icons.star_half
                                                    : currentHabit
                                                              .strengthLevel ==
                                                          "Orta"
                                                    ? Icons.favorite
                                                    : currentHabit
                                                              .strengthLevel ==
                                                          "Zayıf"
                                                    ? Icons.all_out
                                                    : Icons.question_mark,
                                                Colors.blue,
                                                8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: LiquidGlass(
                                    shape: LiquidRoundedRectangle(
                                      borderRadius: 8,
                                    ),
                                    child: TableCalendar(
                                      firstDay: DateTime.utc(2020, 1, 1),
                                      lastDay: DateTime.utc(2030, 12, 31),
                                      focusedDay: DateTime.now(),
                                      calendarFormat: CalendarFormat.month,
                                      startingDayOfWeek:
                                          StartingDayOfWeek.monday,
                                      headerStyle: const HeaderStyle(
                                        formatButtonVisible: false,
                                        titleCentered: true,
                                      ),

                                      // Günlerin nasıl renkleneceğini belirle
                                      calendarBuilders: CalendarBuilders(
                                        defaultBuilder:
                                            (context, day, focusedDay) {
                                              // Gelecek günler → siyah / şeffaf
                                              if (day.isAfter(DateTime.now())) {
                                                return Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return null; // normal gün
                                            },

                                        todayBuilder:
                                            (context, day, focusedDay) {
                                              return Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.pinkAccent,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${day.day}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },

                                        markerBuilder: (context, day, events) {
                                          if (day.isAfter(DateTime.now())) {
                                            return null;
                                          }
                                          final normalizedDay = DateTime(
                                            day.year,
                                            day.month,
                                            day.day,
                                          );

                                          // Kurallar:
                                          // - Tüm habitler yapılmış → dolu yeşil
                                          // - Bazısı yapılmış → içi boş yeşil çember
                                          // - Hiçbiri yapılmamış ve atlanmış ise → içi boş açık gri çember
                                          // - Hiçbiri yapılmamış ve geçmiş gün ise → dolu kırmızı

                                          if (normalizedDay.isBefore(
                                            currentHabit.createdAt.subtract(
                                              Duration(days: 1),
                                            ),
                                          )) {
                                            return Center(
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          // Tamamı yapılmış
                                          if (currentHabit.isCompletedOnDate(
                                                normalizedDay,
                                              ) ||
                                              currentHabit
                                                      .getCountProgressForDate(
                                                        normalizedDay,
                                                      ) ==
                                                  (currentHabit.targetCount
                                                      ?.toInt()) ||
                                              currentHabit
                                                      .getSecondsProgressForDate(
                                                        normalizedDay,
                                                      ) ==
                                                  (currentHabit.targetSeconds
                                                      ?.toInt())) {
                                            return Center(
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: context
                                                      .read<HabitProvider>()
                                                      .getMixedColor(
                                                        currentHabit.id,
                                                      )
                                                      .withValues(alpha: 0.8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          if (currentHabit.type ==
                                                  HabitType.time
                                              ? currentHabit.getSecondsProgressForDate(
                                                          normalizedDay,
                                                        ) <
                                                        (currentHabit
                                                            .targetSeconds!
                                                            .toInt()) &&
                                                    currentHabit
                                                            .getSecondsProgressForDate(
                                                              normalizedDay,
                                                            ) >
                                                        0
                                              : currentHabit.type ==
                                                    HabitType.count
                                              ? currentHabit.getCountProgressForDate(
                                                          normalizedDay,
                                                        ) <
                                                        (currentHabit
                                                            .targetCount!
                                                            .toInt()) &&
                                                    currentHabit
                                                            .getCountProgressForDate(
                                                              normalizedDay,
                                                            ) >
                                                        0
                                              : false) {
                                            return Center(
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: context
                                                        .read<HabitProvider>()
                                                        .getMixedColor(
                                                          currentHabit.id,
                                                        )
                                                        .withValues(alpha: 0.9),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: context
                                                          .read<HabitProvider>()
                                                          .getMixedColor(
                                                            currentHabit.id,
                                                          )
                                                          .withValues(
                                                            alpha: 0.9,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          if (currentHabit.isSkippedOnDate(
                                            normalizedDay,
                                          )) {
                                            return Center(
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.6),
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: Colors.grey
                                                          .withValues(
                                                            alpha: 0.8,
                                                          ),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          if (currentHabit.isCompletedOnDate(
                                                    normalizedDay,
                                                  ) ==
                                                  false ||
                                              currentHabit
                                                      .getCountProgressForDate(
                                                        normalizedDay,
                                                      ) ==
                                                  0 ||
                                              currentHabit
                                                      .getSecondsProgressForDate(
                                                        normalizedDay,
                                                      ) ==
                                                  0) {
                                            return Center(
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withValues(
                                                    alpha: 0.8,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '${day.day}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }

                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
