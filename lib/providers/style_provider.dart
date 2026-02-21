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

enum AppDesignMode { material, cupertino, liquid, fluent, macos, yaru }

enum ViewStyleForMultipleData { list, grid, wrapCard }

enum OrientationForPrivate { horizontal, vertical }

enum Selectors { time, count }

enum Liquidness { ordinary, liquid }

class StyleProvider with ChangeNotifier {
  bool isDetailLiquid = true;

  AppDesignMode current = AppDesignMode.liquid;

  OrientationForPrivate timeSelectorOrientation =
      OrientationForPrivate.vertical;

  OrientationForPrivate countSelectorOrientation =
      OrientationForPrivate.horizontal;

  bool isFulscreenNow = false;

  ViewStyleForMultipleData viewStyle = ViewStyleForMultipleData.grid;

  void setDetailLiquid(bool wanted) {
    isDetailLiquid = wanted;
    notifyListeners();
  }

  Liquidness getDetailLiquid() {
    return isDetailLiquid == true ? Liquidness.liquid : Liquidness.ordinary;
  }

  bool getDetailLiquidBoolean() {
    return isDetailLiquid;
  }

  void setFulscreenForNow(bool wanted) {
    isFulscreenNow = wanted;
    notifyListeners();
  }

  bool getFulscreenForNow() {
    return isFulscreenNow;
  }

  void setVSFMD(ViewStyleForMultipleData wantedViewStyle) {
    viewStyle = wantedViewStyle;
    notifyListeners();
  }

  ViewStyleForMultipleData getVSFMD() {
    return viewStyle;
  }

  void setOrientationForSelectors(
    Selectors selector,
    OrientationForPrivate wantedOrientation,
  ) {
    if (selector == Selectors.time) {
      timeSelectorOrientation = wantedOrientation;
    } else if (selector == Selectors.count) {
      countSelectorOrientation = wantedOrientation;
    }
    notifyListeners();
  }

  bool getOrientationForSelectors(Selectors selector) {
    if (selector == Selectors.time) {
      return timeSelectorOrientation == OrientationForPrivate.horizontal ? true : false;
    } else if (selector == Selectors.count) {
      return countSelectorOrientation == OrientationForPrivate.horizontal ? true : false;
    } else {
      return true;
    }
  }
}
