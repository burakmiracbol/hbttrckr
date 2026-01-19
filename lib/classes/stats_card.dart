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
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';


class StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final double padding;
  const StatCard(this.title, this.value, this.icon, this.color, this.padding, {super.key});

  @override
  Widget build(BuildContext context) {
    return liquidGlassContainer(
      context: context,
      child: GlassGlow(
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
      ),
    );
  }
}
