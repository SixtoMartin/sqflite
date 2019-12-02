import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:func/func.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_example/src/common_import.dart';
import 'model/item.dart';
import 'model/test.dart';
import 'src/item_widget.dart';

class TestPage extends StatefulWidget {
  // return the path
  Future<String> initDeleteDb(String dbName) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    print(documentsDirectory);

    String path = join(documentsDirectory.path, dbName);

    // make sure the folder exists
    if (await new Directory(dirname(path)).exists()) {
      await deleteDatabase(path);
    } else {
      try {
        await new Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        print(e);
      }
    }
    return path;
  }

  final String title;
  final List<Test> tests = [];

  test(String name, Func0<FutureOr> fn) {
    tests.add(new Test(name, fn));
  }

  // Thrown an exception
  fail([String message]) {
    throw new Exception(message ?? "should fail");
  }

  TestPage(this.title) {}

  @override
  _TestPageState createState() => new _TestPageState();
}

expect(dynamic value, dynamic expected, {String reason}) {
  if (value != expected) {
    if (value is List || value is Map) {
      if (!const DeepCollectionEquality().equals(value, expected)) {
        throw new Exception("collection $value != $expected ${reason ?? ""}");
      }
      return;
    }
    throw new Exception("$value != $expected ${reason ?? ""}");
  }
}

bool verify(bool condition, [String message]) {
  if (condition == null) {
    throw new Exception('"$message" null condition');
  }
  if (!condition) {
    throw new Exception('"$message"');
  }
  return condition;
}

class _TestPageState extends State<TestPage> {
  int get _itemCount => items.length;

  List<Item> items = [];

  _run() async {
    if (!mounted) {
      return null;
    }

    setState(() {
      items.clear();
    });

    for (Test test in widget.tests) {
      Item item = new Item("${test.name}");
      int position;
      setState(() {
        position = items.length;
        items.add(item);
      });
      try {
        await test.fn();

        item = new Item("${test.name}")..state = ItemState.success;
      } catch (e) {
        print(e);
        item = new Item("${test.name}")..state = ItemState.failure;
      }

      if (!mounted) {
        return null;
      }

      setState(() {
        items[position] = item;
      });
    }
  }

  _runTest(int index) async {
    if (!mounted) {
      return null;
    }

    Test test = widget.tests[index];

    Item item = items[index];
    setState(() {
      item.state = ItemState.running;
    });
    try {
      print("TEST Running ${test.name}");
      await test.fn();
      print("TEST Done ${test.name}");

      item = new Item("${test.name}")..state = ItemState.success;
    } catch (e, st) {
      print("TEST Error $e running ${test.name}");
      try {
        //print(st);
        if (await Sqflite.getDebugModeOn()) {
          print(st);
        }
      } catch (_) {}
      item = new Item("${test.name}")..state = ItemState.failure;
    }

    if (!mounted) {
      return null;
    }

    setState(() {
      items[index] = item;
    });
  }

  @override
  initState() {
    super.initState();
    /*
    setState(() {
      _itemCount = 3;
    });
    */
    _run();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text(widget.title), actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.refresh),
            tooltip: 'Run again',
            onPressed: _run,
          ),
        ]),
        body: new ListView.builder(
            itemBuilder: _itemBuilder, itemCount: _itemCount));
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Item item = getItem(index);
    return new ItemWidget(item, (Item item) {
      //Navigator.of(context).pushNamed(item.route);
      _runTest(index);
    });
  }

  Item getItem(int index) {
    return items[index];
  }
}
