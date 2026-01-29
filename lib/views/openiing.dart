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

import 'dart:io';

import 'package:flutter/material.dart';

class StatefulWidgetSkeletonSheet extends StatefulWidget {
  const StatefulWidgetSkeletonSheet({super.key});

  @override
  State<StatefulWidgetSkeletonSheet> createState() =>
      _StatefulWidgetSkeletonSheetState();
}

class _StatefulWidgetSkeletonSheetState
    extends State<StatefulWidgetSkeletonSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController controllerForSmth;
  late Animation<double> sizeAnimation;
  late AnimationController animationControllerForSmth;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    animationControllerForSmth = AnimationController(
      vsync: this, // Ekran yenileme sinyalini buradan al
      duration: const Duration(seconds: 2), // Animasyon 2 saniye sürsün
    );
    controllerForSmth = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300), // Genişleme hızı
    );
    // 0.0'dan (hiç yok) 1.0'a (tam boy) kadar bir eğri
    sizeAnimation = CurvedAnimation(
      parent: controllerForSmth,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationControllerForSmth.dispose();
    controllerForSmth.dispose();
  }

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      isExpanded ? controllerForSmth.forward() : controllerForSmth.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text(
              "Hello! Welcome to Hbttrckr",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: "arial",
              ),
            ),
            Text(
              "So if you are new let's get set you up",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: "arial",
              ),
            ),
            Text(
              "We are believing to everybody have a right to select their theme because preferences are personal so lets start with theme selection for you",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w200,
                fontFamily: "arial",
              ),
            ),
            Wrap(
              children: [
                Card(shape: StadiumBorder()),
                Card(shape: StadiumBorder()),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "there is much more options but those are not recommended ones (you can still find the real gem for you)",
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                      fontFamily: "arial",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animationControllerForSmth,
                  ),
                ),
              ],
            ),

            SizeTransition(
              sizeFactor: sizeAnimation,
              axisAlignment:
                  -1.0, // İçeriğin yukarıdan aşağıya doğru büyümesini sağlar
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.withValues(alpha: 0.1),
                child: const Wrap(
                  children: [
                    Card(shape: StadiumBorder()),
                    Card(shape: StadiumBorder()),
                    Card(shape: StadiumBorder()),
                  ],
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => exit(0),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text("Uygulamadan Çık"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),

                ElevatedButton(
                  onPressed: () {},
                  child: Text("Sıradaki Sayfaya Geç"),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

