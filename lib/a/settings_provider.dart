import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  String _language = "العربية";
  String _fontSize = "متوسط";

  bool get darkMode => _darkMode;
  String get language => _language;
  String get fontSize => _fontSize;

  void toggleDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setFontSize(String size) {
    _fontSize = size;
    notifyListeners();
  }

  double get fontSizeValue {
    switch (_fontSize) {
      case "صغير": return 12;
      case "متوسط": return 14;
      case "كبير": return 16;
      case "كبير جداً": return 18;
      default: return 14;
    }
  }
}
