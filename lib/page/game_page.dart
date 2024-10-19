import 'dart:math';

import 'package:flutter/material.dart';
import 'package:imazzler/magic/game_engine.dart';
import 'package:imazzler/magic/game_painter.dart';
import 'package:imazzler/magic/image_node.dart';
import 'package:imazzler/magic/puzzle_magic.dart';
import 'package:imazzler/handlers/database_handler.dart' as database_handler;
import 'package:imazzler/models/level_model.dart';
import 'package:imazzler/models/move_model.dart';

// ignore: must_be_immutable
class GamePage extends StatefulWidget {
  final Size size;
  final String imgPath; // imagem carregada para separação
  final int level;
  final int gameLevelValue;
  final int movementRecord;
  bool isCustomImage = false;

  GamePage(this.size, this.imgPath, this.level, this.gameLevelValue, this.movementRecord, this.isCustomImage, {super.key});

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return GamePageState(size, imgPath, level, gameLevelValue, movementRecord, isCustomImage);
  }
}

enum Direction { none, left, right, top, bottom }

enum GameState { loading, play, complete, over }

class GamePageState extends State<GamePage> with TickerProviderStateMixin {
  final database = database_handler.openDB();
  final Size size;
  var image;
  late PuzzleMagic puzzleMagic;
  late List<ImageNode> nodes; // puzzle pieces

  late Animation<int> alpha;
  late AnimationController controller;
  late Map<int, ImageNode> nodeMap = Map();

  late int level; // dificulty level
  late String path;
  ImageNode? hitNode;

  late double downX = 0.0, downY = 0.0, newX = 0.0, newY = 0.0;
  late int emptyIndex;
  late Direction direction = Direction.none;
  late bool needdraw = true;
  late List<ImageNode> hitNodeList = [];

  GameState gameState = GameState.loading;

  int moveCounter = 0;
  int gameLevel = 0; //
  late String imageLevelPath = 'images/level_$gameLevel.jpg'; // actual level
  int lessMovesRecord = 9999999;
  bool isCustomGame = false;

  // ads related  
  int levelsAvaliable = 7;

  GamePageState(this.size, this.path, this.level, gameLevelValue, movesRecord, isCustomImagePath, {showInterstitialAd}) {
    puzzleMagic = PuzzleMagic();
    emptyIndex = level * level - 1; // dificulty level
    gameLevel = gameLevelValue; // level 1, 2, 3
    lessMovesRecord = movesRecord;
    isCustomGame = isCustomImagePath;
    

    
    puzzleMagic.init(path, size, level, isCustomImagePath).then((val) async {
      nodes = await puzzleMagic.generatePuzzlePieces();
      setState(() {
        hitNode = nodes.first;
        GameEngine.makeRandom(nodes);
        setState(() {
          gameState = GameState.play;
        });
        showStartAnimation();
      });
    }).onError((error, stackTrace) {            
    
      if((levelsAvaliable + 1) <= gameLevel){
        // end of levels
        
        setState(() {
          gameState = GameState.over;  
        });   
        database_handler.upsertLevel(Level(date: DateTime.now().toString(), level: 1), database);    
        gameLevel = 1;   
      }

    },);
      
    
  }

  Widget _congratulationsWidget(){
    bool showRercord = false;
    if (moveCounter < lessMovesRecord) {
      // do stuff
      showRercord = true;
      lessMovesRecord = moveCounter;
      if(!isCustomGame){
        database_handler.upsertMovementRecord(Move(date: DateTime.now().toString(), moves: moveCounter), database); 
      }
    }


    return Center(
      child: Column(
        children: [
          Image.asset("images/resources/congrats.png", 
          
            width: 250,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.low,
          ),
          const SizedBox(height: 20,),

          const Text("Congratulations!!", style: TextStyle(fontSize: 30)),
          const SizedBox(height: 5,),

          !showRercord ? const SizedBox() : const Text("New record!!", style: TextStyle(fontSize: 15)),
          Text("You beat the level with $moveCounter moves.", style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 30,),
        ],
      )
    );
  }

  bool _shoudSave = true;
  void _saveLevelInDatabase() {    
    if(!isCustomGame && _shoudSave){
      database_handler.upsertLevel(Level(date: DateTime.now().toString(), level: ++gameLevel), database);
      _shoudSave = false;
    }
  }

  Widget _gameOverWidget(){

    // reset the levels
    if(!isCustomGame){
      // nao é custom
      database_handler.upsertLevel(Level(date: DateTime.now().toString(), level: 1), database);    
      gameLevel = 1;
    } else {
      // é custom      
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("GAME OVER", style: TextStyle(fontSize: 30),),
          const Text("Looks like you beat them all.", style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 43, 17, 158)),),
          const SizedBox(height: 25,),
          Transform.scale(
            scale: .8,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
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
              child: const Text("EXIT", style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w600))))
        ],
      ),
    );
  }

  Widget _nextLevelWidget()  {
    _saveLevelInDatabase(); 

    
    return Center(
       child: Column(        
        mainAxisAlignment: MainAxisAlignment.center,
         children: [
          _congratulationsWidget(),          
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              
              if(!isCustomGame){
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => GamePage(size, 'images/level_$gameLevel.jpg', level, gameLevel, lessMovesRecord, false,),
                  ),
                );
              }
            },
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
            child: isCustomGame
            ? const Text("Exit", style:  TextStyle(fontSize: 25, fontWeight: FontWeight.w600))
            : const Text("Next Level", style:  TextStyle(fontSize: 25, fontWeight: FontWeight.w600))),
         ],
       ),
     ); 
    
  }

  Widget _stateWidget(){
    if (gameState == GameState.loading) {
      return const Center(
        child: CircularProgressIndicator(),        
      );
    } else if (gameState == GameState.complete) {
      return _nextLevelWidget();
    } else if (gameState == GameState.over){
      return _gameOverWidget();
    } else {
      return Stack(
        children: [
          GestureDetector(
            onPanDown: onPanDown,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanUp,
            child: CustomPaint(painter: GamePainter(nodes, level, hitNode, hitNodeList, direction, downX, downY, newX, newY, needdraw), size: Size.infinite),
          ),
          Container(
            padding: EdgeInsets.only(top: (MediaQuery.of(context).size.height * .13)),
            alignment: Alignment.topCenter,
            
            child: IgnorePointer(
              child:   Column(
                children: [
                  isCustomGame ? const SizedBox() : Text("Level: $gameLevel", style: const TextStyle(fontSize: 25),),
                  Text("Moves: $moveCounter", style: const TextStyle(fontSize: 20),),
                ],
              ),            
            ),
          ),
          
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      body: _stateWidget(),      
    );
  }

 

  @override
  void initState() {
      
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});      
    });
  }
  

  @override
  void dispose() {
    try {
      controller.dispose();      
    } catch (e) {
      //
    }
    super.dispose();
  }

  void showStartAnimation() {
    needdraw = true;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    alpha = IntTween(begin: 0, end: 100).animate(controller);
    nodes.forEach((node) {
      nodeMap[node.curIndex] = node;

      Rect rect = node.rect;
      Rect dstRect = puzzleMagic.getOkRectF(node.curIndex % level, (node.curIndex / level).floor());

      final double deltX = dstRect.left - rect.left;
      final double deltY = dstRect.top - rect.top;

      final double oldX = rect.left;
      final double oldY = rect.top;

      alpha.addListener(() {
        double oldNewX2 = alpha.value * deltX / 100;
        double oldNewY2 = alpha.value * deltY / 100;
        setState(() {
          node.rect = Rect.fromLTWH(oldX + oldNewX2, oldY + oldNewY2, rect.width, rect.height);
        });
      });
    });
    alpha.addStatusListener((AnimationStatus val) {
      if (val == AnimationStatus.completed) {
        needdraw = true;
        // Força uma renderização final após a animação inicial
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    });
    controller.forward();    
  }

  void onPanDown(DragDownDetails details) {
    if (controller.isAnimating) {
      return;
    }    
    needdraw = true;
    RenderBox referenceBox = context.findRenderObject() as RenderBox;
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    for (int i = 0; i < nodes.length; i++) {
      ImageNode node = nodes[i];
      if (node.rect.contains(localPosition)) {        
        hitNode = node;
        direction = isBetween(hitNode!, emptyIndex);
        if (direction != Direction.none) {          ;
          newX = downX = localPosition.dx;
          newY = downY = localPosition.dy;
          nodes.remove(hitNode);
          nodes.add(hitNode!);
        }
        
        setState(() {});
        break;
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (hitNode == null) {
      return;
    }    

    RenderBox referenceBox = context.findRenderObject() as RenderBox;
    Offset localPosition = referenceBox.globalToLocal(details.globalPosition);
    newX = localPosition.dx;
    newY = localPosition.dy;
    if (direction == Direction.top) {
      newY = min(downY, max(newY, downY - hitNode!.rect.width));
    } else if (direction == Direction.bottom) {
      newY = max(downY, min(newY, downY + hitNode!.rect.width));
    } else if (direction == Direction.left) {
      newX = min(downX, max(newX, downX - hitNode!.rect.width));
    } else if (direction == Direction.right) {
      newX = max(downX, min(newX, downX + hitNode!.rect.width));
    }
    setState(() {});
  }

  void onPanUp(DragEndDetails details) {    
    if (hitNode == null) {
      return;
    }
    needdraw = false;
    if (direction == Direction.top) {
      if (-(newY - downY) > hitNode!.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.bottom) {
      if (newY - downY > hitNode!.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.left) {
      if (-(newX - downX) > hitNode!.rect.width / 2) {
        swapEmpty();
      }
    } else if (direction == Direction.right) {
      if (newX - downX > hitNode!.rect.width / 2) {
        swapEmpty();
      }
    }

    hitNodeList.clear();
    hitNode = null; // Reinicializa hitNode

    var isComplete = true;
    nodes.forEach((node) {
      if (node.curIndex != node.index) {
        isComplete = false;
      }
    });
    if (isComplete) {
      gameState = GameState.complete;
    }

    setState(() {});    
  }

  Direction isBetween(ImageNode node, int emptyIndex) {    
    int x = emptyIndex % level;
    int y = (emptyIndex / level).floor();

    int x2 = node.curIndex % level;
    int y2 = (node.curIndex / level).floor();

    if (x == x2) {
      if (y2 < y) {
        for (int index = y2; index < y; ++index) {
          hitNodeList.add(nodeMap[index * level + x]!);
        }
        return Direction.bottom;
      } else if (y2 > y) {
        for (int index = y2; index > y; --index) {
          hitNodeList.add(nodeMap[index * level + x]!);
        }
        return Direction.top;
      }
    }
    if (y == y2) {
      if (x2 < x) {
        for (int index = x2; index < x; ++index) {
          hitNodeList.add(nodeMap[y * level + index]!);
        }
        return Direction.right;
      } else if (x2 > x) {
        for (int index = x2; index > x; --index) {
          hitNodeList.add(nodeMap[y * level + index]!);
        }
        return Direction.left;
      }
    }
    return Direction.none;
  }

  void swapEmpty() {
    int v = -level;
    if (direction == Direction.right) {
      v = 1;
    } else if (direction == Direction.left) {
      v = -1;
    } else if (direction == Direction.bottom) {
      v = level;
    }
    
    ++moveCounter;    
    hitNodeList.forEach((node) {
      node.curIndex += v;
      nodeMap[node.curIndex] = node;
      node.rect = puzzleMagic.getOkRectF(node.curIndex % level, (node.curIndex / level).floor());
    });
    emptyIndex -= v * hitNodeList.length;
  }
}
