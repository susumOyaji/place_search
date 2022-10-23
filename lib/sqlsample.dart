/*
概要
このブログポストでは、Flutterでユーザデバイスにデータを保存するためSQLiteを使う方法について説明します。
FlutterでSQLiteを使うためにはsqfliteパッケージを使います。

sqfliteインストール
FlutterでSQLiteを使うためsqfliteパッケージをインストールする必要があります。次のコマンドを使ってsqfliteパッケージをインストールします。

flutter pub add sqflite

DB準備
Flutterでsqfliteパッケージを使ってSQLite DBを使うため、DBを準備する方法について説明します。

DBオープン
SQLiteを使うためにはSQLite DBをオープンする必要があります。次のコードを使ってSQLite DBをオープンすることができます。
*/
import 'package:sqflite/sqflite.dart';
//...
var db = await openDatabase('my_db.db');
//...
/*
openDatabaseに指定したDBファイルが存在すると、当該DBをオープンします。存在しない場合は、DBファイルを生成してDBをオープンします。
DBファイルはアンドロイドの場合、基本Databaseディレクトリに、iOSの場合はdcoumentsディレクトリに生成されます。

DBクローズ
sqfliteパッケージのopenDatabaseを使ってSQLiteデータベースをオープンして使う場合、アプリが終了されると、オープンされたDBのアクセスも自動でクローズされます。
もし、アプリ終了と一緒にDBのアクセスをクローズするではなく、特定したタイミングでクローズしたい場合、次のコードを使います。

...
await db.close();
...

既存DBを使う場合
sqfliteパッケージを使って、事前に作ったSQLite DBを使うこともできます。
まず、事前に作ったSQLite DBをassets/フォルダにコピーします。その後、pubspec.yamlファイルを開いて下記のように修正します。

assets:
  - assets/data.db
*/

//そして、次のようにSQLite DBが存在しない場合、事前に作ったDBをコピーして使えるようにすることができます。

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> getDB() async {
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, '~www/data.db');
  var exists = await databaseExists(path);

  if (!exists) {
    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    var data = await rootBundle.load(join('assets', 'data.db'));
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(bytes, flush: true);
  }

  return await openDatabase(path);
}

//使い方
//sqfliteを使ってSQLite DBにデータをCRUD(Create, Read, Update, Delete)する方法について説明します。

//モデルクラス
//FlutterでSQLiteにデータを保存したり使うためモデルクラスを定義して使うことができます。
//これはSQLiteを使うため必須条件ではなく、SQLiteからデータを取ってくる時、またはデータを追加する時、もっt明確にするため使います。

//モデルを使うクラスは下記のように作成します。
class Rack {
  final int rack_id;
  final String container_code;


  Rack({
    required this.rack_id,
    required this.container_code,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': rack_id,
      'name': container_code,
    };
  }

  @override
  String toString() {
    return 'Dog{id: $rack_id, name: $container_code}';
  }
}


//Select
//次のようにモデルクラスとsqfliteを使ってSQLite DBに保存されたデータを取ってくることができます。

final List<Map<String, dynamic>> maps = await db.query('dogs');
// final List<Map<String, dynamic>> maps = await db.rawQuery(
//   'SELECT id, name, age FROM dogs',
// );

return List.generate(maps.length, (i) {
  return Dog(
    id: maps[i]['rack_id'],
    name: maps[i]['container_code'],
  );
});


//Insert
//次のようにモデルクラスとsqfliteを使ってSQLite DBにデータを追加することができます。

var rack = Rack(
  rack_id: 0,
  container_code: 'C001',
);

await db.insert('rack', rack.toMap());
// await db.rawInsert('INSERT INTO dogs(id, name, age) VALUES (${dog.id}, "${dog.name}", ${dog.age})');


//Update
//次のようにモデルクラスとsqfliteを使ってSQLite DBにデータを更新することができます。
await db.update('rack', rack.toMap(), where: 'id = ?', whereArgs: [rack.id]);
// await db.rawUpdate('UPDATE dogs SET age = ${dog.age} WHERE id = ${dog.id}');

//Delete
//次のようにsqfliteを使ってSQLite DBにあるデータを削除することができます。
await db.delete('rack', where: 'id = ?', whereArgs: [rack_id]);
// await database.rawDelete('DELETE FROM dogs WHERE id = ?', [id]);

//テスト
//SQLiteは基本的ユーザのデバイスにDBが生成されて、
//sqfliteパッケージはデバイスで動作されるように設計されてますので、ユニットテスト(Unit Test)することができません。
//しかし、sqflite_ffiを使って、テストコードで直接DBをオープンしてCRUDクエリ(Query)をテストすることはできます。

//準備
//次のように実際使ってるSQLite DBをコピーとsqflite_ffiを初期化して、テストする環境を準備します。

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void copyFile(String path, String newPath) {
  File(path).copySync(newPath);
}

void main() {
  sqfliteFfiInit();
  setUp(() {
    File(join('assets', 'my_db.db')).copySync(join('assets', 'test.db'));
  });

  ...
}


//Selectテスト
//次のようにsqflite_ffiを使ってSelectクエリをテストすることができます。
//...

void main() {
  //...
  test('Select', () async {
    var db = await databaseFactoryFfi.openDatabase('../../../assets/test.db');
    var dataProvider = DataProvider(db: db);

    var maps = await db.query('rack');
    var list = List.generate(maps.length, (i) {
      return Rack(
        rack_id: maps[i]['id'],
        container_code: maps[i]['name'],
      );
    });

    expect(list[0].toMap(), {'id': 0, 'name': 'Fido'});
  });
  //...
}



//Insertテスト
//次のようにsqflite_ffiを使ってInsertクエリをテストすることができます。

...
void main() {
  ...
  test('Insert', () async {
    var db = await databaseFactoryFfi.openDatabase('../../../assets/test.db');
    var dataProvider = DataProvider(db: db);

    var dog = Dog(
      id: 1,
      name: 'Fido',
      age: 35,
    );
    await db.insert('dogs', dog.toMap());

    var maps = await db.rawQuery(
      'SELECT name FROM dogs WHERE id=${dog.id}',
    );
    expect(maps[0].name, dog.name);
  });
  ...
}



Updateテスト
次のようにsqflite_ffiを使ってUpdateクエリをテストすることができます。

...
void main() {
  ...
  test('Update', () async {
    var db = await databaseFactoryFfi.openDatabase('../../../assets/test.db');
    var dataProvider = DataProvider(db: db);

    var dog = Dog(
      id: 0,
      name: 'Fido',
      age: 10,
    );
    await db.update('dogs', dog.toMap(), where: 'id = ?', whereArgs: [dog.id]);

    var maps = await db.rawQuery(
      'SELECT age FROM dogs WHERE id=$dog.id',
    );
    expect(maps[0].age, 10);
  });
  ...
}


Deleteテスト
次のようにsqflite_ffiを使ってDeleteクエリをテストすることができます。

...
void main() {
  ...
  test('Delete', () async {
    var db = await databaseFactoryFfi.openDatabase('../../../assets/test.db');
    var dataProvider = DataProvider(db: db);

    var dog = Dog(
      id: 0,
      name: 'Fido',
      age: 35,
    );
    await db.delete('dogs', where: 'id = ?', whereArgs: [id]);

    var maps = await db.rawQuery(
      'SELECT * FROM dogs WHERE id=$dog.id',
    );
    expect(maps.length, 0);
  });
}


完了
これでFlutterでSQLiteを使うためsqfliteパッケージを使う方法についてみてみました。皆さんもSQLiteを使ってユーザのデバイスにデータを保存して使ってみてください。


