import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';

class searchAreas {
  searchAreas(this.areas, this.board);

  String areas;
  String board;
}

final searchAreas1 = {'areas': '1', 'areas': '2', 'Kawasaki': 25};

class Memo {
  final int id;
  final String searchAreas;
  final String searcBoardS;

  Memo(
      {required this.id, required this.searchAreas, required this.searcBoardS});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areas': searchAreas,
      'bord': searcBoardS,
    };
  }

  @override
  String toString() {
    return 'Memo{id: $id, areas: $searchAreas, bord $searcBoardS}';
  }

  static Future<Database> get database async {
    final Future<Database> _database = openDatabase(
      join(await getDatabasesPath(), 'memo_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE memo(id INTEGER PRIMARY KEY AUTOINCREMENT, text TEXT)",
        );
      },
      version: 1,
    );
    return _database;
  }

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
        searchAreas: maps[i]['areas'],
        searcBoardS: maps[i]['bord'],
      );
    });
  }

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

  static Future<void> deleteMemo(int id) async {
    final db = await database;
    await db.delete(
      'memo',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}

void main() {
  runApp(ToDo());
}

class ToDo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo SQL',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MySqlPage(),
    );
  }
}

class MySqlPage extends StatefulWidget {
  @override
  _MySqlPageState createState() => _MySqlPageState();
}

class _MySqlPageState extends State<MySqlPage> {
  List<Memo> _memoList = [];
  final myController = TextEditingController();
  final upDateController = TextEditingController();
  var _selectedvalue;

  Future<void> initializeDemo() async {
    _memoList = await Memo.getMemos();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('メモアプリ'),
      ),
      body: Container(
        padding: EdgeInsets.all(32),
        child: FutureBuilder(
          future: initializeDemo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 非同期処理未完了 = 通信中
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: _memoList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Text(
                      'ID ${_memoList[index].id}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text('${_memoList[index].searchAreas}'),
                    trailing: SizedBox(
                      width: 76,
                      height: 25,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Memo.deleteMemo(_memoList[index].id);
                          final List<Memo> memos = await Memo.getMemos();
                          setState(() {
                            _memoList = memos;
                          });
                        },
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          '削除',
                          style: TextStyle(fontSize: 11),
                        ),
                        //color: Colors.red,
                        //textColor: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Column(
        verticalDirection: VerticalDirection.up,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text("新規メモ作成"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('なんでも入力してね'),
                            TextField(controller: myController),
                            ElevatedButton(
                              child: Text('保存'),
                              onPressed: () async {
                                Memo _memo =
                                    Memo(id: 1, searchAreas: myController.text);
                                await Memo.insertMemo(_memo);
                                final List<Memo> memos = await Memo.getMemos();
                                setState(() {
                                  _memoList = memos;
                                  _selectedvalue = null;
                                });
                                myController.clear();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ));
            },
          ),
          SizedBox(height: 20),
          FloatingActionButton(
              child: Icon(Icons.update),
              backgroundColor: Colors.amberAccent,
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: StatefulBuilder(
                          builder:
                              (BuildContext context, StateSetter setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('IDを選択して更新してね'),
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: DropdownButton(
                                        hint: Text("ID"),
                                        value: _selectedvalue,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _selectedvalue = newValue;
                                            print(newValue);
                                          });
                                        },
                                        items: _memoList.map((entry) {
                                          return DropdownMenuItem(
                                              value: entry.id,
                                              child: Text(entry.id.toString()));
                                        }).toList(),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 3,
                                      child: TextField(
                                          controller: upDateController),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  child: Text('更新'),
                                  onPressed: () async {
                                    Memo updateMemo = Memo(
                                        id: _selectedvalue,
                                        searchAreas: upDateController.text);
                                    await Memo.updateMemo(updateMemo);
                                    final List<Memo> memos =
                                        await Memo.getMemos();
                                    super.setState(() {
                                      _memoList = memos;
                                    });
                                    upDateController.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    });
              }),
        ],
      ),
    );
  }
}
