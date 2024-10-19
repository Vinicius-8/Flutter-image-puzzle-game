import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imazzler/page/home_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
   if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } 
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMAZZLER',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromARGB(255, 54, 21, 204),
        // accentColor: Colors.tealAccent[400],
        scaffoldBackgroundColor: const Color.fromARGB(255, 60, 11, 175),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

    // return GamePage(MediaQuery.of(context).size, 'images/1_free.jpg', 4);