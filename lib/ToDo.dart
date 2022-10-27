import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path/path.dart';
import './highlighted_text.dart';

// SQLiteを使用する際は、下記のパッケージをimportして下さい。
// sqflite:
//  path:

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

void main() {
  runApp(ToDo());
}

class ToDo extends StatelessWidget {
  const ToDo({Key? key}) : super(key: key);
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
  TextEditingController? controller;
  bool isCaseSensitive = false;
  List<String> searchResults = [];
  var frower = [];
  var area = [];
  var board = [];
  var container = [];
  List<String> parts = [];
  var frameworks = <String, String>{};
  var fast = true;
  List<int> searchAreas = List.generate(10, (index) => index + 1);

  List<String> searcBoardS = List.generate(30, (index) => 'B ${index + 1}');

  List<String> searcContaners = List.generate(120, (index) => 'C ${index + 1}');

  List<String> searcParts = List.generate(1200, (index) => 'P ${index + 1}');

  String _text = '';

  Future<String> initializeDemo() async {
    _memoList = await Memo.getMemos();
    return Future.delayed(new Duration(seconds: 1), () {
      return "initializeDemo completed!!";
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void _savewrdo(String Word) {
    if (fast) {
      var farst = Word;
      _text = "Fast parameters"+ Word;
      print('Fast: $Word');
      fast = !fast;
      print(fast);
    } else {
      var second = Word;
      print('Second: $Word');
      fast = !fast;
      print(fast);
    }
  }

  void search(String query, {bool isCaseSensitive = false}) {
    List<String> hitItems = [];

    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }
    if (query.startsWith('A')) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      //searchAreas.add(query);
      //area = area.toSet().toList(); //重複する要素を全て削除する
      //hitItems = searchAreas;
    }

    if (query.startsWith('B')) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      searcBoardS.add(query);
      //board = board.toSet().toList(); //重複する要素を全て削除する
      hitItems = searcBoardS;
    }

    if (query.startsWith('C')) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      searcContaners.add(query);
      //container = container.toSet().toList(); //重複する要素を全て削除する
      hitItems = searcContaners;
    }

    if (query.startsWith('P')) {
      // 指定した文字列(パターン)で始まるか否かを調べる。
      searcParts.add(query);
      //parts = parts.toSet().toList(); //重複する要素を全て削除する
      hitItems = searcParts;
    }

    /*
    final List<String> hitItems = searchAreas.where((element) {
      if (isCaseSensitive) {
        return element.contains(query);
      }
      return element.toLowerCase().contains(query.toLowerCase());
    }).toList();
    */
    setState(() {
      searchResults = hitItems;
      //list[0][0][0].addAll(searchAreas);
      //list.insert(2,[][][]);

      //print(list[0][0][1]);
      //print(list);
    });
  }

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  /*
  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }
  */
  void _handleText(String e) {
    setState(() {
      _text = e;
    });
  }

  Future<String> sampleFutureFunc() async {
    return Future.delayed(new Duration(seconds: 5), () {
      return "completed!!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SqlApp'),
      ),
      body: Column(
        children: [
          Center(
            child: FutureBuilder(
              future: initializeDemo(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Center(
                    child: Text(snapshot.data),
                  );
                } else {
                  return CircularProgressIndicator();
                }
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
          Text(
            "$_text",
            style: TextStyle(
                color: Colors.orangeAccent,
                fontSize: 20.0,
                fontWeight: FontWeight.w500),
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter Barcodeword',
              enabledBorder: OutlineInputBorder(
                  //何もしていない時の挙動、見た目
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.greenAccent,
                  )),
              focusedBorder: OutlineInputBorder(
                  //フォーカスされた時の挙動、見た目
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.amber,
                  )),
            ),
            onSubmitted: (searchWord) {
              //ユーザーがフィールドのテキストの編集を完了(return key to push)したことを示したときに呼び出されます
              _handleText(searchWord);
              _savewrdo(searchWord);
              controller!.clear();
            },
            onChanged: (String val) {
              //ユーザーがデバイス上でTextFieldの値を変更した場合のみ発動される.
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
    );

    /*SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: FutureBuilder(
                future: initializeDemo(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text('snapshot.data'),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
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
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter Barcodeword',
                enabledBorder: OutlineInputBorder(
                    //何もしていない時の挙動、見た目
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                    )),
                focusedBorder: OutlineInputBorder(
                    //フォーカスされた時の挙動、見た目
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.amber,
                    )),
              ),
              onSubmitted: (searchWord) {
                _savewrdo(searchWord);
                controller!.clear();
              },
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
      */
    /*
          Container(
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
          Column(
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
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter Barcodeword',
                enabledBorder: OutlineInputBorder(
                    //何もしていない時の挙動、見た目
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.greenAccent,
                    )),
                focusedBorder: OutlineInputBorder(
                    //フォーカスされた時の挙動、見た目
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: Colors.amber,
                    )),
              ),
              onSubmitted: (searchWord) {
                _savewrdo(searchWord);
                controller!.clear();
              },
              onChanged: (String val) {
                search(val, isCaseSensitive: isCaseSensitive);
              },
            ),
            ListView.builder(
              itemCount: _memoList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Text(
                      'ID ${_memoList[index].id}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    title: Text(
                        '${_memoList[index].text}   ${_memoList[index].rack}'),
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
                        title: Text("新規作成"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Entry'),
                            TextField(controller: myController),
                            TextField(controller: myController),
                            ElevatedButton(
                              child: Text('保存'),
                              onPressed: () async {
                                Memo _memo = Memo(
                                    id: _memoList.length,
                                    text: myController.text,
                                    rack: 'Input rack');
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
                                        text: upDateController.text,
                                        rack: 'input2 rack');
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
    */
  }
}
