import 'package:flutter/material.dart';
import 'package:wattwise/config/app_colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryGreen,
    secondary: AppColors.primaryBlue,
    surface: Colors.white,
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: AppColors.primaryGreen,
    iconTheme: IconThemeData(color: AppColors.textLight),
    titleTextStyle: TextStyle(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryGreen,
    secondary: AppColors.primaryBlue,
    surface: const Color(0xFF1E1E1E),
    error: AppColors.error,
  ),
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: const AppBarTheme(
    elevation: 0,
    backgroundColor: Color(0xFF1E1E1E),
    iconTheme: IconThemeData(color: AppColors.textLight),
    titleTextStyle: TextStyle(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
);
