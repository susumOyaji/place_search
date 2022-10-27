import 'package:flutter/material.dart';
import 'ToDo.dart';
import 'search_pageORG.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SearchPageORG(),//const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  var area = ['a', 'b'];
  var board = ['c', 'd'];
  var container = ['e', 'f'];
  var parts = ['44KK36886-A'];

  var listM = <List>[];
  var listB = <List>[];
  var listT = <List>[];
  var listP = <List>[];

  var array_1 = [
    [
      [
        [
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'], //P1
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'],
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1']
        ], //T1
        [
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'], //P2
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'],
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1']
        ],
        [
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'], //P1
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'],
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1']
        ], //T1
        [
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'], //P2
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1'],
          ['43KK49277-AZ'], ['44KK48541-A'], ['44KK36886-A1']
        ] //T2
      ], //B1
      [] //B2
    ], //M1
    [] //M2
  ];

  Map<String, String> frameworks = {
    'Flutter': 'Dart',
    'Rails': 'Ruby',
  };

  void expand() {
    var newList = new List.from(area)..addAll(board);
    print(newList);
    // [a, b, c, d]

    var newList2 = [area, board, container].expand((x) => x);
    print(newList2);
    // [a, b, c, d, e, f]

    var newList3 = [...area, ...board, ...container, ...parts];
    print(newList3);
    // [a, b, c, d, e, f]
  }

  void _partsAdd() {
    parts.add('pAdd');
  }

  void _barcodeSelect(String barcode) {
    print(barcode);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            TextField(
              //controller: controller,
              decoration: InputDecoration(hintText: 'Enter keyword'),
              onChanged: (String val) {
                _barcodeSelect(val);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: expand, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
