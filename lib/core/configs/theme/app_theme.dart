import 'package:flutter/material.dart';
import 'package:spotifyapp/core/configs/theme/app_color.dart';

class AppTheme {
  static final lightTheme = ThemeData(
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.lightBackground,
      brightness: Brightness.light,
      fontFamily: 'RedHatDisplay',
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.all(30),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 0.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)))));

  static final darkTheme = ThemeData(
      primaryColor: AppColor.primary,
      scaffoldBackgroundColor: AppColor.darkBackground,
      brightness: Brightness.dark,
      fontFamily: 'RedHatDisplay',
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.all(30),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 0.4)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              textStyle:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)))));
}
