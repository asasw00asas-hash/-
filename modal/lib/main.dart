import 'package:flutter/material.dart';
import 'login_screen.dart';

void main() {
  runApp(const WhatsSenderPro());
}

class WhatsSenderPro extends StatelessWidget {
  const WhatsSenderPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Whats Sender Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020512), // Deep Navy
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BFFF), // Electric Blue
          brightness: Brightness.dark,
          surface: const Color(0xFF0A0E21),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// Dummy Dashboard for Navigation
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(child: Text('Welcome to Whats Sender Pro Dashboard')),
    );
  }
}
