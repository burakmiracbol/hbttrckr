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
import 'package:hbttrckr/actions/main_view/scheme_prefs_sheet.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';

void showGeneralPrefsSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return ClipRRect(
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
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 8,
                right: 8,
                bottom: 8,
              ),
              child: LiquidGlassLayer(
                child: GlassGlowLayer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            2.0,
                            0.0,
                            2.0,
                            6.0,
                          ),
                          child: LiquidGlass(
                            shape: LiquidRoundedRectangle(borderRadius: 160),
                            child: GlassGlow(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  4.0,
                                  14.0,
                                  8.0,
                                ),
                                child: Text(
                                  "Genel Tercihler",
                                  style: TextStyle(
                                    fontSize: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.fontSize,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: LiquidGlass(
                          shape: LiquidRoundedRectangle(borderRadius: 160),
                          child: GlassGlow(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320),
                              ),
                              shadowColor: Colors.transparent,
                              color: Colors.transparent,
                              child: ListTile(
                                onTap: () => context
                                    .read<CurrentThemeMode>()
                                    .changeThemeMode(),
                                leading: IconButton(
                                  icon: Icon(
                                    context.watch<CurrentThemeMode>().isDarkMode
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                  ),
                                  onPressed: () => context
                                      .read<CurrentThemeMode>()
                                      .changeThemeMode(),
                                ),
                                title: Text("Tema Modunu Değiştirin"),
                                subtitle: Text(
                                  "şu anki tema modu ${context.watch<CurrentThemeMode>().isDarkMode ? "karanlık" : "açık"}",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Yeni: Tema etkenlerini değiştirme ListTile'ı
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: LiquidGlass(
                          shape: LiquidRoundedRectangle(borderRadius: 160),
                          child: GlassGlow(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320),
                              ),
                              shadowColor: Colors.transparent,
                              color: Colors.transparent,
                              child: ListTile(
                                trailing: Icon(Icons.chevron_right),
                                leading: CircleAvatar(
                                  child: Icon(Icons.palette),
                                ),
                                title: Text("Tema Etkenlerini Değiştirin"),
                                subtitle: Text(
                                  "${context.watch<SchemeProvider>().scheme.toString().split('.').last} • ${context.watch<SchemeProvider>().baseColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}",
                                ),
                                onTap: () {
                                  final sp = context.read<SchemeProvider>();
                                  Color tempColor = sp.baseColor;
                                  SchemeType tempScheme = sp.scheme;
                                  openSchemePrefsSheet(
                                    context,
                                    sp,
                                    tempScheme,
                                    tempColor,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: LiquidGlass(
                          shape: LiquidRoundedRectangle(borderRadius: 160),
                          child: GlassGlow(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320),
                              ),
                              shadowColor: Colors.transparent,
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Consumer<CurrentThemeMode>(
                                  builder: (ctx, theme, child) => Icon(
                                    theme.isMica
                                        ? Icons.blur_off
                                        : Icons.blur_on,
                                  ),
                                ),
                                title: Text(
                                  "Uygulamanın Şeffaflığını Değiştirin",
                                ),
                                subtitle: Text(
                                  "şu anki görüntü modu ${context.watch<CurrentThemeMode>().isMica ? "normal" : "şeffaf"}",
                                ),
                                onTap: () async {
                                  await context
                                      .read<CurrentThemeMode>()
                                      .toggleMica();
                                },
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
        ),
      );
    },
  );
}
