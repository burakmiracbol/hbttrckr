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
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:hbttrckr/actions/main_view/backup_settings_sheet.dart';
import 'package:hbttrckr/actions/main_view/preferences_settings_sheet.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'account_settings_sheet.dart';
import 'notifications_settings_sheet.dart';

void showMainSettingsSheet(
  BuildContext context,
  TextEditingController accountController,
  TextEditingController passwordController,
) {
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
                color: Colors.white.withOpacity(0.2), // İnce ışık yansıması (kenarlık)
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 14, left: 8, right: 8, bottom: 8),
              child: SingleChildScrollView(
                child: LiquidGlassLayer(
                  child: GlassGlowLayer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 6.0),
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
                                    "Ayarlar",
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
                                  leading: CircleAvatar(
                                    child: Icon(Icons.account_circle_outlined),
                                  ),
                                  title: Text("Hesap Bilgileri"),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    showAccountSettingsSheet(
                                      context,
                                      accountController,
                                      passwordController,
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
                                shadowColor: Colors.transparent,
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Icon(Icons.notifications_outlined),
                                  ),
                                  title: Text("Bildirimler"),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    showNotificationsSettingsSheet(context);
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
                                shadowColor: Colors.transparent,
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.tune)),
                                  title: Text("Tercihler"),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    showPreferencesSettingsSheet(context);
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
                                shadowColor: Colors.transparent,
                                color: Colors.transparent,
                                child: ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.backup)),
                                  title: Text("Yedekler"),
                                  trailing: Icon(Icons.chevron_right),
                                  onTap: () {
                                    showBackupSettingsSheet(context);
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
        ),
      );
    },
  );
}
