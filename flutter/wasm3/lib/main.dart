import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'motoko_helper.dart';

MoHelper? helper;

void main() {
  runApp(const MyApp());
  buildWasmInstance();
}

Future<void> buildWasmInstance() async {
  final wasm = await loadWasm();
  helper = MoHelper(wasm);
}

Future<ByteData> loadWasm() async {
  final data = await rootBundle.load('assets/a-motoko-lib.wasm');
  return data;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter <-> Motoko demo (wasm3)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter <-> Motoko demo (wasm3)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String name = "";

  Future<void> _showAlertDialog(String result) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Result'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Motoko returned: $result'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void callGreet() {
    var greet = helper!.lookupFunction("greet");
    var res = helper!.callFunction(greet, [0, helper!.stringToText(name)]);
    _showAlertDialog(helper!.textToString(res));
  }

  void callGetLastMessage() {
    var getMessage = helper!.lookupFunction("getMessage");
    var res = helper!.callFunction(getMessage, [0]);
    _showAlertDialog(helper!.textToString(res));
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: 'Enter your name',
                ),
                onChanged: (value) => name = value,
              ),
            ),
            ElevatedButton(
              onPressed: callGreet,
              child: const Text("greet()"),
            ),
            ElevatedButton(
              onPressed: callGetLastMessage,
              child: const Text("getLastMessage()"),
            ),
          ],
        ),
      ),
    );
  }
}
