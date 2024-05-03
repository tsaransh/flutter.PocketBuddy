import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:pocket_buddy_new/screens/auth.dart';
import 'package:pocket_buddy_new/screens/home.dart';
import 'package:pocket_buddy_new/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

ThemeData? themeLight;
ThemeData? themeDark;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final themeStr = await rootBundle.loadString('assets/theme/app_theme.json');
  final themeJson = jsonDecode(themeStr);
  themeLight = ThemeDecoder.decodeThemeData(themeJson)!;

  final themeStrDark =
      await rootBundle.loadString('assets/theme/app_theme_dark.json');
  final themeJsonDark = jsonDecode(themeStrDark);
  themeDark = ThemeDecoder.decodeThemeData(themeJsonDark)!;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeLight,
      darkTheme: themeDark,
      themeMode: ThemeMode.system,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
