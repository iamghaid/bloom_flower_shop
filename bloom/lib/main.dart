import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_page.dart';

void main() {
  Animate.restartOnHotReload = true;
  runApp(const BloomApp());
}

class BloomApp extends StatelessWidget {
  const BloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloom',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFC17B6B),
          secondary: Color(0xFF8B5E52),
          surface: Color(0xFFFDF6EE),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
