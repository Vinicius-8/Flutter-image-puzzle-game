import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:imazzler/models/difficulty_model.dart';
import 'package:imazzler/models/level_model.dart';
import 'package:imazzler/models/move_model.dart';
import 'package:imazzler/page/difficulty_page.dart';
import 'package:imazzler/page/game_page.dart';
import 'package:imazzler/handlers/database_handler.dart' as database_handler;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final database = database_handler.openDB();
  int? gameLevel;
  int? gameDificulty = 4;
  int? movesRecord = 9999999; // less movement record
  bool isLoading = false;

  void _playLevels() {
    if (gameLevel == null) {
      return;
    }
    
    _initLevelDb().then((value) {
      
      Navigator.push(
        context, 

        MaterialPageRoute(
          builder: (_) => GamePage(MediaQuery.of(context).size, 
          'images/level_$gameLevel.jpg', 
          gameDificulty!, 
          gameLevel!, 
          movesRecord!,
          false
          )
        )
      ).then((value) async {      
        // await ;
      },);

    },);

  }

  Future<String?> _chooseImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Limita a escolha apenas para arquivos de imagem
    );

    String? filePath;

    if (result != null) {
      filePath = result.files.single.path;

      setState(() {});
      return filePath;
    }
    return null;
  }

  void _playSelectedImage(){
    
    _chooseImage().then((value) {      
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => DifficultyPage(
                    difficulty: 6,
                    customImagePath: value,
                  ))).then((value) {
          _initDifficultyDb();
        },
      ).then((value) {
        setState(() {
          isLoading = false;
        });    
      },);
    },);
    
    setState(() {
      isLoading = true;
    });    
      
  }

  void _difficultyPage() { // goes to page to select difficulty
    if (gameDificulty == null) {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DifficultyPage(
                  difficulty: gameDificulty!,
                ))).then(
      (value) {
        _initDifficultyDb();
      },
    );
  }

  Future _initLevelDb() async {
    // carregar dados do banco

    Level? level = await database_handler.getLevels(database);
    if (level != null) {
      gameLevel = level.level;
    } else {
      database_handler.upsertLevel(Level(date: DateTime.now().toString(), level: 1), database); // cria no banco com valor 10
      gameLevel = 1;
    }


    setState(() {});
  }

  void _initDifficultyDb() async {
    // carregar dados do banco

    Difficulty? difficulty = await database_handler.getDifficulty(database);
    if (difficulty != null) {
      gameDificulty = difficulty.difficulty;
    } else {
      database_handler.upsertDifficulty(Difficulty(date: DateTime.now().toString(), difficulty: 4), database); 
      gameDificulty = 4;
    }

    setState(() {});
  }

  void _initMovesRecordDb() async {
    Move? movesModel = await database_handler.getMoves(database);
    if (movesModel != null) {
      movesRecord = movesModel.moves;
    } else {
      database_handler.upsertMovementRecord(Move(date: DateTime.now().toString(), moves: 9999999), database); 
      movesRecord = 9999999;
    }
  }

  @override
  void initState() {
    _initLevelDb();
    _initDifficultyDb();
    _initMovesRecordDb();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    TextButton buttonWidget(String text, Function() function) {
      return TextButton(
          onPressed: function,
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Color.fromARGB(255, 25, 10, 88);
                  }
                  return const Color.fromARGB(255, 54, 21, 204);
                },
              ),
              padding: WidgetStateProperty.all(const EdgeInsets.all(15)),
              shape: WidgetStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))))),
          child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600)));
    }

    return Scaffold(
      body: Center(
        child: isLoading ? const CircularProgressIndicator() : Column(
          children: [
            SizedBox(height: screenSize.height * .3),
            const Text(
              "IMAZZLER",
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenSize.height * .1),
            buttonWidget("PLAY LEVELS", _playLevels),
            SizedBox(height: screenSize.height * .04),
            buttonWidget("CHOOSE IMAGE", _playSelectedImage),
            SizedBox(height: screenSize.height * .03),
            buttonWidget("DIFFICULTY", _difficultyPage),
          ],
        ),
      ),
    );
  }
}
