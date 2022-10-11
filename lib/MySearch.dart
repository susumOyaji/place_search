import 'package:flutter/material.dart';

import './search_page.dart';

void main() {
  runApp(MySearch());
}

class MySearch extends StatelessWidget {
  const MySearch({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Search Items',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SearchPage(),
    );
  }
}
