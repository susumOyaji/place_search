import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  final database = openDatabase(
    join(await getDatabasesPath(), 'memo_database.db'),
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE memo(id INTEGER PRIMARY KEY, text TEXT, priority INTEGER)",
      );
    },
    version: 1,
  );

  Future<void> insertMemo(Memo memo) async {
    final Database db = await database;
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Memo>> getMemos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('memo');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        priority: maps[i]['priority'],
      );
    });
  }

  Future<void> updateMemo(Memo memo) async {
    // Get a reference to the database.
    final db = await database;
    await db.update(
      'memo',
      memo.toMap(),
      where: "id = ?",
      whereArgs: [memo.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete(
      'memo',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  var memo = Memo(
    id: 0,
    text: 'Flutterで遊ぶ',
    priority: 1,
  );

  await insertMemo(memo);

  print(await getMemos());

  memo = Memo(
    id: memo.id,
    text: memo.text,
    priority: memo.priority + 1,
  );
  await updateMemo(memo);

  // Print Fido's updated information.
  print(await getMemos());

  // Delete Fido from the database.
  await deleteMemo(memo.id);

  // Print the list of dogs (empty).
  print(await getMemos());
}

class Memo {
  final int id;
  final String text;
  final int priority;

  Memo({required this.id, required this.text, required this.priority});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'priority': priority,
    };
  }

  @override
  String toString() {
    return 'Memo{id: $id, tet: $text, priority: $priority}';
  }
}
