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
import 'package:shared_preferences/shared_preferences.dart';

enum AppDesignMode { material, cupertino, liquid, fluent, macos, yaru }

enum ViewStyleForMultipleData { list, grid, wrapCard }

enum OrientationForPrivate { horizontal, vertical }

enum Selectors { time, count }

enum Liquidness { ordinary, liquid, fakeLiquid }

class StyleProvider with ChangeNotifier {
  bool isDetailLiquid = true;
  bool isDetailFakeLiquid = false;
  bool isFulscreenNow = false;
  AppDesignMode current = AppDesignMode.liquid;
  OrientationForPrivate timeSelectorOrientation =
      OrientationForPrivate.vertical;
  OrientationForPrivate countSelectorOrientation =
      OrientationForPrivate.horizontal;
  ViewStyleForMultipleData viewStyle = ViewStyleForMultipleData.grid;

  StyleProvider() {
    loadprefs();
  }

  Future<void> loadprefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Boolean Değerler
    isDetailLiquid = prefs.getBool('is_detail_liquid') ?? true;
    isDetailFakeLiquid = prefs.getBool('is_detail_fake_liquid') ?? false;
    isFulscreenNow = prefs.getBool('is_fulscreen_now') ?? false;

    // 2. Enum Değerleri (Index üzerinden okuma)
    // getInt yanındaki varsayılan değerler sınıfın başındaki varsayılanlarla aynı olmalı.
    current = AppDesignMode.values[prefs.getInt('current_design') ?? AppDesignMode.liquid.index];

    timeSelectorOrientation = OrientationForPrivate.values[
    prefs.getInt('time_orient') ?? OrientationForPrivate.vertical.index];

    countSelectorOrientation = OrientationForPrivate.values[
    prefs.getInt('count_orient') ?? OrientationForPrivate.horizontal.index];

    viewStyle = ViewStyleForMultipleData.values[
    prefs.getInt('view_style') ?? ViewStyleForMultipleData.grid.index];

    notifyListeners();
  }

  // Yardımcı Kayıt Metodu (Her değişiklikte bunu çağıracağız)
  Future<void> _saveToPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_detail_liquid', isDetailLiquid);
    await prefs.setBool('is_detail_fake_liquid', isDetailFakeLiquid);
    await prefs.setBool('is_fulscreen_now', isFulscreenNow);

    // Enumları index olarak kaydediyoruz
    await prefs.setInt('current_design', current.index);
    await prefs.setInt('time_orient', timeSelectorOrientation.index);
    await prefs.setInt('count_orient', countSelectorOrientation.index);
    await prefs.setInt('view_style', viewStyle.index);
  }

  // --- SETTER METOTLARI (Kayıt işlemi eklendi) ---

  void setDetailLiquid(bool wanted1, bool wanted2) {
    isDetailLiquid = wanted1;
    isDetailFakeLiquid = wanted2;
    _saveToPrefs(); // Kaydet
    notifyListeners();
  }

  void setFulscreenForNow(bool wanted) {
    isFulscreenNow = wanted;
    _saveToPrefs();
    notifyListeners();
  }

  void setVSFMD(ViewStyleForMultipleData wantedViewStyle) {
    viewStyle = wantedViewStyle;
    _saveToPrefs();
    notifyListeners();
  }

  void setOrientationForSelectors(Selectors selector, OrientationForPrivate wantedOrientation) {
    if (selector == Selectors.time) {
      timeSelectorOrientation = wantedOrientation;
    } else if (selector == Selectors.count) {
      countSelectorOrientation = wantedOrientation;
    }
    _saveToPrefs();
    notifyListeners();
  }

  // AppDesignMode için eksik olan setter:
  void setAppDesignMode(AppDesignMode mode) {
    current = mode;
    _saveToPrefs();
    notifyListeners();
  }

  Liquidness getDetailLiquid() {
    return isDetailLiquid == true
        ? Liquidness.liquid
        : isDetailFakeLiquid
        ? Liquidness.fakeLiquid
        : Liquidness.ordinary;
  }

  bool getDetailLiquidBoolean1() {
    return isDetailLiquid;
  }

  bool getDetailLiquidBoolean2() {
    return isDetailFakeLiquid;
  }


  bool getFulscreenForNow() {
    return isFulscreenNow;
  }


  ViewStyleForMultipleData getVSFMD() {
    return viewStyle;
  }

  bool getOrientationForSelectors(Selectors selector) {
    if (selector == Selectors.time) {
      return timeSelectorOrientation == OrientationForPrivate.horizontal
          ? true
          : false;
    } else if (selector == Selectors.count) {
      return countSelectorOrientation == OrientationForPrivate.horizontal
          ? true
          : false;
    } else {
      return true;
    }
  }
}
