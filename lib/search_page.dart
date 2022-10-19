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
  List<String> parts = [];
  var frameworks = <String, String>{};
  var fast = true;

  List<int> searchAreas = List.generate(10, (index) => index + 1);

  List<String> searcBoardS = List.generate(30, (index) => 'B ${index + 1}');

  List<String> searcContaners = List.generate(120, (index) => 'C ${index + 1}');

  List<String> searcParts = List.generate(1200, (index) => 'P ${index + 1}');

  List<String> searchResults = [];

  List<List<List<List<int>>>> list = [
    [
      [[]]
    ]
  ];





  /*
    ///A
    [
      //B0
      [
        //C0
        [10], //P
        [20], //P
        [30] //P
      ],
      [
        //C1
        [11], //P
        [21],
        [31]
      ],
      [
        //C2
        [12], //P
        [22],
        [32]
      ]
    ],
    [
      //B1
      [
        //C1
        [14], //P
        [24],
        [34]
      ]
    ],
  ];
  //print(list);
  //print(list[0][0][0]);

  //var a = searchAreas.first;
*/
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
      list.insert(2,[][][]);

      print(list[0][0][1]);
      print(list);
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
