import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import './highlighted_text.dart';

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

  // DBにデータを挿入するための関数です。
  static Future<void> insertMemo(Memo memo) async {
    final Database db = await database;
    await db.insert(
      'memo',
      memo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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


  Future<String> initializeDemo() async {
    _memoList = await Memo.getMemos();
    return Future.delayed(new Duration(seconds: 1), () {
      return "initializeDemo completed!!";
    });
  }

  final List<String> searchTargets =
      List.generate(10, (index) => 'Something ${index + 1}');

  List<String> searchResults = [];

  void search(String query, {bool isCaseSensitive = false}) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

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

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Items'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: FutureBuilder(
                future: initializeDemo(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                //  if (snapshot.connectionState == ConnectionState.waiting) {
                //    return Center(
                //      child: CircularProgressIndicator(),
                      //child: Text(snapshot.data),
                //    );
                //  } else {
                //    return Text(snapshot.data); //CircularProgressIndicator();
                //  }
                },
              ),
            ),
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
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter keyword'),
              onChanged: (String val) {
                search(val, isCaseSensitive: isCaseSensitive);
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
          ],
        ),
      ),
    );
  }
}
