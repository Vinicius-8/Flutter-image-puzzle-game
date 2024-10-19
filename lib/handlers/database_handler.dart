import 'dart:async';

import 'package:imazzler/models/difficulty_model.dart';
import 'package:imazzler/models/level_model.dart';
import 'package:imazzler/models/move_model.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> openDB() async {  
  final database = openDatabase(
    join(await getDatabasesPath(), 'database.db'),
    onCreate: (db, version) async {
      
      await db.execute(
        "CREATE TABLE level(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, level INTEGER)",
      );
      
      await db.execute(
        "CREATE TABLE difficulty(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, difficulty INTEGER)",
      );      
      
      await db.execute(
        "CREATE TABLE moves_record(id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, moves INTEGER)",
      );      
    },
    version: 1,
  );
  
  return database;
}

Future<void> insertLevel(Level level, final database) async {
  final Database db = await database;

  await db.insert(
    'level',
    level.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<void> insertDifficulty(Difficulty difficulty, final database) async {
  final Database db = await database;

  await db.insert(
    'difficulty',
    difficulty.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}

Future<Level?> getLevels(final database) async {
  // Get a reference to the database.
  final Database db = await database;

  // Query the table for all The Dogs.
  final List<Map<String, dynamic>> maps = await db.query('level');

  
  try {
    Level le =  List.generate(maps.length, (i) {
      return Level(
        id: maps[i]['id'],
        date: maps[i]['date'],
        level: maps[i]['level'],
      );
    }).first;

    return le;

    
  } catch (e) {
    return null;
  }
}

Future<Difficulty?> getDifficulty(final database) async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('difficulty');

  try {
    Difficulty di = List.generate(maps.length, (i) {
      return Difficulty(
        id: maps[i]['id'],
        date: maps[i]['date'],
        difficulty: maps[i]['difficulty'],
      );
    }).first;
    return di;    
  } catch (e) {
    return null;
  }

}

Future<Move?> getMoves(final database) async {
  final Database db = await database;

  final List<Map<String, dynamic>> maps = await db.query('moves_record');

  try {
    Move mv = List.generate(maps.length, (i) {
      return Move(
        id: maps[i]['id'],
        date: maps[i]['date'],
        moves: maps[i]['moves'],
      );
    }).first;
    return mv;    
  } catch (e) {
    return null;
  }

}

Future<void> upsertDifficulty(Difficulty difficulty, final database) async {
  final Database db = await database;

  Difficulty? existingDifficulty = await getDifficulty(db);
  
  if (existingDifficulty == null) {
    // Se não existir, insere um novo registro
    await db.insert(
      'difficulty',
      difficulty.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  } else {
    // Se existir, atualiza o registro existente
    final existingId = existingDifficulty.id;
    
    await db.update(
      'difficulty',
      difficulty.toMap()..['id'] = existingId,
      where: "id = ?",
      whereArgs: [existingId],
    );
  }
}

Future<void> upsertLevel(Level level, final database) async {
  final Database db = await database;

  Level? existingLevel = await getLevels(db);
  
  if (existingLevel == null) {
    // Se não existir, insere um novo registro
  
    await db.insert(
      'level',
      level.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  } else {
    // Se existir, atualiza o registro existente
    final existingId = existingLevel.id;
  
    await db.update(
      'level',
      level.toMap()..['id'] = existingId,
      where: "id = ?",
      whereArgs: [existingId],
    );
  }
}

Future<void> upsertMovementRecord(Move moves, final database) async {
  final Database db = await database;

  Move? existingMove = await getMoves(db);
  
  if (existingMove == null) {
    // Se não existir, insere um novo registro
  
    await db.insert(
      'moves_record',
      moves.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  } else {
    // Se existir, atualiza o registro existente
    final existingId = existingMove.id;
  
    await db.update(
      'moves_record',
      moves.toMap()..['id'] = existingId,
      where: "id = ?",
      whereArgs: [existingId],
    );
  }
}
