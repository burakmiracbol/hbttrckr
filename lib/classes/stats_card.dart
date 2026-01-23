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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';


class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final double padding;
  final bool? isWideOverride;
  const StatCard(
    this.title,
    this.value,
    this.icon,
    this.color,
    this.padding, {
    this.isWideOverride,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = math.max(0.0, constraints.maxWidth - padding * 2);
        final innerHeight = math.max(0.0, constraints.maxHeight - padding * 2);
        final baseSize = math.min(innerWidth, innerHeight);
        final isWide = isWideOverride ?? innerWidth >= innerHeight * 1.2;
        final iconSize = baseSize * 0.32;
        final valueSize = baseSize * 0.2;
        final titleSize = baseSize * 0.07;
        final gapSmall = baseSize * 0.04;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Opacity(
            opacity: 1,
            child: isWide
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: iconSize, color: color),
                          SizedBox(width: gapSmall),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: valueSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gapSmall / 2),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: iconSize, color: color),
                      SizedBox(height: gapSmall),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: valueSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: gapSmall / 2),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: titleSize,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
