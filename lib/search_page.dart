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
  var frameworks = <String, String>{};
  var fast = true;

  final List<String> searchTargets =
      List.generate(10, (index) => 'Something ${index + 1}');

  List<String> searchResults = [];

  void _savewrdo(String Word) {
    if (fast) {
      var farst = Word;
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
                _savewrdo(searchWord);
                controller!.clear();
              },
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: 'Enter Barcodeword'),
              //onChanged: (String val) {
              //  search(val, isCaseSensitive: isCaseSensitive);
              //},
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
