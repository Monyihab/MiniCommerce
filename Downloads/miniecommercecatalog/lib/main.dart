import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'app_colors.dart';
import 'app_theme.dart';

void main() {
  runApp(const MyShop());
}

class MyShop extends StatelessWidget {
  const MyShop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAST Shopping Catalog',
      theme: ThemeData(
        scaffoldBackgroundColor: kDeepRed,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          primary: red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titleTextStyle: const TextStyle(
            color: navy,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(red),
          trackColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.25),
          ),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
          thumbVisibility: WidgetStateProperty.all(true),
          trackVisibility: WidgetStateProperty.all(true),
          thickness: WidgetStateProperty.all(8),
          radius: const Radius.circular(10),
          crossAxisMargin: 2,
          mainAxisMargin: 4,
          minThumbLength: 50,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}
