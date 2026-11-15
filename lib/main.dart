import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'helpers/shared_pref_helper.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'theme/rick_morty_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi SQLite FFI untuk desktop Linux / Windows / macOS
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final bool isLoggedIn = await SharedPrefHelper.isLoggedIn();

  runApp(RickAndMortyApp(isLoggedIn: isLoggedIn));
}

class RickAndMortyApp extends StatelessWidget {
  final bool isLoggedIn;
  const RickAndMortyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: RickMortyTheme.darkTheme,
      home: isLoggedIn ? const MainNavScreen() : const LoginScreen(),
    );
  }
}
