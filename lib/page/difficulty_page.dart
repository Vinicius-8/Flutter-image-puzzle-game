import 'package:flutter/material.dart';
import 'package:imazzler/handlers/database_handler.dart' as database_handler;
import 'package:imazzler/models/difficulty_model.dart';
import 'package:imazzler/page/game_page.dart';

enum Levels {
  level_2, // 2 - Barbie
  level_3, // 3 - Too Easy
  level_4, // 4 - Easy
  level_5, // 5 - Not That Easy
  level_6, // 6 - Medium
  level_7, // 7 - Medium Plus
  level_8, // 8 - A Bit Tough
  level_9, // 9 - Takes Time
  level_10, // 10 - Difficult
  level_15, // 15 - Oh Man
  level_20, // 20 - Impossible
  level_25, // 25 - Stop Man Please
  level_30, // 30 - Don't Do this To Yourself
}

// ignore: must_be_immutable
class DifficultyPage extends StatefulWidget {
  int difficulty;
  String? customImagePath;
  DifficultyPage({super.key, required this.difficulty, this.customImagePath});

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends State<DifficultyPage> {
  final database = database_handler.openDB();
  Levels _difficultyLevel = Levels.level_4;
  

  static const Map<Levels, int> values = {
    Levels.level_2: 2,
    Levels.level_3: 3,
    Levels.level_4: 4,
    Levels.level_5: 5,
    Levels.level_6: 6,
    Levels.level_7: 7,
    Levels.level_8: 8,
    Levels.level_9: 9,
    Levels.level_10: 10,
    Levels.level_15: 15,
    Levels.level_20: 20,
    Levels.level_25: 25,
    Levels.level_30: 30,
  };

  static int _getValue(Levels level) {
    return values[level]!;
  }

  static Levels? _getLevel(int value) {
    return values.entries.firstWhere((entry) => entry.value == value, orElse: () => const MapEntry(Levels.level_2, -1)).key;
  }

  @override
  void initState() {
    _difficultyLevel = _getLevel(widget.difficulty)!;
    super.initState();
  }

  void _defineDifficultyInDatabase() {
    if (widget.customImagePath != null) {
      _playCustomImage();      
      return;
    }

    int diff = _getValue(_difficultyLevel);
    database_handler.upsertDifficulty(Difficulty(date: DateTime.now().toString(), difficulty: diff), database).then(
      (value) {
        Navigator.pop(context);
      },
    );
  }

  void _playCustomImage() {
    int diff = _getValue(_difficultyLevel);
    Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(MediaQuery.of(context).size, widget.customImagePath!, diff, 1, 999999,  true,))).then((value) {
      Navigator.pop(context);
    },);
  }

  Widget _radioItem(String text, Levels radioLevel) {
    return RadioListTile<Levels>(
        title: Text(text),
        value: radioLevel,
        groupValue: _difficultyLevel,
        onChanged: (Levels? value) {
          setState(() {
            _difficultyLevel = value!;
            _defineDifficultyInDatabase();
          });
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _radioItem("Barbie", Levels.level_2),
              _radioItem("Too Easy", Levels.level_3),
              _radioItem("Easy", Levels.level_4),
              _radioItem("Not That Easy", Levels.level_5),
              _radioItem("Medium", Levels.level_6),
              _radioItem("Medium Plus", Levels.level_7),
              _radioItem("A Bit Tough", Levels.level_8),
              _radioItem("Takes Time", Levels.level_9),
              _radioItem("Difficult", Levels.level_10),
              _radioItem("Oh Man", Levels.level_15),
              _radioItem("Impossible", Levels.level_20),
              _radioItem("Stop Man, Please", Levels.level_25),
              _radioItem("Don't Do This To Yourself", Levels.level_30),
            ],
          ),
        ),
      ),
    );
  }
}
