import 'package:flutter/material.dart';

import './highlighted_text.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController? controller;
  bool isCaseSensitive = false;

  var frower = [];
  var area = [];
  var board = [];
  var container = [];
  var parts = ['44KK36886-A'];

  final List<String> searchTargets =
      List.generate(10, (index) => 'Something ${index + 1}');

  List<String> searchResults = [];

  void search(String query, {bool isCaseSensitive = false}) {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    } else {
      if (query.startsWith('A')) {
        // 指定した文字列(パターン)で始まるか否かを調べる。
        frower.add(query);
        frower = frower.toSet().toList(); //重複する要素を全て削除する
        print('Area: $frower');
      }
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

    frower = (List.generate(2, (index) => 'A${index + 1}')); //Area touroku
    print('Frower: $frower');

    area = (List.generate(10, (index) => 'B${index + 1}')); //板台車
    print('Area: $area');

    board = (List.generate(10, (index) => 'C${index + 1}')); //天箱
    print('Board: $board');

    container = (List.generate(10, (index) => 'P${index + 1}')); //部品
    print('Container: $container');

    parts = ['C1', 'B1', 'A1', 'F1']; //ｺﾝﾃﾅｰ,ﾎﾞｰﾄﾞ,ｴﾘｱ,ﾌﾛﾜｰ
    print(parts);
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
        title: const Text('Search PartsArea'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
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
                // 別で作成した関数を返す
                searchRecipeModel.searchRecipe(
                  searchWord, // onSubmittedプロパティの引数に入った値を使用
                  recipeNameAndIngredientNameList,
                );
              },
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter Barcodeword'),
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
