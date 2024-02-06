import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  static const String IS_DARK = "isDark";

  bool get themeValue {
    return _isDark;
  }

  set themeValue(bool value) {
    _isDark = value;
    updateThemeInPref(value);
    notifyListeners();
  }

  void updateThemeInPref(bool value) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(IS_DARK, value);
  }

  void updateThemeOnStart() async {
    var prefs = await SharedPreferences.getInstance();
    var isDarkPref = prefs.getBool(IS_DARK);

    if (isDarkPref != null) {
      _isDark = isDarkPref;
    } else {
      _isDark = false;
    }
    notifyListeners();
  }
}
