import 'package:flutter_quill/quill_delta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class NoteDatabase {
  static final NoteDatabase _instance = NoteDatabase._internal();
  factory NoteDatabase() => _instance;

  NoteDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'notes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            subject TEXT,
            content TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertNote(
    String subject,
    List<Map<String, dynamic>> delta,
  ) async {
    final db = await database;
    final contentJson = jsonEncode(delta);

    await db.insert('notes', {
      'subject': subject,
      'content': contentJson,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateNote(
    String subject,
    List<Map<String, dynamic>> delta,
  ) async {
    final db = await database;
    final contentJson = jsonEncode(delta);

    await db.update(
      'notes',
      {'content': contentJson},
      where: 'subject = ?',
      whereArgs: [subject],
      conflictAlgorithm: ConflictAlgorithm.replace, // optional
    );
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    final db = await database;
    return await db.query('notes');
  }

  Future<Map<String, dynamic>?> getNoteBySubject(String subject) async {
    final db = await database;
    final result = await db.query(
      'notes',
      where: 'subject = ?',
      whereArgs: [subject],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
