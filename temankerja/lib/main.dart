import 'package:flutter/material.dart';
import 'package:inovasi_sumut/app/app_shell.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDAN TALENTA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: KkColors.green),
        scaffoldBackgroundColor: KkColors.bg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: KkColors.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const AppShell(),
    );
  }
}
