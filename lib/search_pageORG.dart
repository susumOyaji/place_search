import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import './highlighted_text.dart';
import 'dart:io';

class Memo {
  final int id;
  final String text;
  final String rack;

  Memo({required this.id, required this.text, required this.rack});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'rack': rack,
    };
  }

  //printで見やすくするための実装
  @override
  String toString() {
    return 'Memo{id: $id, text: $text, rack: $rack}';
  }
} //class Memo

class SearchPageORG extends StatefulWidget {
  const SearchPageORG({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPageORG> {
  TextEditingController? controller;
  bool isCaseSensitive = false;
  List<Memo> _memoList = [];
  List widgets = [];
  bool isLoading = false; //テーブル読み込み中の状態を保有する
  List<Memo> _dowresponce = [];
  bool isFirst = true;
  bool isSecond = true;
  bool isThird = true;
  bool isSub = true;
  String hintText = 'Scanning to  Anything-Barcode';

  String isFirstString = "";
  String isSecondString = "";

  static Future<Database> get database async {
    final Future<Database> _database = openDatabase(
      // pathをデータベースに設定しています。
      // 'path'パッケージからの'join'関数を使用する事は、DBをお互い（iOS, Android）のプラットフォームに構築し、
      // pathを確保するのに良い方法です。
      join(await getDatabasesPath(), 'memo_database1.db'),

      // Memo テーブルのデータベースを作成しています。
      // ここではSQLの解説は省きます。
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT, rack TEXT)",
        );
      },
      version: 1,
    );
    return _database;
  }

  static Future<List<Memo>> getMemos() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('memo');
    return List.generate(maps.length, (i) {
      return Memo(
        id: maps[i]['id'],
        text: maps[i]['text'],
        rack: maps[i]['rack'],
      );
    });
  }

  // DBにデータを挿入するための関数です。
  static Future<void> insertMemo(Memo memo) async {
    final Database db = await database;
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // DB内にあるデータを更新するための関数
  static Future<void> updateMemo(Memo memo) async {
    final db = await database;
    await db.update(
      'memo',
      memo.toMap(),
      where: "id = ?",
      whereArgs: [memo.id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  // DBからデータを削除するための関数
  static Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete(
      'memo',
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Memo>> initializeMemo() async {
    _memoList = await getMemos();
    //return Future.delayed(const Duration(seconds: 3), () {
    return _memoList;
    //"initializeDemo completed!!";
    //});
  }

  // 具体的なデータ
  var fido = Memo(
    id: 0,
    rack: '35',
    text: '1',
  );

  /*
  var bobo = Dog(
    id: 1,
    location: 'Bobo',
    rack: '17',
    contaner: '2',
    part: '2',
  );
  */
  // データベースにDogのデータを挿入
  //insertData(fido);
  //await insertDog(bobo);

  // Stateのサブクラスを作成し、initStateをオーバーライドすると、wedgit作成時に処理を動かすことができる。
  // ここでは、初期処理としてCatsの全データを取得する。
  @override
  void initState() {
    super.initState();
    controller = TextEditingController();

    insertMemo(fido);
    _load();
    print(fido);
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  final List<String> searchTargets =
      List.generate(10, (index) => 'Something ${index + 1}');

  // 挿入
  //insertMemo(Memo memo);

  List<String> searchResults = [];

  //query to input Deta
  void search(String query, {bool isCaseSensitive = false}) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    if (isFirst == true) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      setState(() {
        isFirstString = query;
        searchResults.clear();
        isFirst = false;
        isSecond = true;

        hintText = 'Second to Barcode';
      });
      return;
    }

    if (isSecond == true) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      setState(() {
        isSecondString = query;
        searchResults.clear();
        isFirst = true;
        isSecond = false;
      });
    }

    if (isFirstString.startsWith('a') && isSecondString.startsWith('b')) {
      hintText = 'Good 1st. to Barcode';
    }
    if (isFirstString.startsWith('b') && isSecondString.startsWith('c')) {
      hintText = 'Good 2nd. to Barcode';
    }
    if (isFirstString.startsWith('c') && isSecondString.startsWith('d')) {
      hintText = 'Good 3nd. to Barcode';
    }

    switch (isFirstString.substring(0, 1)) {
      case 'a':
        if (isSecondString.startsWith('b')) {
          hintText = 'Good 1st. to Barcode';
        }
        break;
      case 'b':
        if (isSecondString.startsWith('c')) {
          hintText = 'Good 1st. to Barcode';
        }
        break;
      case 'c':
        if (isSecondString.startsWith('p')) {
          hintText = 'Good 1st. to Barcode';
        }
        break;
    }

    /*
    if (query.startsWith('c') && isThird == true) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      setState(() {
        isFirstString = query;
        searchResults.clear();
        isFirst = false;
        isSecond = false;
        isThird = true;
        hintText = 'Part. to Barcode';
      });
      return;
      //searcContaners.add(query);
      //container = container.toSet().toList(); //重複する要素を全て削除する
      //hitItems = searcContaners;
    }

    if (query.startsWith('p') && isThird == true) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      setState(() {
        isFirstString = query;
        searchResults.clear();
        isFirst = false;
        hintText = 'Contaner. to Barcode';
      });
      return;

      //searcParts.add(query);
      //parts = parts.toSet().toList(); //重複する要素を全て削除する
      //hitItems = searcParts;
    }
    */

    final List<String> hitItems = searchTargets.where((element) {
      if (isCaseSensitive) {
        return element.contains(query);
      }
      return element.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      searchResults = hitItems;
    });
  }

  // initStateで動かす処理。
  // catsテーブルに登録されている全データを取ってくる
  void _load() async {
    setState(() => isLoading = true); //テーブル読み込み前に「読み込み中」の状態にする
    _dowresponce = await initializeMemo(); ////catsテーブルを全件読み込む
    setState(() => isLoading = false); //「読み込み済」の状態にする
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SqlApp'),
      ),
      body: isLoading //「読み込み中」だったら「グルグル」が表示される
          ? const Center(
              child: CircularProgressIndicator(), // これが「グルグル」の処理
            )
          : Column(
              children: [
                SwitchListTile(
                  title: const Text('Case Sensitive'),
                  value: isCaseSensitive,
                  onChanged: (bool newVal) {
                    setState(() {
                      isCaseSensitive = newVal;
                    });
                    search(controller!.text, isCaseSensitive: newVal);
                  },
                ),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'FirstString: ${isFirstString}   \nSecondString: ${isSecondString}'),
                  ],
                )),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    enabledBorder: OutlineInputBorder(
                        //何もしていない時の挙動、見た目
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.greenAccent,
                        )),
                    focusedBorder: OutlineInputBorder(
                        //フォーカスされた時の挙動、見た目
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(
                          color: Colors.amber,
                        )),
                  ),
                  onChanged: (String val) {
                    //ユーザーがデバイス上でTextFieldの値を変更した場合のみ発動される.
                    search(val, isCaseSensitive: isCaseSensitive);
                    controller?.clear(); //リセット処理
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: HighlightedText(
                        wholeString: searchResults[index],
                        highlightedString: controller!.text,
                        isCaseSensitive: isCaseSensitive,
                      ),
                    );
                  },
                ),
                Text(_dowresponce.toString()),
              ],
            ),
    );
  }
}
