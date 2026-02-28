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
import '../../providers/style_provider.dart';

void showPrivatePrefsSheet(BuildContext context) {
  showPlatformModalSheet(
    enableDrag: true,
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setStateSheet) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2.0, 0.0, 2.0, 8.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: PlatformTitle(
                        fontSize: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.fontSize,
                        title: 'Özel Tercihler',
                        padding: EdgeInsets.fromLTRB(16, 2, 16, 2),
                      ),
                    ),
                  ),
                ),
              ),

              PlatformListTile(
                onTap: () {},
                leading: Icon(
                  context.read<StyleProvider>().getOrientationForSelectors(
                        Selectors.time,
                      )
                      ? Icons.stay_current_landscape
                      : Icons.stay_current_portrait,
                ),
                title: Text("Time Selector Slider Orientation"),
                subtitle: Text(
                  "For now it's ${context.read<StyleProvider>().getOrientationForSelectors(Selectors.time) ? "horizontal" : "vertical"}",
                ),
                trailing: DropdownButton<OrientationForPrivate>(
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  value: context.read<StyleProvider>().timeSelectorOrientation,
                  items: OrientationForPrivate.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setStateSheet(
                        () => context
                            .read<StyleProvider>()
                            .setOrientationForSelectors(Selectors.time, v),
                      );
                    }
                  },
                ),
              ),

              PlatformListTile(
                onTap: () {},
                leading: Icon(
                  context.read<StyleProvider>().getOrientationForSelectors(
                        Selectors.count,
                      )
                      ? Icons.stay_current_landscape
                      : Icons.stay_current_portrait,
                ),
                title: Text("Count Selector Slider Orientation"),
                subtitle: Text(
                  "For now it's ${context.read<StyleProvider>().getOrientationForSelectors(Selectors.count) ? "horizontal" : "vertical"}",
                ),
                trailing: DropdownButton<OrientationForPrivate>(
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  value: context.read<StyleProvider>().countSelectorOrientation,
                  items: OrientationForPrivate.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setStateSheet(
                        () => context
                            .read<StyleProvider>()
                            .setOrientationForSelectors(Selectors.count, v),
                      );
                    }
                  },
                ),
              ),

              PlatformListTile(
                onTap: () {},
                leading: Icon(
                  context.watch<StyleProvider>().getVSFMD() ==
                          ViewStyleForMultipleData.grid
                      ? Icons.grid_view_rounded
                      : context.watch<StyleProvider>().getVSFMD() ==
                            ViewStyleForMultipleData.list
                      ? Icons.list
                      : Icons.credit_card_rounded,
                ),
                title: Text("Change Layout in Habits Page"),
                subtitle: Text(
                  "For now it is ${context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.grid
                      ? "Grid"
                      : context.watch<StyleProvider>().getVSFMD() == ViewStyleForMultipleData.list
                      ? "List"
                      : "Wrap Card"}",
                ),
                trailing: DropdownButton<ViewStyleForMultipleData>(
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  value: context.watch<StyleProvider>().getVSFMD(),
                  items: ViewStyleForMultipleData.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toString().split('.').last),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setStateSheet(
                        () => context.read<StyleProvider>().setVSFMD(v),
                      );
                    }
                  },
                ),
              ),

              // Detail screen Liquidliği
              PlatformListTile(
                onTap: () {},
                leading: Icon(context.watch<StyleProvider>().getDetailLiquidBoolean1() ? Icons.water_drop : Icons.waves),
                title: Text("Change Detail Screens Liquidness"),
                subtitle: Text("For now it is ${context.watch<StyleProvider>().getDetailLiquidBoolean1() ? "Liquid" : "Ordinary"}"),
                trailing: DropdownButton<Liquidness>(
                  style: TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[900],
                  value: context.watch<StyleProvider>().getDetailLiquid(),
                  items: Liquidness.values
                      .map(
                        (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.toString().split('.').last),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setStateSheet(
                            () => context.read<StyleProvider>().setDetailLiquid(v == Liquidness.liquid, v== Liquidness.fakeLiquid),
                      );
                    }
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
