import 'package:flutter/material.dart';
import 'main_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Flex',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor:
            const Color(0xFFDDB892),

        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color(0xFFDDB892),

          foregroundColor:
              Color(0xFF5D4037),

          elevation: 0,

          surfaceTintColor:
              Colors.transparent,
        ),

        colorScheme: ColorScheme.fromSeed(
          seedColor:
              const Color(0xFFDDB892),
        ),
      ),

      home: const MainPage(),
    );
  }
}