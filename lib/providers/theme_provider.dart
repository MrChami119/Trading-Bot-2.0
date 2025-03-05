import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    notifyListeners();
  }
  
  // App colors
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFF0C419);
  static const Color accentBlue = Color(0xFF4A90E2);
  static const Color accentGreen = Color(0xFF2ECC71);
  static const Color accentRed = Color(0xFFE74C3C);
  
  // Dark theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryGold,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: const ColorScheme.dark(
      primary: primaryGold,
      secondary: secondaryGold,
      surface: Color(0xFF1E1E1E),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: primaryGold,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: primaryGold),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
  
  // Light theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    primaryColor: primaryGold,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: primaryGold,
      secondary: secondaryGold,
      surface: Color(0xFFF5F5F5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: const Color(0xFF1E1E1E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: primaryGold),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

