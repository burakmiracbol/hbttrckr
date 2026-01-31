

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../classes/all_widgets.dart';
import '../../providers/scheme_provider.dart';

void openSchemePrefsSheet(
  BuildContext sheetContext,
  SchemeProvider sp,
  SchemeType tempScheme,
  Color tempColor,
) {
  showPlatformModalSheet(
    context: sheetContext,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setStateSheet) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: PlatformTitle(
                          fontSize: Theme.of(ctx).textTheme.headlineSmall!.fontSize,
                          title: 'Scheme Prefs',
                          padding: EdgeInsets.fromLTRB(16,2,16,2)
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text('Scheme Tipi Seçin'),
                    subtitle: DropdownButton<SchemeType>(
                      style: TextStyle(color: Colors.white),
                      dropdownColor: Colors.grey[900],
                      value: tempScheme,
                      items: SchemeType.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.toString().split('.').last),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setStateSheet(() => tempScheme = v);
                        }
                      },
                    ),
                  ),

                  Center(
                    child: IntrinsicWidth(
                      child: Card(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text('Base Renk Seçin'),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(backgroundColor: tempColor),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        '#${tempColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Card(
                    child: IntrinsicHeight(
                      child: IntrinsicWidth(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorPicker(
                            hexInputBar: true,
                            portraitOnly: true,
                            pickerColor: tempColor,
                            onColorChanged: (c) =>
                                setStateSheet(() => tempColor = c),
                            pickerAreaHeightPercent: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      spacing: 8,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('İptal'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            sp.setScheme(tempScheme);
                            sp.setBaseColor(tempColor);
                            Navigator.of(ctx).pop();
                          },
                          child: Text('Uygula'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
