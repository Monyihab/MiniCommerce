
import 'package:flutter/material.dart';
import 'welcome_page.dart';
import 'app_colors.dart';

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
        scaffoldBackgroundColor: lightBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: red,
          primary: red,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: red,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}
