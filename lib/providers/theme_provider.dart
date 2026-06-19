import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;
  bool get isDark => _brightness == Brightness.dark;

  void loadTheme(String theme) {
    _brightness = theme == 'dark' ? Brightness.dark : Brightness.light;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _brightness = _brightness == Brightness.light
        ? Brightness.dark
        : Brightness.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'umma_theme',
      _brightness == Brightness.dark ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Future<void> setTheme(String theme) async {
    _brightness = theme == 'dark' ? Brightness.dark : Brightness.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('umma_theme', theme);
    notifyListeners();
  }
}
