import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_wasm/flutter_wasm.dart';
import 'package:flutter_wasmer/motoko_helper.dart';

WasmInstance? instance;
MoHelper? helper;

void main() async {
  runApp(const MyApp());
  buildWasmInstance();
}

Future<Uint8List> loadWasm() async {
  final data = await rootBundle.load('assets/a-motoko-lib.wasm');
  return data.buffer.asUint8List();
}

Future<void> buildWasmInstance() async {
  final wasm = await loadWasm();
  final builder = wasmModuleCompileSync(wasm).builder();
  builder.addFunction(
      "wasi_unstable", "fd_write", (int a, int b, int c, int d) => 0);
  instance = builder.build();
  helper = MoHelper(instance!);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter <-> Motoko demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter <-> Motoko demo'),
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
    if (instance != null) {
      var greet = instance?.lookupFunction("greet");
      var res = greet(0, helper!.stringToText(name));
      _showAlertDialog(helper!.textToString(res));
    }
  }

  void callGetLastMessage() {
    if (instance != null) {
      var getMessage = instance?.lookupFunction("getMessage");
      var res = getMessage(0);
      _showAlertDialog(helper!.textToString(res));
    }
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
