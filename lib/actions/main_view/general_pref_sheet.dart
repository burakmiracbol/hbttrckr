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
import '../../classes/all_widgets.dart';
import '../../providers/scheme_provider.dart';

void showGeneralPrefsSheet(BuildContext context) {
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 8.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: PlatformTitle(
                        fontSize: Theme.of(context,).textTheme.headlineSmall!.fontSize,
                        title: 'Genel Tercihler',
                        padding: EdgeInsets.fromLTRB(16,2,16,2)
                    ),
                  ),
                ),
              ),
            ),

            PlatformListTile(
              onTap: () => context.read<CurrentThemeMode>().changeThemeMode(),
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
            PlatformListTile(
              trailing: Icon(Icons.chevron_right),
              leading: CircleAvatar(child: Icon(Icons.palette)),
              title: Text("Tema Etkenlerini Değiştirin"),
              subtitle: Text(
                "${context.watch<SchemeProvider>().scheme.toString().split('.').last} • ${context.watch<SchemeProvider>().baseColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}",
              ),
              onTap: () {
                final sp = context.read<SchemeProvider>();
                Color tempColor = sp.baseColor;
                SchemeType tempScheme = sp.scheme;
                openSchemePrefsSheet(context, sp, tempScheme, tempColor);
              },
            ),

            PlatformListTile(
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
      );
    },
  );
}
