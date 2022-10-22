import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// SQLiteを使用する際は、下記のパッケージをimportして下さい。
// sqflite:
//  path:

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
    //SQLのコマンドは全て大文字で記述されている場合が多いのでそれに習います. 
    //sqfliteでSQL分の実行するにはexecuteというメソッドを使います.
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age TXT)",
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
        name: maps[i]['name'],
        age: maps[i]['age'],
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
    name: 'Fido',
    age: '35',
  );
  await insertDog(fido);


  fido = Dog(
    id: 1,
    name: 'Fido',
    age: '17',
  );

  // データベースにDogのデータを挿入
  await insertDog(fido);
  //await insertDog(bobo);

  print(await dogs());

  fido = Dog(
    id: fido.id,
    name: fido.name,
    age: fido.age + '7',
  );
  // データベース内のfidoを更新
  await updateDog(fido);

  // fidoのアップデートを表示
  print("updated DB");
  print(await dogs());
}

class Dog {
  final int id;
  final String name;
  final String age;

  Dog({required this.id, required this.name, required this.age});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
    };
  }

  //printで見やすくするための実装
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}


Map<String, dynamic> _portaInfoMap = {
    "name": "Vitalflux.com",
    "domains": ["Data Science", "Mobile", "Web"],
    "noOfArticles": [
      {"type": "data science", "count": 50},
      {"type": "web", "count": 75}
    ]
};


  class PortalInfo {
    final String name;
    final List<String> domains;
    final List<Object> noOfArtcles;
 
    PortalInfo({
      required this.name,
      required this.domains,
      required this.noOfArtcles
    });
 
  factory PortalInfo.fromJson(Map<String, dynamic> parsedJson){
    return PortalInfo(
        name: parsedJson['name'],
        domains : parsedJson['domains'],
        noOfArtcles : parsedJson ['noOfArticles']
    );
  }
}
