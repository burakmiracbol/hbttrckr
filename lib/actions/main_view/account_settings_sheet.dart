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

void showAccountSettingsSheet (
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
          padding: const EdgeInsets.only(
            top: 16,
            left: 8,
            right: 8,
            bottom: 8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Align(
                      alignment:
                      Alignment.topLeft,
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          4.0,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(
                              sheetContext,
                            );
                          },
                          icon: Icon(
                            Icons.close,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Account",
                        style: TextStyle(
                          fontSize:
                          Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.fontSize,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ),
                  child: Card(
                    child: TextField(
                      controller:
                      accountController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                        'Account name',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        filled: true,
                        fillColor:
                        Colors.grey[900],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ),
                  child: Card(
                    child: TextField(
                      controller:
                      passwordController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText:
                        'Password (that is secret don\'t share it)',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            12,
                          ),
                        ),
                        filled: true,
                        fillColor:
                        Colors.grey[900],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot your password ?\n(okay that is normal but we are tired)",
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(
                    4.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        Color.fromARGB(
                          255,
                          140,
                          140,
                          73,
                        ),
                      ),
                      onPressed: () {},
                      child: Text("Log in"),
                    ),
                  ),
                ),

                Stack(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.only(
                        top: 6.0,
                      ),
                      child: Center(
                        child: Divider(),
                      ),
                    ),
                    Center(
                      child: Card(
                        child: Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Text("  or  "),
                        ),
                      ),
                    ),
                  ],
                ),

                Card(
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Create Account",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),))
      );
    },
  );
}