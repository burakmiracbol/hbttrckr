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

import 'package:conditional_wrap/conditional_wrap.dart';
import 'package:flutter/material.dart';
import 'package:hbttrckr/classes/glass_card.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

class LiquidWrapper extends StatelessWidget {
  final Widget child;
  final bool statement;
  final LiquidShape shape;
  const LiquidWrapper({
    required this.child,
    required this.statement,
    required this.shape,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetWrapper(
      wrapper: (child) => statement
          ? LiquidGlass(
              shape: shape,
              child: GlassGlow(child: child),
            )
          : child,
      child: child,
    );
  }
}

class CardLiquidWrapper extends StatelessWidget {
  final Widget child;
  final bool statement;
  final bool statement2;
  final LiquidShape shape;
  final BoxShape glShape;
  final double borderRadius;
  final double borderRadiusRect;
  const CardLiquidWrapper({
    required this.statement2,
    required this.child,
    required this.statement,
    required this.shape,
    required this.borderRadius,
    this.borderRadiusRect = 160,
    this.glShape = BoxShape.rectangle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetWrapper(
      wrapper: (child) => statement
          ? LiquidGlass(
              shape: shape,
              child: GlassGlow(child: child),
            )
          : statement2?
          glassContainer(child: child,borderRadiusRect: borderRadiusRect, context: context)
          :Card(
        color: Theme.of(context).cardColor.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
      child: child,
    );
  }
}
