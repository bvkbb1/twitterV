import 'package:flutter/material.dart';
import 'package:twitter_clone_v/theming/dark_mode.dart';
import 'package:twitter_clone_v/theming/light_theme.dart';

class MyThemeProvider extends ChangeNotifier{
  ThemeData _themeData = lightMode;

  // getter for theme data
  ThemeData get getThemeData => _themeData;

  bool get isDarkMode => _themeData == darkMode;

  // set the theme data
  set setThemeData(ThemeData themeDate){
    _themeData = themeDate;
    notifyListeners();
  }

  // set the theme
  void toggleTheme(){
    setThemeData = _themeData == lightMode ? darkMode : lightMode;
    // if (_themeData == lightMode) {
    //   setThemeData = darkMode;
    // } else {
    //   setThemeData = lightMode;
    // }
  }
}