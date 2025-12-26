import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hbttrckr/views/charts.dart';
import 'package:hbttrckr/providers/habitprovider.dart';
import 'package:hbttrckr/classes/habit.dart';
import 'package:hbttrckr/classes/glasscard.dart';

import 'mainappview.dart';



class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habits = context.watch<HabitProvider>().habits;

    final totalHabits = habits.length;
    final activeHabits = habits.where((h) => h.currentStreak > 0).length;
    final perfectHabits = habits.where((h) => h.strength >= 90).length;
    final totalStrength = habits.fold(0.0, (sum, h) => sum + h.strength);

    return GlassGlowLayer(
      child: LiquidGlassLayer(
        child: Scaffold(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor.withValues(alpha: 0),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: isMica
                                ? Theme.of(context).cardColor
                                : Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.2),
                            child: StatCard(
                              "Toplam Alışkanlık",
                              totalHabits.toString(),
                              Icons.list_alt,
                              Colors.blue,
                              16,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: isMica
                                ? Theme.of(context).cardColor
                                : Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.2),
                            child: StatCard(
                              "Aktif Streak",
                              activeHabits.toString(),
                              Icons.whatshot,
                              Colors.orange,
                              16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: isMica
                                ? Theme.of(context).cardColor
                                : Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.2),
                            child: StatCard(
                              "Efsane Seviye",
                              perfectHabits.toString(),
                              Icons.star,
                              Colors.purple,
                              16,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: isMica
                                ? Theme.of(context).cardColor
                                : Theme.of(
                                    context,
                                  ).cardColor.withValues(alpha: 0.2),
                            child: StatCard(
                              "Ortalama Güç",
                              "${(totalStrength / totalHabits.clamp(1, 999)).toStringAsFixed(1)}%",
                              Icons.trending_up,
                              Colors.green,
                              16,
                            ),
                          ),
                        ),
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
}

class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  double padding = 0;
  StatCard(this.title, this.value, this.icon, this.color, this.padding);

  @override
  Widget build(BuildContext context) {
    return GlassGlow(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Opacity(
          opacity: 1,
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
