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
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';

void showPreferencesSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.only(top: 16, left: 8, right: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () =>
                        context.read<CurrentThemeMode>().changeThemeMode(),
                    leading: IconButton(
                      icon: Icon(
                        context.watch<CurrentThemeMode>().isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () =>
                          context.read<CurrentThemeMode>().changeThemeMode(),
                    ),
                    title: Text("Tema Modunu Değiştirin"),
                    subtitle: Text(
                      "şu anki tema modu ${context.watch<CurrentThemeMode>().isDarkMode ? "karanlık" : "açık"}",
                    ),
                  ),
                  // Yeni: Tema etkenlerini değiştirme ListTile'ı
                  ListTile(
                    leading: CircleAvatar(child: Icon(Icons.palette)),
                    title: Text("Tema Etkenlerini Değiştirin"),
                    subtitle: Text(
                      "${context.watch<SchemeProvider>().scheme.toString().split('.').last} • ${context.watch<SchemeProvider>().baseColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}",
                    ),
                    onTap: () {
                      final sp = context.read<SchemeProvider>();
                      Color tempColor = sp.baseColor;
                      SchemeType tempScheme = sp.scheme;
                      showModalBottomSheet(
                        context: sheetContext,
                        isScrollControlled: true,
                        builder: (ctx) {
                          return StatefulBuilder(
                            builder: (ctx2, setStateSheet) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text('Scheme Tipi Seçin'),
                                        subtitle: DropdownButton<SchemeType>(
                                          value: tempScheme,
                                          items: SchemeType.values
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e,
                                                  child: Text(
                                                    e
                                                        .toString()
                                                        .split('.')
                                                        .last,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (v) {
                                            if (v != null) {
                                              setStateSheet(
                                                () => tempScheme = v,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      ListTile(
                                        title: Text('Base Renk Seçin'),
                                        subtitle: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: tempColor,
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                '#${tempColor.toARGB32()                                                        .toRadixString(16)
                                                        .padLeft(8, '0')
                                                        .toUpperCase()}',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ColorPicker(
                                          pickerColor: tempColor,
                                          onColorChanged: (c) => setStateSheet(
                                            () => tempColor = c,
                                          ),
                                          pickerAreaHeightPercent: 0.6,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: Text('İptal'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () {
                                              sp.setScheme(tempScheme);
                                              sp.setBaseColor(tempColor);
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Text('Uygula'),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                      ),
                                      SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Consumer<CurrentThemeMode>(
                      builder: (ctx, theme, child) =>
                          Icon(theme.isMica ? Icons.blur_off : Icons.blur_on),
                    ),
                    title: Text("Uygulamanın Şeffaflığını Değiştirin"),
                    subtitle: Text(
                      "şu anki görüntü modu ${context.watch<CurrentThemeMode>().isMica ? "normal" : "şeffaf"}",
                    ),
                    onTap: () async {
                      await context.read<CurrentThemeMode>().toggleMica();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
