import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Basit bir theme/scheme provider: kullanıcı hangi "scheme" tipini seçtiğini
// ve temanın base color'unu değiştirebilmesini sağlar.

enum SchemeType {
  expressive,
  fidelity,
  fruitsalad,
  monochrome,
  neutral,
  rainbow,
  tonalSpot,
  vibrant,
}

class SchemeProvider extends ChangeNotifier {
  static const _kSchemeKey = 'scheme_type';
  static const _kBaseColorKey = 'scheme_base_color';

  SchemeType _scheme = SchemeType.expressive;
  Color _baseColor = Colors.teal;
  SharedPreferences? _prefs;

  SchemeType get scheme => _scheme;
  Color get baseColor => _baseColor;

  // Initialize from SharedPreferences. Call this once before using the provider
  // or await it in main() before runApp so values are loaded synchronously.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final schemeIndex = _prefs?.getInt(_kSchemeKey);
    if (schemeIndex != null && schemeIndex >= 0 && schemeIndex < SchemeType.values.length) {
      _scheme = SchemeType.values[schemeIndex];
    }
    final baseColorInt = _prefs?.getInt(_kBaseColorKey);
    if (baseColorInt != null) {
      _baseColor = Color(baseColorInt);
    }
    notifyListeners();
  }

  void setScheme(SchemeType s) {
    if (_scheme != s) {
      _scheme = s;
      _prefs?.setInt(_kSchemeKey, s.index);
      notifyListeners();
    }
  }

  void setBaseColor(Color c) {
    if (_baseColor != c) {
      _baseColor = c;
      _prefs?.setInt(_kBaseColorKey, c.toARGB32());
      notifyListeners();
    }
  }

  // Helper: ARGB int for color utilities
  int get baseColorArgb => _baseColor.toARGB32();
}
