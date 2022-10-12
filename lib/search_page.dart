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
