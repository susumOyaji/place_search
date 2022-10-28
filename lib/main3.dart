import 'package:flutter/material.dart';
import '/database_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DataPage(),
    );
  }
}

class DataPage extends StatelessWidget {
  // database_helper.dartのDataBaseHelperをインスタンス化
  final dbHelper = DatabaseHelper.instance;

  // 画面作成
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('sqflite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: const Text(
                'insert',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _insert();
              },
            ),
            ElevatedButton(
              child: const Text(
                'query',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _query();
              },
            ),
            ElevatedButton(
              child: const Text(
                'update',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _update();
              },
            ),
            ElevatedButton(
              child: const Text(
                'delete',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ボタンが押されたときのメソッド類

  // insertが押されたときのメソッド
  void _insert() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  // queryが押されたときのメソッド
  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  // updateが押された時のメソッド
  void _update() async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  // deleteが押された時のメソッド
  void _delete() async {
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id!);
    print('deleted $rowsDeleted row(s): row $id');
  }
}
