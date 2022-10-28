import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// SQLiteを使用する際は、下記のパッケージをimportして下さい。
// sqflite:
//  path:

class Dog {
  final int id;
  final String location;
  final String rack;
  final String contaner;
  final String part;

  Dog(
      {required this.id,
      required this.location,
      required this.rack,
      required this.contaner,
      required this.part});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Location': location,
      'Rack': rack,
      'Contaner': contaner,
      'Part': part,
    };
  }

  //printで見やすくするための実装
  @override
  String toString() {
    return 'Dog{id: $id, Location: $location, Rack: $rack, Contaner: $contaner, Part:$part}';
  }
} //DogClass

void main() async {
  // このソースコードはWidgetで視覚化しておらず、結果は全てコンソール上に出力しています。
  // 出力結果は最後に表示させます。
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    // pathをデータベースに設定しています。
    // 'path'パッケージからの'join'関数を使用する事は、DBをお互い（iOS, Android）のプラットフォームに構築し、
    // pathを確保するのに良い方法です。
    join(await getDatabasesPath(), 'doggie_database.db'),

    // dogs テーブルのデータベースを作成しています。
    // ここではSQLの解説は省きます。
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE dogs(id INTEGER PRIMARY KEY AUTOINCREMENT, Location TEXT, Rack TEXT, Contaner TEXT, Part TEXT )",
      );
    },
    // version 1のSQLiteを使用します。
    version: 1,
  );

  // DBにデータを挿入するための関数です。
  Future<void> insertDog(Dog dog) async {
    // データベースのリファレンスを取得します。
    final Database db = await database;
    // テーブルにDogのデータを入れます。
    await db.insert(
      'dogs',
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> dogs() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dogs');
    return List.generate(maps.length, (i) {
      return Dog(
        id: maps[i]['id'],
        location: maps[i]['Location'],
        rack: maps[i]['Rack'],
        contaner: maps[i]['Cantaner'],
        part: maps[i]['part'],
      );
    });
  }

  // DB内にあるデータを更新するための関数
  Future<void> updateDog(Dog dog) async {
    final db = await database;

    await db.update(
      'dogs',
      dog.toMap(),
      where: "id = ?",
      whereArgs: [dog.id],
    );
  }

  // DBからデータを削除するための関数
  Future<void> deleteDog(int id) async {
    // Get a reference to the database.
    final db = await database;

    // データベースからdogのデータを削除する。
    // 今回は使用していない。
    await db.delete(
      'dogs',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // 具体的なデータ
  var fido = Dog(
    id: 0,
    location: 'Fido',
    rack: '35',
    contaner: '1',
    part: '1',
  );

  var bobo = Dog(
    id: 1,
    location: 'Bobo',
    rack: '17',
    contaner: '2',
    part: '2',
  );

  // データベースにDogのデータを挿入
  await insertDog(fido);
  await insertDog(bobo);

  print(await dogs());

  fido = Dog(
    id: fido.id,
    location: fido.location,
    rack: fido.rack + '7',
    contaner: '',
    part: '',
  );
  // データベース内のfidoを更新
  await updateDog(fido);

  // fidoのアップデートを表示
  print("updated DB");
  print(await dogs());
}
